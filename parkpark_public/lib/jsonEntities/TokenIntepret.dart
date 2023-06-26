// To parse this JSON data, do
//
//     final tokenGetter = tokenGetterFromJson(jsonString);

import 'dart:convert';

TokenGetter tokenGetterFromJson(String str) => TokenGetter.fromJson(json.decode(str));

String tokenGetterToJson(TokenGetter data) => json.encode(data.toJson());

class TokenGetter {
  TokenGetter({
    required this.status,
    required this.message,
    required this.result,
  });

  String status;
  String message;
  String result;

  factory TokenGetter.fromJson(Map<String, dynamic> json) => TokenGetter(
    status: json["Status"],
    message: json["Message"],
    result: json["Result"],
  );

  Map<String, dynamic> toJson() => {
    "Status": status,
    "Message": message,
    "Result": result,
  };
}