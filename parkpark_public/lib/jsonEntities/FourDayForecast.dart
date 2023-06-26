// To parse this JSON data, do
//
//     final fourDayWeatherForecast = fourDayWeatherForecastFromJson(jsonString);

import 'dart:convert';

FourDayWeatherForecast fourDayWeatherForecastFromJson(String str) => FourDayWeatherForecast.fromJson(json.decode(str));

String fourDayWeatherForecastToJson(FourDayWeatherForecast data) => json.encode(data.toJson());

class FourDayWeatherForecast {
  FourDayWeatherForecast({
    required this.apiInfo,
    required this.items,
  });

  ApiInfo apiInfo;
  List<Item> items;

  factory FourDayWeatherForecast.fromJson(Map<String, dynamic> json) => FourDayWeatherForecast(
    apiInfo: ApiInfo.fromJson(json["api_info"]),
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "api_info": apiInfo.toJson(),
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
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

class Item {
  Item({
    required this.updateTimestamp,
    required this.timestamp,
    required this.forecasts,
  });

  DateTime updateTimestamp;
  DateTime timestamp;
  List<Forecast> forecasts;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    updateTimestamp: DateTime.parse(json["update_timestamp"]),
    timestamp: DateTime.parse(json["timestamp"]),
    forecasts: List<Forecast>.from(json["forecasts"].map((x) => Forecast.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "update_timestamp": updateTimestamp.toIso8601String(),
    "timestamp": timestamp.toIso8601String(),
    "forecasts": List<dynamic>.from(forecasts.map((x) => x.toJson())),
  };
}

class Forecast {
  Forecast({
    required this.date,
    required this.timestamp,
    required this.forecast,
    required this.relativeHumidity,
    required this.temperature,
    required this.wind,
  });

  String date;
  DateTime timestamp;
  String forecast;
  HighAndLows relativeHumidity;
  HighAndLows temperature;
  Wind wind;

  factory Forecast.fromJson(Map<String, dynamic> json) => Forecast(
    date: json["date"],
    timestamp: DateTime.parse(json["timestamp"]),
    forecast: json["forecast"],
    relativeHumidity: HighAndLows.fromJson(json["relative_humidity"]),
    temperature: HighAndLows.fromJson(json["temperature"]),
    wind: Wind.fromJson(json["wind"]),
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "timestamp": timestamp.toIso8601String(),
    "forecast": forecast,
    "relative_humidity": relativeHumidity.toJson(),
    "temperature": temperature.toJson(),
    "wind": wind.toJson(),
  };
}

class HighAndLows {
  HighAndLows({
    required this.low,
    required this.high,
  });

  int low;
  int high;

  factory HighAndLows.fromJson(Map<String, dynamic> json) => HighAndLows(
    low: json["low"],
    high: json["high"],
  );

  Map<String, dynamic> toJson() => {
    "low": low,
    "high": high,
  };
}

class Wind {
  Wind({
    required this.speed,
    required this.direction,
  });

  HighAndLows speed;
  String direction;

  factory Wind.fromJson(Map<String, dynamic> json) => Wind(
    speed: HighAndLows.fromJson(json["speed"]),
    direction: json["direction"],
  );

  Map<String, dynamic> toJson() => {
    "speed": speed.toJson(),
    "direction": direction,
  };
}