import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_weather/state.dart';
import 'package:flutter_weather/home.dart';

// todo: remove unused/unnecessary imports
// ignore: unused_import
import 'dart:developer';
// ignore: unused_import, unnecessary_import
import 'package:flutter/foundation.dart';


Future main() async {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // widget
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        title: "Flutter Weather",
        home: const HomeView(),
      )
    );
  }
}

