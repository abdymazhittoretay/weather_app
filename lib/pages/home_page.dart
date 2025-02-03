// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/widgets/forecast_info.dart';
import 'package:weather_app/widgets/weather_info.dart';

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
      Map<String, Weather> uniqueDays = {};
      for (var weather in w) {
        String key = weather.date.toString().split(" ")[0];
        if (!uniqueDays.containsKey(key) &&
            key != _weather?.date.toString().split(" ")[0]) {
          uniqueDays[key] = weather;
        }
      }
      setState(() {
        _forecast = uniqueDays.values.toList();
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
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    WeatherInfo(weather: _weather!),
                    SizedBox(
                      height: 20.0,
                    ),
                    _forecast != null
                        ? SizedBox(
                            width: MediaQuery.sizeOf(context).width,
                            height: 200,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _forecast!.length,
                                itemBuilder: (context, index) {
                                  Weather day = _forecast![index];
                                  return ForecastInfo(weather: day);
                                }),
                          )
                        : SizedBox(),
                  ],
                ),
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
