import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class WeatherCaller {
  Future<WeatherData> getCurrentLocationWeather() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition();
      double latitude = position.latitude;
      double longitude = position.longitude;

      final queryParameters = {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'appid': '241241c7fdc1e826df470810ac913d06',
      };

      final uri = Uri.https(
        'api.openweathermap.org',
        '/data/2.5/weather',
        queryParameters,
      );

      final response = await http.get(uri);
      final weatherData = WeatherData.fromJson(jsonDecode(response.body));
      return weatherData;
    } else {
      throw Exception('Location permission not granted');
    }
  }
}

class WeatherData {
  final double temperature;
  final String description;
  final String iconCode;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final mainData = json['main'];
    final weather = json['weather'][0];
    final temperature = mainData['temp'];
    final description = weather['description'];
    final iconCode = weather['icon'];
    return WeatherData(
      temperature: temperature - 273.15,
      description: _capitalizeFirstLetter(description.toString()),
      iconCode: iconCode.toString(),
    );
  }

  factory WeatherData.empty() {
    return WeatherData(
      temperature: 0,
      description: '',
      iconCode: '',
    );
  }

  static String _capitalizeFirstLetter(String text) {
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
}

class WeatherDisplay extends StatelessWidget {
  final WeatherData weatherData;
  final bool isPermissionGranted;

  const WeatherDisplay({
    Key? key,
    required this.weatherData,
    required this.isPermissionGranted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isPermissionGranted) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Text(
              'No permissions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),
              textAlign: TextAlign.center,
            ),
          ]);
    }

    return Column(
      children: [
        Image.network(
          'https://openweathermap.org/img/w/${weatherData.iconCode}.png',
        ),
        const SizedBox(height: 20),
        Text(
          '${weatherData.temperature.toStringAsFixed(2)}°C',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w200),
        ),
        Text(
          weatherData.description,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w200),
        ),
      ],
    );
  }
}
