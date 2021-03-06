import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flutter_weather/keys.dart';

// todo: remove unused/unnecessary imports
// ignore: unused_import
import 'dart:developer';
// ignore: unused_import
import 'package:flutter/foundation.dart';

class City {
  // final int id;
  final String name;
  final int cityId;

  const City({
    // required this.id,
    required this.name,
    required this.cityId,
  });

  // representations
  @override
  String toString() {
    // return 'City{id: $id, name: $name, cityId: $cityId}';
    return 'City{name: $name, cityId: $cityId}';
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'name': name,
      'city_id': cityId,
    };
  }

  // methods
  // City copyWith({int? id, String? name, int? cityId}) {
  City copyWith({String? name, int? cityId}) {
    return City(
      // id: id ?? this.id,
      name: name ?? this.name,
      cityId: cityId ?? this.cityId,
    );
  }
}

/* DATABASE METHODS */
Future<Database> databaseGetOrCreate() async {
  // platform-specific boilerplate
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // avoid errors caused by flutter upgrade
  WidgetsFlutterBinding.ensureInitialized();

  // get or create database
  final db = openDatabase(
    path.join(await getDatabasesPath(), 'db.sqlite3'),
    onCreate: (database, version) {
      return database.execute(
        'CREATE TABLE cities('
          // 'id INTEGER PRIMARY KEY,'
          'name TEXT,'
          'city_id TEXT'
        ')',
      );
    },
    version: 1,
  );

  // if (kDebugMode) runExamples(db);

  return db;
}

// list
Future<List<City>> dbCityGetAll(Database db) async {
  // final db = await database;

  // query the table for all cities
  final List<Map<String, dynamic>> cities = await db.query('cities');

  // convert the List<Map<String>> into a List<City>
  return List.generate(cities.length, (i) => City(
    // id: cities[i]['id'],
    name: cities[i]['name'],
    cityId: int.parse(cities[i]['city_id']),
  ));
}

// create city
Future<void> dbCityCreate(Database db, City city) async {
  // add the city
  await db.insert(
    'cities',
    city.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}


// get city
Future<City?> dbCityGetByName(Database db, String name) async {
  final List cities = await dbCityGetAll(db);

  if (cities.where((city) => city.name == name).isEmpty) return null;
  return cities.where((city) => city.name == name).first;
}

Future<City?> dbCityGetByCityId(Database db, int cityId) async {
  final List cities = await dbCityGetAll(db);

  if (cities.where((city) => city.cityId == cityId).isEmpty) return null;
  return cities.where((city) => city.cityId == cityId).first;
}

// update city
Future<void> dbCityUpdate(Database db, City city) async {
  await db.update(
    'cities',
    city.toMap(),
    where: 'city_id = ?',
    whereArgs: [city.cityId],
  );
}


// delete city
Future<bool> dbCityDelete(Database db, City city) async {
  await db.delete(
    'cities',
    where: 'city_id = ?',
    whereArgs: [city.cityId],
  );

  // if (kDebugMode) {
  //   print("City '$cityName' removed from database");
  // }

  return true;
}


/* CityWeather */
class CityWeather {
  final int cityId;
  final String name;
  final int date;
  final String temp;
  final String description;
  final String feelsLike;
  final String windSpeed;
  final String windGust;
  final int windDirection;

  const CityWeather({
    required this.cityId,
    required this.name,
    required this.date,
    required this.temp,
    required this.feelsLike,
    required this.description,
    required this.windSpeed,
    required this.windGust,
    required this.windDirection,
  });

  factory CityWeather.fromJson(Map<String, dynamic> json) {
    final String windGust = json['wind']!['gust'] != null
        ? json['wind']['gust'].toStringAsFixed(1) : '0';
    return CityWeather(
      cityId: json['id'],
      name: json['name'],
      date: json['dt'],
      temp: json['main']['temp'].toStringAsFixed(1),
      feelsLike: json['main']['feels_like'].toStringAsFixed(1),
      description: json['weather'][0]['description'],
      windSpeed: json['wind']['speed'].toStringAsFixed(1),
      windGust: windGust,
      windDirection: json['wind']['deg'],
    );
  }
}

Future<CityWeather> weatherFetchByCityName(String cityName) async {
  // if (kDebugMode) print("Getting weather for '$cityName'...");

  final String weatherUrl = "https://api.openweathermap.org/data/2.5/weather/"
      "?q=$cityName&appId=$weatherApiKey&units=metric";

  // if (kDebugMode) print("Querying URL: $weatherUrl");

  final http.Response response = await http.get(Uri.parse(weatherUrl));
  return weatherGetFromResponse(response);
}

Future<CityWeather> weatherFetchByCityId(int cityId) async {
  // if (kDebugMode) print("Getting weather for city Id: $cityId...");

  final String weatherUrl = "https://api.openweathermap.org/data/2.5/weather/"
      "?id=$cityId&appId=$weatherApiKey&units=metric";

  // if (kDebugMode) print("Querying URL: $weatherUrl");

  final http.Response response = await http.get(Uri.parse(weatherUrl));
  return weatherGetFromResponse(response);
}

CityWeather weatherGetFromResponse(http.Response response) {
  if (response.statusCode != 200) {
    if (response.statusCode == 404) {
      throw Exception(
          "Error: Could not find a city with that name"
      );
    }

    throw Exception(
      "Error: ${response.reasonPhrase}"
    );
  }

  // decode json
  final decodedResponse = jsonDecode(response.body);
  assert(decodedResponse is Map);

  final cityWeather = CityWeather.fromJson(decodedResponse);
  return cityWeather;
}