import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:parkpark/entities/parkCSV.dart';
import 'package:parkpark/jsonEntities/FourDayForecast.dart';
import 'package:parkpark/jsonEntities/twoHweatherforecast.dart';


class GetWeatherForecast{
  String generateDateTimeArg() {
    DateTime current_timeanddate = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(current_timeanddate);
    String formattedTime = DateFormat.Hms().format(current_timeanddate);
    String combined = "${formattedDate}T$formattedTime";
    //print(combined);
    return combined;
  }

  String generateDateArg() {
    DateTime current_timeanddate = DateTime.now().subtract(Duration(
        days: 1)); // because sometimes current day will generate blank response
    String formattedDate = DateFormat('yyyy-MM-dd').format(current_timeanddate);
    return formattedDate;
  }

  Future<List<AreaMetadatum>> getAreaMetadataFrom2hForecast () async {
    String current_time = generateDateTimeArg();

    var headers = {
      'accept': 'application/json',
    };

    var url = Uri.parse(
        'https://api.data.gov.sg/v1/environment/2-hour-weather-forecast?date_time=$current_time');
    var twoHRaw = await http.get(url, headers: headers);
    if (twoHRaw.statusCode != 200) {
      throw Exception('http.get error: statusCode= ${twoHRaw.statusCode}');
    }
    //print(twoHRaw.body);

    final weatherTwoH = twoHWeatherForecastFromJson(twoHRaw.body);
    return weatherTwoH.areaMetadata;
  }

  Future<List<Forecast>> get4DayForecast() async {
    String dateToday = generateDateArg();
    var headers = {
      'accept': 'application/json',
    };

    var url = Uri.parse(
        'https://api.data.gov.sg/v1/environment/4-day-weather-forecast?date=$dateToday');
    var fourDayRaw = await http.get(url, headers: headers);
    if (fourDayRaw.statusCode != 200)
      throw Exception('http.get error: statusCode= ${fourDayRaw.statusCode}');

    final fourDayWeatherForecast =
    fourDayWeatherForecastFromJson(fourDayRaw.body);
    //print(fourDayWeatherForecast.items.length);

    List<Forecast> filtered4dayforecast = [];

    for (int j = 1; j < fourDayWeatherForecast.items[0].forecasts.length; j++) {
      filtered4dayforecast.add(fourDayWeatherForecast.items[0].forecasts[j]);
      //print(fourDayWeatherForecast.items[i].forecasts[j]);

    }
    //
    // for (int i = 0; i < filtered4dayforecast.length; i++) {
    //   print('${filtered4dayforecast[i].date}->${filtered4dayforecast[i].forecast}');
    // }
    return filtered4dayforecast;
  }


  Future<List<ForecastElement>> getTwoHForecasts() async {
    String current_time = generateDateTimeArg();

    var headers = {
      'accept': 'application/json',
    };

    var url = Uri.parse(
        'https://api.data.gov.sg/v1/environment/2-hour-weather-forecast?date_time=$current_time');
    var twoHRaw = await http.get(url, headers: headers);
    if (twoHRaw.statusCode != 200)
      throw Exception('http.get error: statusCode= ${twoHRaw.statusCode}');
    //print(twoHRaw.body);

    final weatherTwoH = twoHWeatherForecastFromJson(twoHRaw.body);

    List<ForecastElement> area_and_forecast = [];

    for (var i = 0; i < weatherTwoH.items.length; i++) {
      for (var j = 0; j < weatherTwoH.items[i].forecasts.length; j++) {
        area_and_forecast.add(weatherTwoH.items[i].forecasts[j]);
      }
    }

    return area_and_forecast;
  }

  Future<String> determineClosest2hForecastArea(List<AreaMetadatum> areaMetadataList, Park target_park) async {
    String closestArea = "";
    double minDistance = double.infinity;

    double parklat = target_park.latitude;
    double parklong = target_park.longitude;

    for (int i = 0; i < areaMetadataList.length; i++) {
      double lat = areaMetadataList[i].labelLocation.latitude;
      double lon = areaMetadataList[i].labelLocation.longitude;
      double distance = Geolocator.distanceBetween(parklat, parklong, lat, lon);

      // Update the closest area if the distance is smaller than the current minimum
      if (distance < minDistance) {
        minDistance = distance;
        closestArea = areaMetadataList[i].name;
      }
    }

    return closestArea;
  }

}