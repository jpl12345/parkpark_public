
class CleanedCarparks {
  String carparkNo;
  String carparkName = 'blank';
  int numLotsAvail = -1;
  double distFromUser = 0;
  double lat = 0;
  double long = 0;
  String geometries ='';
  String lotType;

  CleanedCarparks(this.carparkNo, this.numLotsAvail, this.lotType, this.geometries) {
    updateLatLong();
  }



  void updateLatLong() {
    //print(geometries);
    var splitted = geometries.split(",");
    lat = double.tryParse(splitted[0])!;
    long = double.tryParse(splitted[1])!;


  }

  void setdistanceFromUser(double dist) {
    distFromUser = dist;
  }



}

