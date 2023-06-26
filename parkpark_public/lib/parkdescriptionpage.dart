import 'package:flutter/material.dart';
import 'entities/parkCSV.dart';
import 'weatherInfoPage.dart';
import 'parkCarparkPage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class ParkDescriptionPage extends StatefulWidget {
  Park sel_park;

  ParkDescriptionPage({Key? key, required this.sel_park}) : super(key: key);


  @override
  State<ParkDescriptionPage> createState() => ParkDescriptionPageController(sel_park);
}


class ParkDescriptionPageController extends State<ParkDescriptionPage> {
  Park selected_park_park;

  ParkDescriptionPageController(this.selected_park_park);

  CameraPosition _initialCameraPosition() {
    return CameraPosition(
      target: LatLng(selected_park_park.latitude, selected_park_park.longitude),
      zoom: 14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Park Description'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: GoogleMap(
                      initialCameraPosition: _initialCameraPosition(),
                      markers: {
                        Marker(
                          markerId: MarkerId(selected_park_park.name),
                          position: LatLng(selected_park_park.latitude, selected_park_park.longitude),
                          infoWindow: InfoWindow(title: selected_park_park.name),
                        ),
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selected_park_park.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                        Text(selected_park_park.distanceFromUser.toStringAsFixed(2) + "km away", textAlign: TextAlign.left,),
                        SizedBox(height: 10),
                        Text(selected_park_park.description, style: TextStyle(fontSize: 16))
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => (WeatherInfoPage(selPark: selected_park_park,)),
                    ));
                  },
                  child: Text('Weather Information'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => (ParkCarparkPage(selPark: selected_park_park,)),
                    ));
                  },
                  child: Text('Car Park Information'),
                ),
              ],
            ),
          ),
          //Spacer(),
        ],
      ),
    );
  }
}