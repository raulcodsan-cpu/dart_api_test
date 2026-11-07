import 'dart:convert';

import 'package:http/http.dart' as http;

import 'odpt_exceptions.dart';
import 'odpt_models.dart';

class OdptApiService {
  final String consumerKey;

  /// Dependency injection for later mock testing.
  final http.Client _client;

  /// Provied OR Default value URL endpoint value.
  final String _baseUrl;

  /// Default endpoint host per specification
  static const String defaultBaseUrl = 'https://api.odpt.org/api/v4';

  /// Default constructor.
  ///
  /// * **required** String [consumerKey].
  /// * **Optional** Http client [client]. (Default _http.Client()_).
  /// * **Optional** String [baseUrl]. (Default _https://api.odpt.org/api/v4_ from class attribute)
  ///
  /// <br>
  OdptApiService({
    required this.consumerKey,
    http.Client? client,
    String? baseUrl,
    // If http client is passed (mock client) it is used, otherwise created.
  }) : _client = client ?? http.Client(),
       // If url passed (portability for other apps) it is used, otherwise default is used.
       _baseUrl =
           (baseUrl ?? defaultBaseUrl); //.replaceAll(RegExp(r'/+$'), '');

  /// Core request executor handling authentication, URI encoding,
  /// `HTTP` status checking, and `JSON` for Linked Data (JSON-LD) List parsing.
  ///
  /// * **String** [endpoint] param. is final part of URL for API endpoint.
  /// * **Map<String, String>** [queryParameters] param. is for optional user-provided GET param.
  ///
  /// <br>
  Future<List<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
  }) async {
    // 1. Merge default acl:consumerKey parameter with user-provided parameters
    final mergedParams = <String, String>{
      // `...?` Unpacks the contents of the Map an inserts key-value pairs to [mergedParams] IF NOT NULL.
      ...?queryParameters,
      'acl:consumerKey': consumerKey,
    };

    // 2. Resolve relative endpoint vs full URL
    final String cleanPath = endpoint.startsWith('/') ? endpoint : '/$endpoint';

    final Uri uri = Uri.parse('$_baseUrl$cleanPath')
        .replace(queryParameters: mergedParams);
    print('Calling to Uri: $uri');

    // 3. Dispatch HTTP GET request
    final http.Response response;

    try {
      response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );
    } catch (e) {
      // Re-throw lower-level network/socket issues
      rethrow;
    }

    // 4. Validate HTTP Status Codes against specification [cite: 1]
    _handleResponseStatusCode(response);

    // 5. Parse response body.
    // The specification defines that all results are returned as a JSON Array of objects [cite: 1].
    // We use utf8.decode() to handle Japanese char.
    final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));
    //
    // There are cases were in JSON-LD the response can be a List<dynamic> rather than a Map<String, dynamic>.
    if (decoded is List) {
      // Creates a new lazy [Iterable] with all elements that have type [T].
      return decoded.whereType<Map<String, dynamic>>().toList();
    } else if (decoded is Map<String, dynamic>) {
      // Fallback safeguard if an endpoint returns a single JSON object
      return [decoded];
    } else {
      return const [];
    }
  }

  /// API error handling based on documentation https://developer.odpt.org/documents .<br>
  /// (See file: `odpt_exceptions.dart`)
  void _handleResponseStatusCode(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return;
      case 400:
        throw const OdptBadRequestException();
      case 401:
        throw const OdptUnauthorizedException();
      case 403:
        throw const OdptForbiddenException();
      case 404:
        throw const OdptNotFoundException();
      case 500:
        throw const OdptInternalServerErrorException();
      case 503:
        throw const OdptServiceUnavailableException();
      default:
        throw OdptHttpException(
          response.statusCode,
          'Unexpected error: ${response.reasonPhrase ?? "HTTP ${response.statusCode}"}',
        );
    }
  }

  // ==========================================
  // Hard-Typed Convenience APIs
  // ==========================================

  /// Fetch Operator data (`odpt:Operator`)
  /// * *Optional* String [sameAs]: Transport operator to search for.
  /// <br>
  /// E.g. :
  /// ```http
  ///		"owl:sameAs" : "odpt.Operator:JR-East",
  /// ```
  ///
  /// <br>
  Future<List<OdptOperator>> getOperators({String? sameAs}) async {
    // If [sameAs] has been passed, the parameters contains it, if not its empty.
    final params = <String, String>{'owl:sameAs': ?sameAs};

    final jsonList = await get('odpt:Operator', queryParameters: params);
    return jsonList.map((e) => OdptOperator.fromJson(e)).toList();
  }

  /// Fetch Station data (`odpt:Station`)
  /// Allows filtering by line, operator, or station name (supports comma-separated OR queries).
  /// ### Response example
  /// ```json
  /// {
  ///  @id: urn:ucode:_00001C00000000000001000003102901,
  ///  @type: odpt:Station,
  ///  dc:date: 2024-03-27T09:00:00+09:00,
  ///  @context: http://vocab.odpt.org/context_odpt_Station.jsonld, dc:title: 秋葉原,
  ///  owl:sameAs: odpt.Station:JR-East.Yamanote.Akihabara,
  ///  odpt:railway: odpt.Railway:JR-East.Yamanote,
  ///  odpt:operator: odpt.Operator:JR-East,
  ///  odpt:stationTitle: {
  ///     en: Akihabara,
  ///     ja: 秋葉原
  ///  }
  ///},```
  Future<List<OdptStation>> getStations({
    String? railway,
    String? operator,
    String? title,
    String? stationCode,
    String? sameAs,
  }) async {
    final params = <String, String>{
      if (railway != null) 'odpt:railway': railway,
      if (operator != null) 'odpt:operator': operator,
      if (title != null) 'dc:title': title,
      if (stationCode != null) 'odpt:stationCode': stationCode,
      if (sameAs != null) 'owl:sameAs': sameAs,
    };

    final jsonList = await get('odpt:Station', queryParameters: params);
    print('Response: $jsonList');
    return jsonList.map((e) => OdptStation.fromJson(e)).toList();
  }

  /// Fetch Real-time Train data (`odpt:Train`) .
  /// Returns train locations, delays, and destination information
  Future<List<OdptTrain>> getTrains({
    String? railway,
    String? operator,
    String? sameAs,
  }) async {
    final params = <String, String>{
      'odpt:railway': ?railway,
      'odpt:operator': ?operator,
      'owl:sameAs': ?sameAs,
    };

    final jsonList = await get('odpt:Train', queryParameters: params);
    return jsonList.map((e) => OdptTrain.fromJson(e)).toList();
  }

  /// Geographic Feature Search API (/v4/places/odpt:Station) <br>
  /// https://developer.odpt.org/documents#_%E5%9C%B0%E7%89%A9%E6%83%85%E5%A0%B1%E6%A4%9C%E7%B4%A2api_v4placesrdf_type:~:text=acl%3AconsumerKey%3DACL_CONSUMERKEY%27-,1.7.%20%E5%9C%B0%E7%89%A9%E6%83%85%E5%A0%B1%E6%A4%9C%E7%B4%A2API%20(/v4/places/RDF_TYPE%3F),-/v4/places%20%E3%81%A7%E3%81%AF
  Future<List<OdptStation>> getStationsNear({
    required double latitude,
    required double longitude,
    required double radiusInMeters, // Max 4000m according to the spec
  }) async {
    final params = <String, String>{
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'radius': radiusInMeters.clamp(0, 4000).toInt().toString(),
    };

    final jsonList = await get('places/odpt:Station', queryParameters: params);
    return jsonList.map((e) => OdptStation.fromJson(e)).toList();
  }

  /// Close underlying HTTP client resources.
  void close() {
    _client.close();
  }
}
