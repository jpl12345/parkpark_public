import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'recommendParkScreen.dart';
import 'allcarparkpage.dart';
import 'parkexplorepage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenController();
}

class HomeScreenController extends State<HomeScreen> {
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
                    'Find your way back to nature',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 40),

            Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 50.0,
                  ),
                  title: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.yellow[700],
                    minimumSize: const Size.fromHeight(60),),
                    child: const Text("Explore Parks", style: TextStyle(fontSize: 24),),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ParkExplorePage()));
                    },),),

                const SizedBox(height: 20),

                ListTile(
                  leading: Icon(
                    Icons.park,
                    color: Colors.white,
                    size: 50.0,
                  ),
                  title: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.yellow[700],
                    minimumSize: const Size.fromHeight(60),),
                    child: Text("Recommend a Park", style: TextStyle(fontSize: 24),),
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => RecommendParkScreen()));
                    },),),

                const SizedBox(height: 20),

                ListTile(
                  leading: Icon(
                    Icons.local_parking,
                    color: Colors.white,
                    size: 50.0,
                  ),
                  title: ElevatedButton(style: ElevatedButton.styleFrom(primary: Colors.yellow[700],
                    minimumSize: const Size.fromHeight(60),),
                    child: Text("Carpark Information", style: TextStyle(fontSize: 24),),
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AllCarparkPage()));
                    },),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
