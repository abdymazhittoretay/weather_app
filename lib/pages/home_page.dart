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

  void getWeather(String cityName) {
    _wf.currentWeatherByCityName(cityName).then((w) {
      setState(() {
        _weather = w;
      });
    }).catchError((e){
      print(e);
    });
  }

  void _fetchWeather() async {
    final String cityName = await getCurrentCity();
    getWeather(cityName);
  }

  @override
  void initState() {
    super.initState();

    _fetchWeather();
  }

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _weather != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  searchWidget(context),
                  SizedBox(
                    height: 20.0,
                  ),
                  Column(
                    children: [],
                  ),
                  Icon(
                    Icons.location_on,
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    _weather?.areaName ?? "",
                    style: TextStyle(color: Colors.white, fontSize: 24.0),
                  ),
                  // future Weather Icons
                  Container(
                    height: MediaQuery.sizeOf(context).height * 0.2,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"))),
                  ),
                  Text(
                    "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C",
                    style: TextStyle(color: Colors.white, fontSize: 24.0),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    _weather?.weatherDescription ?? "",
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  Text(
                      "Max.: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)},  Min.: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}",
                      style: TextStyle(color: Colors.white, fontSize: 14.0)),
                ],
              )
            : CircularProgressIndicator(
                color: Colors.black,
              ),
      ),
    );
  }

  Widget searchWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        onSubmitted: (value) {
          setState(() {
            getWeather(_controller.text);
          });
        },
        controller: _controller,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
            hintText: "Enter city name",
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(10.0)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0))),
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
