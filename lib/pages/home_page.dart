// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService _weatherService =
      WeatherService(apiKey: "253a1d17598d32dfc6ce7159df4ae4ee");
  Weather? _weather;

  void _fetchWeather() async {
    final String cityName = await _weatherService.getCurrentCity();

    try {
      final Weather weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _fetchWeather();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 242, 248),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(_weather?.cityName ?? "Loading city..."),
            _weather?.temperature != null
                ? Column(
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      // future Weather Icons
                      Icon(
                        Icons.space_bar_sharp,
                        size: 40.0,
                      ),
                      // after Weather Icons here need to add time of this location
                      SizedBox(
                        height: 20.0,
                      ),
                      Text("${_weather?.temperature.round()}°C"),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(_weather?.mainCondition ?? "")
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
