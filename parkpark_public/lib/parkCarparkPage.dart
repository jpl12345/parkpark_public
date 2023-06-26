import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'controllersForEntities/getCarparkdata.dart';
import 'entities/carParkforScreens.dart';
import 'entities/parkCSV.dart';


class ParkCarparkPage extends StatefulWidget {
  Park selPark;

  ParkCarparkPage({Key? key, required this.selPark}) : super(key: key);

  @override
  State<ParkCarparkPage> createState() => ParkCarparkPageController(selPark);
}

class ParkCarparkPageController extends State<ParkCarparkPage> {
  Park selectedPark;
  Future<List<CleanedCarparks>> carparkList = Future.value(List.empty());

  GoogleMapController? _mapController;
  final GetCarparkAvailResults _getCarparkAvailResults = GetCarparkAvailResults();

  ParkCarparkPageController(this.selectedPark);

  @override
  void initState() {
    super.initState();
    _getCarparkAvailResults.getcarparkResults();
    _getCarparkAvailResults.readCsvFileAndCalcDistFromPark(selectedPark);
    carparkList = _getCarparkAvailResults.updateAndReturnAvailLots();
  }

  Set<Marker> _getMarkers(List<CleanedCarparks> carparkList) {
    Set<Marker> markers = {};
    markers.add(Marker(
      markerId: MarkerId(selectedPark.name),
      position: LatLng(selectedPark.latitude, selectedPark.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));

    carparkList.take(4).forEach((carpark) {
      markers.add(Marker(
        markerId: MarkerId(carpark.carparkName),
        position: LatLng(carpark.lat, carpark.long),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    });

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
      appBar: AppBar(title: Text('Carpark')),
      body: FutureBuilder<List<CleanedCarparks>>(
        future: carparkList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<CleanedCarparks> carparkList =
            snapshot.data!..sort((a, b) => a.distFromUser.compareTo(b.distFromUser));
            return Column(
              children: [
                Expanded(child: _buildGoogleMap(carparkList)),
                Expanded(child: _buildListView(carparkList)),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildGoogleMap(List<CleanedCarparks> sortedList) {
    final selectedPark = sortedList.first;
    return GoogleMap(
      onMapCreated: (controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(selectedPark.lat, selectedPark.long),
        zoom: 13.0,
      ),
      markers: _getMarkers(sortedList),
    );
  }

  Widget _buildListView(List<CleanedCarparks> sortedList) {
    return ListView.builder(
      itemCount: sortedList.take(4).length,
      itemBuilder: (BuildContext context, int index) {
        final carpark = sortedList[index];
        return ListTile(
          title: Text(carpark.carparkNo + ': ' + carpark.carparkName),
          trailing: Text(carpark.numLotsAvail == -1 ? 'No availability data available' : '${carpark.numLotsAvail} lots available'),
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