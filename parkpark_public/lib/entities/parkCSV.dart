
import 'dart:math';

class Park {
  final double longitude;
  final double latitude;
  final String name;
  final String description;

  double distanceFromUser = 0;
  String picture_path = '';

  Park(this.longitude, this.latitude, this.name, this.description){
    set_picture_name();
  }

  String _getImagePathForPark() {
    // Return image asset path based on forecast description
    Random random = Random(name.length + description.length);
    int fileNumber = random.nextInt(13) + 1;
    String filepath = "assets/park_images/$fileNumber.jpg";

    return filepath;
  }

  void setdistanceFromUser(double dist) {
    distanceFromUser = dist;
  }

  void set_picture_name (){
    picture_path = _getImagePathForPark();
  }


}