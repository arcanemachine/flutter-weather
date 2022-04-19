import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:flutter_weather/state.dart';


class CityWeatherScreen extends StatelessWidget {
  const CityWeatherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<AppState>().currentCityWeather;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text("Current Weather: ${weather.name}"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(weather.name, style: const TextStyle(fontSize: 24.0)),
                  _weatherItem("Current Weather"),
                  _sectionHeader("Main"),
                  _weatherItem("Temperature:  ${weather.temp}\u00B0 C"),
                  _weatherItem("Feels Like:  ${weather.feelsLike}\u00B0 C"),
                  _weatherItem("Conditions:  ${weather.description}"),
                  _sectionHeader("Wind"),
                  _weatherItem("Speed:  ${weather.windSpeed} km/h"),
                  _weatherItem("Gusts:  ${weather.windGust} km/h"),
                  _windDirection(weather.windDirection),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Updated on: ${
                DateTime.fromMillisecondsSinceEpoch(weather.date * 1000)
              }"),
            ),
          ),
        ],
      ),
    );
  }

  // widgets
  Widget _paddedText(String text, double padding, {double fontSize=14.0}) {
    return Padding(
      padding: EdgeInsets.all(padding,),
      child: Text(text, style: TextStyle(fontSize: fontSize)),
    );
  }

  Widget _sectionHeader(String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 20),
        _paddedText(title, 8.0, fontSize: 20.0),
      ],
    );
  }

  Widget _weatherItem(String content) {
    return _paddedText(content, 6.0);
  }

  Widget _windDirection(int direction) {
    late final String directionString;

    if (direction >= 348.75 || direction < 33.75) {
      directionString = "N";
    } else if (direction >= 33.75 && direction < 78.75) {
      directionString = "NE";
    } else if (direction >= 78.75 && direction < 123.75) {
      directionString = "E";
    } else if (direction >= 123.75 && direction < 168.75) {
      directionString = "SE";
    } else if (direction >= 168.75 && direction < 213.75) {
      directionString = "S";
    } else if (direction >= 213.75 && direction < 258.75) {
      directionString = "SW";
    } else if (direction >= 258.75 && direction < 303.75) {
      directionString = "W";
    } else if (direction >= 303.75 && direction < 348.75) {
      directionString = "NW";
    } else {
      directionString = "???";
    }

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Direction: $directionString",
            style: const TextStyle(fontSize: 14.0)
          ),
          Transform.rotate(
            angle: direction.toDouble() * (3.14 / 180),
            // angle: 3.0,
            child: const Icon(Icons.arrow_upward),
          ),
          Text("($direction\u00B0)"),
        ],
      )
    );
  }
}