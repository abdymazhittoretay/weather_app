// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory("253a1d17598d32dfc6ce7159df4ae4ee");
  Weather? _weather;

  void _fetchWeather() async {
    final String cityName = await getCurrentCity();

    _wf.currentWeatherByCityName(cityName).then((w) {
      setState(() {
        _weather = w;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _fetchWeather();
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
            Text(_weather?.areaName ?? "Loading city..."),
            _weather?.areaName != null
                ? Column(
                    children: [
                      // future Weather Icons
                      Container(
                        height: MediaQuery.sizeOf(context).height * 0.2,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"))),
                      ),
                      Text(_weather?.weatherDescription ?? ""),
                      // after Weather Icons here need to add time of this location
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                          "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C"),
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  // Functions
  Future<String> getCurrentCity() async {
    // Checks permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Requests permission
      permission = await Geolocator.requestPermission();
    }

    // gets the current location
    Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
    ));

    // converts current location to placemarks
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    // selects city name from placemarks
    final String? city = placemarks[0].locality;

    // if variable city is null it will return ""
    return city ?? "";
  }
}
