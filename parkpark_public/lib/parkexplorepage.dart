import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'entities/parkCSV.dart';
import 'parkdescriptionpage.dart';
import 'controllersForEntities/getParksData.dart';



class ParkExplorePage extends StatefulWidget {
  const ParkExplorePage({Key? key}) : super(key: key);

  @override
  State<ParkExplorePage> createState() => ParkExplorePageController();
}

class ParkExplorePageController extends State<ParkExplorePage> {
  late Future<List<Park>> futureParkList;
  String _searchTerm = '';
  double _maxDistance = 5; // Default maximum distance value is 5 km


  Future<List<Park>> getListOfParks() {
    Future<Position> user_pos =  Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    Future<List<Park>> data = GetParksData().readParkCSV_updateDist(user_pos);
    return data;
  }


  List<Park> searchPark(List<Park> parks, String searchTerm, double maxDistance) {
    if (searchTerm.isEmpty) {
      return parks.where((park) => park.distanceFromUser <= maxDistance).toList();
    }

    return parks.where((park) =>
    park.name.toLowerCase().contains(searchTerm.toLowerCase()) &&
        park.distanceFromUser <= maxDistance)
        .toList();
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Park Explore Page'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Park>>(
        future: getListOfParks(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final parks = searchPark(snapshot.data!, _searchTerm, _maxDistance);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search parks',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchTerm = value;
                      });
                    },
                  ),

                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.always,
                    decoration: InputDecoration(
                      hintText: 'Enter Max Distance (km), currently set to 5km.',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final double? parsedValue = double.tryParse(value ?? '');
                      if (parsedValue == null || parsedValue < 1 || parsedValue > 50) {
                        return 'Please enter a number between 1 and 50';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _maxDistance = double.tryParse(value) ?? _maxDistance;
                      });
                    },
                  ),

                ),

                Expanded(
                  child: parks.isNotEmpty
                      ? Scrollbar(
                    child: ListView.builder(
                      itemCount: parks.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ParkDescriptionPage(
                                  sel_park: parks[index],
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Image(
                                image: AssetImage(parks[index].picture_path),
                                height: 200,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              ListTile(
                                title: Text(parks[index].name, style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(parks[index].distanceFromUser.toStringAsFixed(2) + "km away"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                      : Center(child: Text('No parks matching search term or criteria found')),
                ),


              ],
            );
          }


        },
      ),
    );
  }
}




