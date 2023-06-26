import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'jsonEntities/twoHweatherforecast.dart';
import 'entities/parkCSV.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'jsonEntities/FourDayForecast.dart';

import 'package:parkpark/controllersForEntities/getWeatherForecast.dart';

class WeatherInfoPage extends StatefulWidget {
  Park selPark;

  WeatherInfoPage({Key? key, required this.selPark}) : super(key: key);

  @override
  State<WeatherInfoPage> createState() => WeatherInfoPageController(selPark);
}

class WeatherInfoPageController extends State<WeatherInfoPage> {
  Park selectedPark;

  String closestAreaFor2h = '';

  WeatherInfoPageController(this.selectedPark);

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

    closestAreaFor2h = await getClosestArea(weatherTwoH.areaMetadata);
    //print(closestAreaFor2h);

    List<ForecastElement> filtered_2hforecast = [];
    for (var i = 0; i < area_and_forecast.length; i++) {
      if (area_and_forecast[i].area == closestAreaFor2h) {
        filtered_2hforecast.add(area_and_forecast[i]);
      }
    }
    return filtered_2hforecast;
  }

  Future<List<Forecast>> download4dayforecast() async {
    return await GetWeatherForecast().get4DayForecast();
  }

  Future<String> getClosestArea(List<AreaMetadatum> areaMetadataList) async {
    String closestArea = "";
    double minDistance = double.infinity;

    double parklat = selectedPark.latitude;
    double parklong = selectedPark.longitude;

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

  String _getImagePathForWeatherCondition(String forecast) {
    // Return image asset path based on forecast description
    if (forecast.toLowerCase().contains('fair') &&
        !forecast.toLowerCase().contains('night')) {
      return 'assets/images/weather_sunny.png';
    } else if (forecast.toLowerCase().contains('cloudy') ||
        forecast.toLowerCase().contains('overcast')) {
      return 'assets/images/weather_cloudy.png';
    } else if (forecast.toLowerCase().contains('rain') ||
        forecast.toLowerCase().contains('shower') ||
        forecast.toLowerCase().contains('showers')) {
      return 'assets/images/weather_rain.png';
    } else if (forecast.toLowerCase().contains('thunderstorm') ||
        forecast.toLowerCase().contains('thundery')) {
      return 'assets/images/weather_thunderstorm.png';
    }
    return 'assets/images/default.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather Information"),
        centerTitle: true,
      ),
      body: Column(children: [
        FutureBuilder<List<ForecastElement>>(
          future: getTwoHForecasts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('An error occurred'));
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '2 hour Weather Forecast',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        const SizedBox(height: 16.0),
                        ...snapshot.data!.map((forecast) => ListTile(
                              leading: Image.asset(
                                _getImagePathForWeatherCondition(
                                    forecast.forecast),
                                height: 40.0,
                                width: 40.0,
                              ),
                              title: Text(
                                '${forecast.area} (${forecast.forecast})',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              subtitle: Text(forecast.forecast),
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
        FutureBuilder<List<Forecast>>(
          future: download4dayforecast(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('An error occurred'));
            } else {
              List<Forecast> forecastList = snapshot.data!;
              return Expanded(
                child: ListView.builder(
                  itemCount: forecastList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Forecast forecast = forecastList[index];
                    String forecastDate = DateFormat('d MMMM, EEE')
                        .format(DateTime.parse(forecast.date));
                    String forecastDescription = forecast.forecast;
                    String imagePath =
                        _getImagePathForWeatherCondition(forecastDescription);
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Weather Forecast for $forecastDate',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            const SizedBox(height: 16.0),
                            ListTile(
                              leading: Image.asset(
                                imagePath,
                                height: 40.0,
                                width: 40.0,
                              ),
                              subtitle: Text(forecast.forecast),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        )
      ]),
    );
  }
}
