import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:flutter_weather/state.dart';


class CityWeatherScreen extends StatelessWidget {
  const CityWeatherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text("Current Weather"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Current weather: ${state.currentCityWeather.temp} degrees C"),
          ],
        ),
      ),
    );
  }
}