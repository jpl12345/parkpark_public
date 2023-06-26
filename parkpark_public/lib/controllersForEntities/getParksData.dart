import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parkpark/entities/parkCSV.dart';

class GetParksData {
  Future<List<Park>> readParkCSV_updateDist(Future<Position> user_pos) async {
    final input = await rootBundle.loadString('assets/parks.csv');
    var fields = const CsvToListConverter(fieldDelimiter: ",").convert(input);
    final parks = fields.map((row) => Park(row[0], row[1], row[2], row[3])).toList();
    Position user_position = await user_pos;
    await Future.forEach(parks, (park) async {
      park.setdistanceFromUser(
          Geolocator.distanceBetween(park.latitude, park.longitude, user_position.latitude, user_position.longitude) /
              1000);
    });
    parks.sort((a, b) => a.distanceFromUser.compareTo(b.distanceFromUser));
    return parks;
  }
}
