import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:parkpark/entities/carParkforScreens.dart';
import 'package:parkpark/jsonEntities/CarParkIntepret.dart';
import 'package:parkpark/jsonEntities/TokenIntepret.dart';
import 'package:http/http.dart' as http;
import 'package:parkpark/entities/parkCSV.dart';
import 'package:geolocator/geolocator.dart';


class GetCarparkAvailResults{

  List<CleanedCarparks> _carparkList = [];


  Future<void> readCsvFileAndCalcDistFromPark(Park sel_park) async {
    final String fileData =
    await rootBundle.loadString('assets/carparkdetails.csv');
    List<dynamic> decodedCsv = const CsvToListConverter().convert(fileData);
    await Future.forEach(decodedCsv.skip(1), (dynamic decodedCsvItem) async {
      final String ppCode = decodedCsvItem[0];
      final String ppName = decodedCsvItem[1];
      final String geometries = decodedCsvItem[2];
      CleanedCarparks carpark = CleanedCarparks(ppCode, -1, "", geometries);
      carpark.carparkName = ppName;
      double carparkDistFromPark = Geolocator.distanceBetween(
          sel_park.latitude, sel_park.longitude, carpark.lat, carpark.long);
      carpark.setdistanceFromUser(carparkDistFromPark);
      _carparkList.add(carpark);
    });
    _carparkList.sort((a, b) => a.distFromUser.compareTo(b.distFromUser));
  }

  Future<void> readCsvFileAndCalcDistParkFromUser(Position user_pos) async {

    final String fileData = await rootBundle.loadString(
        'assets/carparkdetails.csv');
    List<dynamic> decodedCsv = const CsvToListConverter().convert(fileData);
    for (int i = 1; i < decodedCsv.length; i++) {
      final String ppCode = decodedCsv[i][0];
      final String ppName = decodedCsv[i][1];
      final String geometries = decodedCsv[i][2];
      CleanedCarparks carpark = CleanedCarparks(ppCode, -1, "", geometries);
      carpark.carparkName = ppName;
      double carparkDistFromUser = Geolocator.distanceBetween(
          user_pos.latitude, user_pos.longitude, carpark.lat, carpark.long);


      carpark.setdistanceFromUser(carparkDistFromUser);
      _carparkList.add(carpark);
    }
    _carparkList.sort((a, b) => a.distFromUser.compareTo(b.distFromUser));
  }

  Future<List<ResultCarpark>> getcarparkResults() async {
    var headers = {
      'AccessKey': '[URA-ACCESS-KEY]',
    };

    var url = Uri.parse(
        'https://www.ura.gov.sg/uraDataService/insertNewToken.action');
    var res = await http.get(url, headers: headers);
    if (res.statusCode != 200) {
      throw Exception(
          'http.get error: statusCode= ${res.statusCode}');
    }
    //print(res.body);
    //print(res.runtimeType);
    final tokenGetter = tokenGetterFromJson(res.body);
    //print(tokenGetter.result);

    headers = {
      'AccessKey': '[URA-ACCESS-KEY]',
      'Token': tokenGetter.result,
    };

    var params = {
      'service': 'Car_Park_Availability',
    };
    var query = params.entries.map((p) => '${p.key}=${p.value}').join('&');

    url = Uri.parse('https://www.ura.gov.sg/uraDataService/invokeUraDS?$query');
    res = await http.get(url, headers: headers);
    if (res.statusCode != 200) {
      throw Exception(
          'http.get error: statusCode= ${res.statusCode}');
    }

    final carparkIntepret = carparkIntepretFromJson(res.body);


    List<ResultCarpark> avail_slots = carparkIntepret.result;


    return avail_slots;
  }

  Future<List<CleanedCarparks>> _updateAvailableLots(
      Future<List<ResultCarpark>> resultsFuture) async {
    List<ResultCarpark> results = await resultsFuture;
    for (var result in results) {
      var carpark = _carparkList.firstWhere((c) =>
      c.carparkNo == result.carparkNo);
      if (carpark != null) {
        carpark.numLotsAvail = int.parse(result.lotsAvailable);
      }
    }
    return _carparkList;
  }

  Future<List<CleanedCarparks>> updateAndReturnAvailLots() {
    return _updateAvailableLots(getcarparkResults());
  }


}