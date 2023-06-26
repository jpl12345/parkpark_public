import 'package:flutter/material.dart';
import 'package:parkpark/loadingscreen.dart';
import 'package:google_fonts/google_fonts.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkPark',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Color(0xFFFFA000),
        accentColor: Colors.white,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
          headline1: GoogleFonts.dmSans(
              fontSize: 50, fontWeight: FontWeight.w800, color: Colors.white),
          headline2: const TextStyle(color: Colors.white),
          button: const TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black,
              ),
            ],
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor:
            MaterialStateProperty.all<Color>(Color(0xFFFFA000)),
            elevation: MaterialStateProperty.all<double>(2),
            shadowColor: MaterialStateProperty.all<Color>(Colors.black.withOpacity(0.5)),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      home: LoadingScreen(),
    );
  }
}