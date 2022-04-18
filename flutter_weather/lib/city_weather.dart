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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Current Weather: ${weather.name}"),
            const SizedBox(height: 16),
            Text("Temperature: ${weather.temp} degrees C"),
            Text("Conditions: ${weather.description}"),
            Text("Feels Like: ${weather.feelsLike} degrees C"),
            const SizedBox(height: 16),
            Text("Updated on: ${
              DateTime.fromMillisecondsSinceEpoch(weather.date * 1000)
            }"),
          ],
        ),
      ),
    );
  }
}