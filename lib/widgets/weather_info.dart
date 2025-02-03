// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class WeatherInfo extends StatelessWidget {
  final Weather weather;

  const WeatherInfo({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                        
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          weather.areaName ?? "",
                          style: TextStyle(color: Colors.white, fontSize: 24.0),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(weather.date.toString().split(" ")[0],
                            style: TextStyle(color: Colors.white)),
                        Text(
                          "${weather.date!.hour.toString().padLeft(2, "0")}:${weather.date!.minute.toString().padLeft(2, "0")}",
                          style: TextStyle(color: Colors.white, fontSize: 24.0),
                        ),
                        // future Weather Icons
                        Container(
                          height: MediaQuery.sizeOf(context).height * 0.2,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(
                                      "http://openweathermap.org/img/wn/${weather.weatherIcon}@4x.png"))),
                        ),
                        Text(
                          "${weather.temperature?.celsius?.toStringAsFixed(0)}°C",
                          style: TextStyle(color: Colors.white, fontSize: 24.0),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          weather.weatherDescription ?? "",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                        Text(
                            "Max.: ${weather.tempMax?.celsius?.toStringAsFixed(0)},  Min.: ${weather.tempMin?.celsius?.toStringAsFixed(0)}",
                            style: TextStyle(color: Colors.white, fontSize: 14.0)),
                      ],
                    );
  }
}