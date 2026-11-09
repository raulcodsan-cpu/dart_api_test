import 'api_helper.dart';
import 'key_file.dart';
import 'odpt_models.dart';

void main() async {
  final odptConsumerKey = KeyFile.apiKey;

  final api = OdptApiService(consumerKey: odptConsumerKey);

  await loadTokyoStations(api);
  await monitorYamanoteTrains(api);
  await loadOperators(api);

  api.close();
}

Future<void> loadTokyoStations(OdptApiService api) async {
  print('--- Getting Yamanote Line Stations ---');

  // Filter stations belonging specifically to the JR East Yamanote Line
  final List<OdptStation> stations = await api.getStations(
    railway: 'odpt.Railway:JR-East.Yamanote',
  );

  for (final station in stations) {
    final name = station.stationTitle?.en ?? station.title ?? 'Unknown';
    print('Station: $name (${station.stationCode ?? "No Code"})');
    print('Coordinates: Lat ${station.latitude}, Long ${station.longitude}');
  }
  print('\n\n');
  // final tokyo = await api.getStations(title: '東京');
}

Future<void> monitorYamanoteTrains(OdptApiService api) async {
  print('--- Monitoring Real-Time Trains ---');

  final List<OdptTrain> liveTrains = await api.getTrains(
    railway: 'odpt.Railway:JR-East.Yamanote',
  );

  if (liveTrains.isEmpty) {
    print('No active trains reported at this moment.');
    print('\n\n');
    return;
  }

  for (final train in liveTrains) {
    final status = (train.delay != null && train.delay! > 0)
        ? 'Delayed by ${train.delay! ~/ 60} min'
        : 'On Time';

    final location = train.toStation != null
        ? 'Between ${train.fromStation} and ${train.toStation}'
        : 'At station: ${train.fromStation}';

    print(
      'Train #${train.trainNumber} [${train.carComposition ?? "?"} cars]: $status',
    );
    print('   Location: $location');
  }
  print('\n\n');
}

Future<void> loadOperators(OdptApiService api) async {
  print('--- Fetching Operators ---');

  // Fetch all registered operators
  final List<OdptOperator> operators = await api.getOperators();

  for (final operator in operators) {
    // dc:title holds the Japanese name; odpt:operatorTitle provides multilingual support
    final jaName = operator.title ?? operator.operatorTitle?.ja ?? 'Unknown';
    final enName = operator.operatorTitle?.en ?? 'No EN translation';

    print('Operator: $jaName ($enName)');
    print(
      'ID (owl:sameAs): ${operator.sameAs}',
    ); // e.g. "odpt.Operator:TokyoMetro"
  }
  print('\n\n');
}
