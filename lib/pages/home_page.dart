// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String apiKey = dotenv.env['WEATHER_API_KEY'] ?? "";
  late final WeatherFactory _wf = WeatherFactory(apiKey);
  Weather? _weather;
  List<Weather>? _forecast;

  void getWeather(String cityName) async {
    _wf.currentWeatherByCityName(cityName).then((w) {
      setState(() {
        _weather = w;
      });
    }).catchError((e) {
      print(e);
    });

    await _wf.fiveDayForecastByCityName(cityName).then((w) {
      setState(() {
        _forecast = w;
      });
    }).catchError((e) {
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
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "${_weather?.date!.hour.toString().padLeft(2, "0")}:${_weather?.date!.minute.toString().padLeft(2, "0")}",
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
                color: Colors.white,
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: () => showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return openDialog(context);
          },
        ),
        child: Icon(Icons.search),
      ),
    );
  }

  Widget searchWidget(BuildContext context) {
    return TextField(
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
    );
  }

  Widget openDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      content: searchWidget(context),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text(
            'CANCEL',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text(
            'SEARCH',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              getWeather(_controller.text);
            });
            _controller.clear();
            Navigator.of(context).pop();
          },
        ),
      ],
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
