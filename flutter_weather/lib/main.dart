import 'package:flutter/material.dart';
import 'package:flutter_weather/city_weather.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_weather/state.dart';
import 'package:flutter_weather/home.dart';

// todo: remove unused/unnecessary imports
// ignore: unused_import
import 'dart:developer';
// ignore: unused_import, unnecessary_import
import 'package:flutter/foundation.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // widget
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(
          create: (_) => AppState(),
          lazy: false,
        ),
        Provider<AppRouter>(
          lazy: false,
          create: (_) => AppRouter(),
        ),
      ],
      child: Builder(
        builder: (BuildContext context) {
          final router = Provider.of<AppRouter>(context, listen: false).router;
          return MaterialApp.router(
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
            debugShowCheckedModeBanner: false,
            title: "Flutter Weather",
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
          );
        }
      ),
    );
  }
}

class AppRouter {
  late final router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
      ),
      GoRoute(
        path: '/weather',
        builder: (BuildContext context, GoRouterState state) =>
          const CityWeatherScreen(),
      ),
    ],
  );
}