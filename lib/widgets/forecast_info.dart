// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class ForecastInfo extends StatelessWidget {
  final Weather weather;

  const ForecastInfo({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10.0),
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[900],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(weather.date.toString().split(" ")[0],
              style: TextStyle(color: Colors.white, fontSize: 14.0)),
          Image.network(
            "http://openweathermap.org/img/wn/${weather.weatherIcon}@4x.png",
            height: 50,
            width: 50,
          ),
          Text(
            "${weather.temperature?.celsius?.toStringAsFixed(0)}°C",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 5.0),
          Text(weather.weatherDescription.toString(),
              style: TextStyle(color: Colors.white, fontSize: 14.0)),
          Text(
              "Max.: ${weather.tempMax?.celsius?.toStringAsFixed(0)},  Min.: ${weather.tempMin?.celsius?.toStringAsFixed(0)}",
              style: TextStyle(color: Colors.white, fontSize: 14.0)),
        ],
      ),
    );
  }
}
