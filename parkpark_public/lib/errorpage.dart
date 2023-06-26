import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  final double horizontalPadding = 40;
  final double verticalPadding = 25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
              child: Column(
                children: [
                  const SizedBox(height: 130),
                  Text(
                    "ParkPark",
                    style: GoogleFonts.dmSans(fontSize: 50, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  Text(
                    "Find your way back to nature",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const <Widget>[
                      Icon(
                        Icons.signal_wifi_off,
                        color: Colors.white,
                        size: 50.0,
                      ),
                      Icon(
                        Icons.wrong_location_sharp,
                        color: Colors.white,
                        size: 50.0,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Oh no!",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),

                  Text(
                    "Currently facing connection issues.",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),

                  Text(
                    "Please try the following and restart the app.",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 40),

            Text(
              "Please try",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const <Widget>[
                Icon(
                  Icons.signal_wifi_4_bar,
                  color: Colors.white,
                  size: 50.0,
                ),
                Text(
                  "connecting to the internet",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const <Widget>[
                Icon(
                  Icons.location_pin,
                  color: Colors.white,
                  size: 50.0,
                ),
                Text(
                  "enabling location services",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}