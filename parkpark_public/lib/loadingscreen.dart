import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'homescreen.dart';
import 'errorpage.dart';


class LoadingScreen extends StatefulWidget {
  @override
  PermissionChecker createState() => PermissionChecker();
}

class PermissionChecker extends State<LoadingScreen> {

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  Future<void> checkPermission() async {
    bool locationStatus = await Permission.locationWhenInUse.isGranted;
    Location location = Location();

    var headers = {
      'AccessKey': '[URA-ACCESS-KEY]',
    };

    var url = Uri.parse('https://www.ura.gov.sg/uraDataService/insertNewToken.action');
    var resFuture = http.get(url, headers: headers);

    try {
      var res = await resFuture.timeout(Duration(seconds: 5)); // add timeout of 5 seconds
      if (locationStatus == true && res.statusCode == 200){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
      } else {
        await location.requestPermission();
        locationStatus = await Permission.locationWhenInUse.isGranted;
        if (locationStatus == true && res.statusCode == 200){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ErrorPage()));
        }
      }
    } on TimeoutException catch (_) {
      // show error page if timeout occurs
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ErrorPage()));
    } catch (_) {
      // show error page for any other errors
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ErrorPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
