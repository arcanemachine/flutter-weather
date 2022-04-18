import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class CityWeatherScreen extends StatelessWidget {
  const CityWeatherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text("Current Weather"),
    ),
    body: Center(
      child: Column(
        children: const <Widget>[
          Text("Insert weather here"),
        ],
      ),
    ),
  );
}