import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkpark/controllersForEntities/getCarparkdata.dart';
import 'entities/carParkforScreens.dart';


class AllCarparkPage extends StatefulWidget {
  const AllCarparkPage({Key? key}) : super(key: key);

  @override
  State<AllCarparkPage> createState() => AllCarparkPageController();
}

class AllCarparkPageController extends State<AllCarparkPage> {
  bool _showOnlyAvailable = false;
  int _numCarparksToShow = 4;
  List<CleanedCarparks> user_loc_carparks = [];
  GoogleMapController? _mapController;

  Future<List<CleanedCarparks>> getCleanedCarparks() async {
    Position user_pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var clean = GetCarparkAvailResults();
    clean.readCsvFileAndCalcDistParkFromUser(user_pos);

    // var lots = await clean.updateAndReturnAvailLots();
    // for (int i = 0; i < lots.length; i++) {
    //   print(lots[i].carparkName + lots[i].distFromUser.toString() +
    //       lots[i].numLotsAvail.toString());
    // }
    user_loc_carparks = await clean.updateAndReturnAvailLots();
    return user_loc_carparks;
  }


  Future<Position> getUserPosition() async {
    Position user_pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return user_pos;
  }

  Future<Set<Marker>> _getMarkers() async {
    var user_pos = await getUserPosition();

    Set<Marker> markers = {};
    markers.add(Marker(
      markerId: MarkerId('Your location'),
      position: LatLng(user_pos.latitude, user_pos.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));

    if (_showOnlyAvailable == false) {
      user_loc_carparks.take(_numCarparksToShow).forEach((carpark) {
        markers.add(Marker(
          markerId: MarkerId(carpark.carparkName),
          position: LatLng(carpark.lat, carpark.long),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));
      });
    } else {
      int count = 0;
      user_loc_carparks.forEach((carpark) {
        if (count >= _numCarparksToShow) {
          return;
        }
        if (carpark.numLotsAvail >= 0) {
          markers.add(Marker(
            markerId: MarkerId(carpark.carparkName),
            position: LatLng(carpark.lat, carpark.long),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
          ));
          count++;
        }
      });
    }
    return markers;
  }


  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carpark'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () async {
              final result = await showDialog<int>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Number of carparks to show (Choose from 1-10)'),
                    content: TextField(
                      keyboardType: TextInputType.number,
                      onSubmitted: (value) {
                        Navigator.pop(context, int.parse(value));
                      },
                    ),
                  );
                },
              );
              if (result != null && result >= 1 && result <= 10) {
                setState(() {
                  _numCarparksToShow = result;
                });
              }
            },
          ),
        ],
      ),

      body: FutureBuilder<List<CleanedCarparks>>(
        future: getCleanedCarparks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<CleanedCarparks> carparkList =
            snapshot.data!
              ..sort((a, b) => a.distFromUser.compareTo(b.distFromUser));
            return Column(
              children: [
                SwitchListTile(
                  title: Text('Show only carparks with availability data'),
                  value: _showOnlyAvailable,
                  onChanged: (value) {
                    setState(() {
                      _showOnlyAvailable = value;
                    });
                  },
                ),
                Expanded(
                  child: FutureBuilder<Set<Marker>>(
                    future: _getMarkers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        final Set<Marker> markers = snapshot.data!;
                        final selectedPark = carparkList.first;
                        return GoogleMap(
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          initialCameraPosition: CameraPosition(
                            target: LatLng(selectedPark.lat, selectedPark.long),
                            zoom: 13.0,
                          ),
                          markers: markers,
                        );
                      }
                    },
                  ),
                ),
                Expanded(child: _buildListView(carparkList)),
              ],
            );
          }
        },
      ),
    );
  }


  Widget _buildListView(List<CleanedCarparks> sortedList) {
    final filteredList = _showOnlyAvailable ? sortedList.where((
        carpark) => carpark.numLotsAvail >= 0).toList() : sortedList;
    return ListView.builder(
      itemCount: filteredList
          .take(_numCarparksToShow)
          .length,
      itemBuilder: (BuildContext context, int index) {
        final carpark = filteredList[index];
        return ListTile(
          title: Text(carpark.carparkNo + ': ' + carpark.carparkName),
          trailing: Text(carpark.numLotsAvail == -1
              ? 'No availability data available'
              : '${carpark.numLotsAvail} lots available'),
          subtitle: Text('${carpark.distFromUser.toStringAsFixed(2)}m away'),
          onTap: () {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(LatLng(carpark.lat, carpark.long), 18),
            );
          },
        );
      },
    );
  }

}
