import 'package:flutter/material.dart';
import 'package:weather_app/weather_caller.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Geologica'),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherData? _weatherData;
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationWeather();
  }

  Future<void> _getCurrentLocationWeather() async {
    WeatherCaller weatherCaller = WeatherCaller();
    try {
      WeatherData weatherData = await weatherCaller.getCurrentLocationWeather();
      setState(() {
        _weatherData = weatherData;
        _isPermissionGranted = true;
      });
    } catch (e) {
      setState(() {
        _isPermissionGranted = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WeatherDisplay(
              weatherData: _weatherData ?? WeatherData.empty(),
              isPermissionGranted: _isPermissionGranted,
            ),
          ]),
    );
  }
}
