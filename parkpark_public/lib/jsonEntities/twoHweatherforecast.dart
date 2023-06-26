// To parse this JSON data, do
//
//     final weatherTwoH = weatherTwoHFromJson(jsonString);

import 'dart:convert';

TwoHWeatherForecast twoHWeatherForecastFromJson(String str) => TwoHWeatherForecast.fromJson(json.decode(str));

String weatherTwoHToJson(TwoHWeatherForecast data) => json.encode(data.toJson());

class TwoHWeatherForecast {
  TwoHWeatherForecast({
    required this.areaMetadata,
    required this.items,
    required this.apiInfo,
  });

  List<AreaMetadatum> areaMetadata;
  List<Item> items;
  ApiInfo apiInfo;

  factory TwoHWeatherForecast.fromJson(Map<String, dynamic> json) => TwoHWeatherForecast(
    areaMetadata: List<AreaMetadatum>.from(json["area_metadata"].map((x) => AreaMetadatum.fromJson(x))),
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    apiInfo: ApiInfo.fromJson(json["api_info"]),
  );

  Map<String, dynamic> toJson() => {
    "area_metadata": List<dynamic>.from(areaMetadata.map((x) => x.toJson())),
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "api_info": apiInfo.toJson(),
  };
}

class ApiInfo {
  ApiInfo({
    required this.status,
  });

  String status;

  factory ApiInfo.fromJson(Map<String, dynamic> json) => ApiInfo(
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
  };
}

class AreaMetadatum {
  AreaMetadatum({
    required this.name,
    required this.labelLocation,
  });

  String name;
  LabelLocation labelLocation;

  factory AreaMetadatum.fromJson(Map<String, dynamic> json) => AreaMetadatum(
    name: json["name"],
    labelLocation: LabelLocation.fromJson(json["label_location"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "label_location": labelLocation.toJson(),
  };
}

class LabelLocation {
  LabelLocation({
    required this.latitude,
    required this.longitude,
  });

  double latitude;
  double longitude;

  factory LabelLocation.fromJson(Map<String, dynamic> json) => LabelLocation(
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}

class Item {
  Item({
    required this.updateTimestamp,
    required this.timestamp,
    required this.validPeriod,
    required this.forecasts,
  });

  DateTime updateTimestamp;
  DateTime timestamp;
  ValidPeriod validPeriod;
  List<ForecastElement> forecasts;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    updateTimestamp: DateTime.parse(json["update_timestamp"]),
    timestamp: DateTime.parse(json["timestamp"]),
    validPeriod: ValidPeriod.fromJson(json["valid_period"]),
    forecasts: List<ForecastElement>.from(json["forecasts"].map((x) => ForecastElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "update_timestamp": updateTimestamp.toIso8601String(),
    "timestamp": timestamp.toIso8601String(),
    "valid_period": validPeriod.toJson(),
    "forecasts": List<dynamic>.from(forecasts.map((x) => x.toJson())),
  };
}

class ForecastElement {
  ForecastElement({
    required this.area,
    required this.forecast,
  });

  String area;
  String forecast;

  factory ForecastElement.fromJson(Map<String, dynamic> json) => ForecastElement(
    area: json["area"],
    forecast: json["forecast"],
  );

  Map<String, dynamic> toJson() => {
    "area": area,
    "forecast": forecast,
  };
}


class ValidPeriod {
  ValidPeriod({
    required this.start,
    required this.end,
  });

  DateTime start;
  DateTime end;

  factory ValidPeriod.fromJson(Map<String, dynamic> json) => ValidPeriod(
    start: DateTime.parse(json["start"]),
    end: DateTime.parse(json["end"]),
  );

  Map<String, dynamic> toJson() => {
    "start": start.toIso8601String(),
    "end": end.toIso8601String(),
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
