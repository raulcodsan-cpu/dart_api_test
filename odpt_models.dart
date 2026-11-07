/// Multilingual title map (e.g., `{"ja": "東京", "en": "Tokyo"}`)

class MultilingualTitle {
  final String? ja;
  final String? en;
  final Map<String, dynamic> raw;

  const MultilingualTitle({this.ja, this.en, this.raw = const {}});

  factory MultilingualTitle.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MultilingualTitle();
    return MultilingualTitle(
      ja: json['ja'] as String?,
      en: json['en'] as String?,
      raw: json,
    );
  }

  Map<String, dynamic> toJson() => raw.isNotEmpty
      ? raw
      : {if (ja != null) 'ja': ja, if (en != null) 'en': en};
}

/// Represents public transportation operator information (`odpt:Operator`).

class OdptOperator {
  final String id; // @id
  final String sameAs; // owl:sameAs
  final String? title; // dc:title
  final MultilingualTitle? operatorTitle; // odpt:operatorTitle
  final String? date; // dc:date

  const OdptOperator({
    required this.id,
    required this.sameAs,
    this.title,
    this.operatorTitle,
    this.date,
  });

  /// Factory constructor to create a stub object by identifier.
  factory OdptOperator.fromId(String sameAs) {
    return OdptOperator(id: '', sameAs: sameAs);
  }

  factory OdptOperator.fromJson(Map<String, dynamic> json) {
    return OdptOperator(
      id: json['@id'] as String? ?? '',
      sameAs: json['owl:sameAs'] as String? ?? '',
      title: json['dc:title'] as String?,
      operatorTitle: json['odpt:operatorTitle'] != null
          ? MultilingualTitle.fromJson(
              json['odpt:operatorTitle'] as Map<String, dynamic>,
            )
          : null,
      date: json['dc:date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '@type': 'odpt:Operator',
    '@id': id,
    'owl:sameAs': sameAs,
    if (title != null) 'dc:title': title,
    if (operatorTitle != null) 'odpt:operatorTitle': operatorTitle!.toJson(),
    if (date != null) 'dc:date': date,
  };
}

/// Represents station information (`odpt:Station`).

class OdptStation {
  final String id; // @id
  final String sameAs; // owl:sameAs
  final String? title; // dc:title
  final MultilingualTitle? stationTitle; // odpt:stationTitle
  final String? operator; // odpt:operator
  final String? railway; // odpt:railway
  final String? stationCode; // odpt:stationCode
  final double? longitude; // geo:long
  final double? latitude; // geo:lat
  final List<String> connectingRailways; // odpt:connectingRailway
  final List<String> connectingStations; // odpt:connectingStation

  const OdptStation({
    required this.id,
    required this.sameAs,
    this.title,
    this.stationTitle,
    this.operator,
    this.railway,
    this.stationCode,
    this.longitude,
    this.latitude,
    this.connectingRailways = const [],
    this.connectingStations = const [],
  });

  /// Factory constructor to create a stub object by identifier.
  factory OdptStation.fromId(String sameAs) {
    return OdptStation(id: '', sameAs: sameAs);
  }

  factory OdptStation.fromJson(Map<String, dynamic> json) {
    return OdptStation(
      id: json['@id'] as String? ?? '',
      sameAs: json['owl:sameAs'] as String? ?? '',
      title: json['dc:title'] as String?,
      stationTitle: json['odpt:stationTitle'] != null
          ? MultilingualTitle.fromJson(
              json['odpt:stationTitle'] as Map<String, dynamic>,
            )
          : null,
      operator: json['odpt:operator'] as String?,
      railway: json['odpt:railway'] as String?,
      stationCode: json['odpt:stationCode'] as String?,
      longitude: (json['geo:long'] as num?)?.toDouble(),
      latitude: (json['geo:lat'] as num?)?.toDouble(),
      connectingRailways:
          (json['odpt:connectingRailway'] as List<dynamic>?)?.cast<String>() ??
          const [],
      connectingStations:
          (json['odpt:connectingStation'] as List<dynamic>?)?.cast<String>() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    '@type': 'odpt:Station',
    '@id': id,
    'owl:sameAs': sameAs,
    if (title != null) 'dc:title': title,
    if (stationTitle != null) 'odpt:stationTitle': stationTitle!.toJson(),
    if (operator != null) 'odpt:operator': operator,
    if (railway != null) 'odpt:railway': railway,
    if (stationCode != null) 'odpt:stationCode': stationCode,
    if (longitude != null) 'geo:long': longitude,
    if (latitude != null) 'geo:lat': latitude,
    if (connectingRailways.isNotEmpty)
      'odpt:connectingRailway': connectingRailways,
    if (connectingStations.isNotEmpty)
      'odpt:connectingStation': connectingStations,
  };
}

/// Represents real-time train location and status (`odpt:Train`).

class OdptTrain {
  final String id; // @id
  final String sameAs; // owl:sameAs
  final String trainNumber; // odpt:trainNumber
  final String? operator; // odpt:operator
  final String? railway; // odpt:railway
  final String? railDirection; // odpt:railDirection
  final String? trainType; // odpt:trainType
  final String? fromStation; // odpt:fromStation
  final String? toStation; // odpt:toStation
  final List<String> originStation; // odpt:originStation
  final List<String> destinationStation; // odpt:destinationStation
  final int? delay; // odpt:delay (seconds)
  final int? carComposition; // odpt:carComposition
  final String? date; // dc:date
  final String? valid; // dct:valid

  const OdptTrain({
    required this.id,
    required this.sameAs,
    required this.trainNumber,
    this.operator,
    this.railway,
    this.railDirection,
    this.trainType,
    this.fromStation,
    this.toStation,
    this.originStation = const [],
    this.destinationStation = const [],
    this.delay,
    this.carComposition,
    this.date,
    this.valid,
  });

  /// Factory constructor to create a stub object by identifier.
  factory OdptTrain.fromId(String sameAs) {
    return OdptTrain(
      id: '',
      sameAs: sameAs,
      trainNumber: sameAs.split('.').last,
    );
  }

  factory OdptTrain.fromJson(Map<String, dynamic> json) {
    return OdptTrain(
      id: json['@id'] as String? ?? '',
      sameAs: json['owl:sameAs'] as String? ?? '',
      trainNumber: json['odpt:trainNumber'] as String? ?? '',
      operator: json['odpt:operator'] as String?,
      railway: json['odpt:railway'] as String?,
      railDirection: json['odpt:railDirection'] as String?,
      trainType: json['odpt:trainType'] as String?,
      fromStation: json['odpt:fromStation'] as String?,
      toStation: json['odpt:toStation'] as String?,
      originStation:
          (json['odpt:originStation'] as List<dynamic>?)?.cast<String>() ??
          const [],
      destinationStation:
          (json['odpt:destinationStation'] as List<dynamic>?)?.cast<String>() ??
          const [],
      delay: (json['odpt:delay'] as num?)?.toInt(),
      carComposition: (json['odpt:carComposition'] as num?)?.toInt(),
      date: json['dc:date'] as String?,
      valid: json['dct:valid'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    '@type': 'odpt:Train',
    '@id': id,
    'owl:sameAs': sameAs,
    'odpt:trainNumber': trainNumber,
    if (operator != null) 'odpt:operator': operator,
    if (railway != null) 'odpt:railway': railway,
    if (railDirection != null) 'odpt:railDirection': railDirection,
    if (trainType != null) 'odpt:trainType': trainType,
    if (fromStation != null) 'odpt:fromStation': fromStation,
    if (toStation != null) 'odpt:toStation': toStation,
    if (originStation.isNotEmpty) 'odpt:originStation': originStation,
    if (destinationStation.isNotEmpty)
      'odpt:destinationStation': destinationStation,
    if (delay != null) 'odpt:delay': delay,
    if (carComposition != null) 'odpt:carComposition': carComposition,
    if (date != null) 'dc:date': date,
    if (valid != null) 'dct:valid': valid,
  };
}
