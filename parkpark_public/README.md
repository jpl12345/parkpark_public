# Running ParkPark

This folder contains files for the mobile park application built using Flutter, ParkPark.

## Getting Started

To run the code, please follow the instructions on (https://youtu.be/hfz_AraTk_k) if you are using windows, or follow (https://youtu.be/JJwBoRMY08U) if you are using Mac.
You may be required to install Java.


The following version of flutter was used:
- Flutter 3.3.10 • channel stable • https://github.com/flutter/flutter.git
- Framework • revision 135454af32 (3 months ago) • 2022-12-15 07:36:55 -0800
- Engine • revision 3316dd8728
- Tools • Dart 2.18.6 • DevTools 2.15.0

To open our project in Android studio, click on File->Open and select the folder containing our code. The parent directory should contain:
- .dart_tool
- .flutter-plugins
- .flutter-plugins-dependencies
- .gitignore
- .idea
- .metadata
- analysis_options.yaml
- /android
- /assets
- /build
- /ios
- /lib
- /linux
- /macos
- pubspec.lock
- pubspec.yaml
- README.md
- /test
- /web
- /windows

The source code is located in /lib

# IMPORTANT!
Please take note that you will need to set the date and time of your phone/emulated phone to match GMT+8 to display forecasts correctly.

## API Keys
You will need to provide your own Google Maps API keys in the files below:
- Google Maps API Keys were replaced with [YOUR-GOOGLE-API-KEY]
1. android/app/src/main/AndroidManifest.xml
2. ios/Runner/AppDelegate.swift


You will also need to get your own URA access keys for the files below:
- Access Key was replaced with [URA-ACCESS-KEY]
1. lib/controllersForEntities/getCarparkdata.dart
2. lib/loadingscreen.dart
