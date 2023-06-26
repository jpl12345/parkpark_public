// To parse this JSON data, do
//
//     final carparkIntepret = carparkIntepretFromJson(jsonString);

import 'dart:convert';

CarparkAvailResults carparkIntepretFromJson(String str) => CarparkAvailResults.fromJson(json.decode(str));

String carparkIntepretToJson(CarparkAvailResults data) => json.encode(data.toJson());

class CarparkAvailResults {
  CarparkAvailResults({
    required this.status,
    required this.message,
    required this.result,
  });

  String status;
  String message;
  List<ResultCarpark> result;

  factory CarparkAvailResults.fromJson(Map<String, dynamic> json) => CarparkAvailResults(
    status: json["Status"],
    message: json["Message"],
    result: List<ResultCarpark>.from(json["Result"].map((x) => ResultCarpark.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "Status": status,
    "Message": message,
    "Result": List<dynamic>.from(result.map((x) => x.toJson())),
  };
}

class ResultCarpark {
  ResultCarpark({
    required this.carparkNo,
    required this.geometries,
    required this.lotsAvailable,
    required this.lotType,
  });

  String carparkNo;
  List<Geometry> geometries;
  String lotsAvailable;
  LotType lotType;

  factory ResultCarpark.fromJson(Map<String, dynamic> json) => ResultCarpark(
    carparkNo: json["carparkNo"],
    geometries: List<Geometry>.from(json["geometries"].map((x) => Geometry.fromJson(x))),
    lotsAvailable: json["lotsAvailable"],
    lotType: lotTypeValues.map[json["lotType"]]!,
  );

  Map<String, dynamic> toJson() => {
    "carparkNo": carparkNo,
    "geometries": List<dynamic>.from(geometries.map((x) => x.toJson())),
    "lotsAvailable": lotsAvailable,
    "lotType": lotTypeValues.reverse[lotType],
  };
}

class Geometry {
  Geometry({
    required this.coordinates,
  });

  String coordinates;

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    coordinates: json["coordinates"],
  );

  Map<String, dynamic> toJson() => {
    "coordinates": coordinates,
  };
}

enum LotType { C, M, H }

final lotTypeValues = EnumValues({
  "C": LotType.C,
  "H": LotType.H,
  "M": LotType.M
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
