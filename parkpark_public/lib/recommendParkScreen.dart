import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parkpark/entities/carParkforScreens.dart';
import 'package:parkpark/entities/parkCSV.dart';
import 'package:parkpark/parkdescriptionpage.dart';
import 'controllersForEntities/getParksData.dart';
import 'controllersForEntities/getWeatherForecast.dart';
import 'package:parkpark/controllersForEntities/getCarparkdata.dart';

class RecommendParkScreen extends StatefulWidget {
  const RecommendParkScreen({Key? key}) : super(key: key);

  @override
  State<RecommendParkScreen> createState() => RecommendParkScreenController();
}

class RecommendParkScreenController extends State<RecommendParkScreen> {
  late bool isDriving = false;
  late double distance = 5;
  Future<Position> userPosition =
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  TextEditingController popupTextController = TextEditingController();
  bool _isLoading = false;
  late Park recommended_park;

  Future<List<Park>> getListofParks() async {
    return GetParksData().readParkCSV_updateDist(userPosition);
  }

  Future<String> determinePark() async {
    // Get the weather forecast for the next 2 hours and the user's location
    setState(() {
      _isLoading = true;
    });
    var twoHourForecasts = await GetWeatherForecast().getTwoHForecasts();

    bool foundDryPark = false;

    // Find the dry regions
    List<String> dryRegions = [];
    for (var forecast in twoHourForecasts) {
      if (!['rain', 'showers', 'thunderstorms', 'thundery'].any(
          (substring) => forecast.forecast.toLowerCase().contains(substring))) {
        //print('added into dry ' + forecast.forecast);
        dryRegions.add(forecast.area);
      }
    }

    // for (int i=0; i<twoHourForecasts.length; i++){
    //   //print('${twoHourForecasts[i].area} ${twoHourForecasts[i].forecast}');
    // }

    // Find the closest dry region to the user's location
    var areaMetadata =
        await GetWeatherForecast().getAreaMetadataFrom2hForecast();

    if (dryRegions.isEmpty) {
      // No dry areas found, terminate
      setState(() {
        _isLoading = false;
      });
      //print('Sorry, it\'s raining everywhere in the next 2 hours');
      return ('Sorry, it\'s raining everywhere in the next 2 hours');
    }

    // for (int i=0; i<dryRegions.length; i++){
    //   print(dryRegions[i]);
    // }

    // Check if there are any parks within the specified distance from the user's location and the closest dry area
    if (isDriving == false) {
      var allParks = await getListofParks();
      for (var park in allParks) {
        if (park.distanceFromUser <= distance) {
          // filter all parks based on user's distance preference
          var closest_forecast_area = await GetWeatherForecast()
              .determineClosest2hForecastArea(areaMetadata, park);
          for (int i = 0; i < dryRegions.length; i++) {
            if (dryRegions[i] == closest_forecast_area) {
              // check if park is dry
              setState(() {
                _isLoading = false;
              });
              foundDryPark = true;
              recommended_park = park;
              return park.name; // park is dry, terminate and recommend it
            }
          }
        }
      }

      if (foundDryPark == false) {
        setState(() {
          _isLoading = false;
        });
        return 'Sorry, no parks that are dry in less than ${distance}km from you.';
      }
    } else {
      // logic if driving is true
      var allParks = await getListofParks();
      for (var park in allParks) {
        if (park.distanceFromUser <= distance) {
          // filter all parks based on user's distance preference
          var closest_forecast_area = await GetWeatherForecast()
              .determineClosest2hForecastArea(areaMetadata, park);
          List<CleanedCarparks> carparks = [];
          var carparkAvailResults = GetCarparkAvailResults();
          carparkAvailResults.getcarparkResults();
          carparkAvailResults.readCsvFileAndCalcDistFromPark(park);
          carparks = await carparkAvailResults.updateAndReturnAvailLots();

          for (int i = 0; i < dryRegions.length; i++) {
            if (dryRegions[i] == closest_forecast_area) {
              // check if park is dry
              {
                for (int i = 0; i < 4; i++) {
                  if (carparks[i].numLotsAvail > 0 &&
                      carparks[i].distFromUser < 2000) {
                    // number of lots available in 1st 4 are >0 and dist <2000
                    setState(() {
                      _isLoading = false;
                    });
                    foundDryPark = true;
                    recommended_park = park;
                    return park.name; // park is dry and lots available, terminate and recommend it
                  }
                }
              }
            }
          }
        }
      }

      if (foundDryPark == false) {
        setState(() {
          _isLoading = false;
        });
        return 'Sorry, no parks that are dry and has available lots in less than ${distance}km from you.';
      }
    }

    // The below statement is only reached in erroneous situations
    setState(() {
      _isLoading = false;
    });

    return 'Sorry, unhandled error!';
  }

  Future<Park> searchAndReturnPark(String name) async {
    List<Park> listofparks = await getListofParks();
    for (int i = 0; i < listofparks.length; i++) {
      if (listofparks[i].name == name) {
        return listofparks[i];
      }
    }
    throw Exception('Error! Sorry, but no parks found with matching name!');
  }

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (message.toLowerCase().contains('sorry')) {
          // if message contains 'sorry', show only OK button
          return AlertDialog(
            title: Text('Recommendation'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        } else {
          // if message does not contain 'sorry', show OK and Take me there! buttons
          return AlertDialog(
            title: Text('Recommendation'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParkDescriptionPage(
                      sel_park: recommended_park,
                    ),
                  ),
                ),
                child: Text('Take me there!'),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    isDriving = false;
    distance = 5.0; // default distance of 5 km
  }

  void _updateIsDriving(bool? value) {
    setState(() {
      isDriving = value!;
    });
  }

  void _updateDistance(double value) {
    setState(() {
      distance = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommend Park'),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                'Find a Park!',
                style: Theme.of(context).textTheme.headline6?.copyWith(
                      color: Colors.white,
                      fontSize: 40,
                    ),
              ),
            ),
            SizedBox(height: 100),
            Text(
              'Are you driving?',
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Colors.white,
                  ),
            ),
            SizedBox(height: 10),
            Theme(
              data: ThemeData.dark(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: isDriving,
                    activeColor: Colors.yellow[700],
                    onChanged: _updateIsDriving,
                  ),
                  Text(
                    'Yes',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 20),
                  Radio<bool>(
                    value: false,
                    groupValue: isDriving,
                    activeColor: Colors.yellow[700],
                    onChanged: _updateIsDriving,
                  ),
                  Text(
                    'No',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'How far do you want to travel?',
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Colors.white,
                  ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '1 km',
                  style: TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Slider(
                        value: distance,
                        min: 1,
                        max: 30,
                        activeColor: Colors.yellow[700],
                        inactiveColor: Colors.grey,
                        divisions: 29,
                        onChanged: _updateDistance,
                      ),
                      Text(
                        '${distance.toStringAsFixed(1)} km',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Text(
                  '30 km',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.yellow[700]),
              onPressed: () async {
                var result = await determinePark();
                showAlertDialog(context, result);
              },
              child: _isLoading
                  ? const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Recommend a Park',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
