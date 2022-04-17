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
  }
  databaseFactory = databaseFactoryFfi;

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

  // if (kDebugMode) {
  //   runExamples(db);
  // }

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
  // final db = await database;

  await db.insert(
    'cities',
    city.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  if (kDebugMode) {
    print("New city added to database: ${city.name}");
  }
}


// get city
Future<City> dbCityGetByName(List<City> cities, String name) async {
  return cities.where((city) => city.name == name).first;
}

Future<City> dbCityGetByCityId(List<City> cities, int cityId) async {
  return cities.where((city) => city.cityId == cityId).first;
}

// update city
Future<void> dbCityUpdate(Database db, City city) async {
  // final db = await database;

  await db.update(
    'cities',
    city.toMap(),
    // where: 'id = ?',
    where: 'city_id = ?',
    // whereArgs: [id],
    whereArgs: [city.cityId],
  );
}


// delete city
Future<void> dbCityDelete(Database db, City city) async {
  // final db = await database;

  await db.delete(
    'cities',
    // where: 'id = ?',
    where: 'city_id = ?',
    // whereArgs: [id],
    whereArgs: [city.cityId],
  );
}


/* CityWeather */
class CityWeather {
  final int cityId;
  final double temp;

  const CityWeather({
    required this.cityId,
    required this.temp,
  });

  factory CityWeather.fromJson(Map<String, dynamic> json) {
    return CityWeather(
      cityId: json['weather'][0]['id'],
      temp: json['main']['temp'],
    );
  }
}

Future<CityWeather> weatherFetchByCityName(String cityName) async {
  /* return a JSON object containing the fetched weather */

  final String weatherUrl = "https://api.openweathermap.org/data/2.5/weather/"
      "?q=$cityName&appId=$weatherApiKey&units=metric";
  final http.Response response = await http.get(Uri.parse(weatherUrl));

  return weatherGetFromResponse(response);
}

Future<CityWeather> weatherFetchByCityId(int cityId) async {
  /* return a JSON object containing the fetched weather */

  final String weatherUrl = "https://api.openweathermap.org/data/2.5/weather/"
      "?id=$cityId&appId=$weatherApiKey&units=metric";
  final http.Response response = await http.get(Uri.parse(weatherUrl));

  return weatherGetFromResponse(response);
}

CityWeather weatherGetFromResponse(http.Response response) {
  if (response.statusCode != 200) {
    throw Exception(
      "Error received: ${response.statusCode} (${response.reasonPhrase})"
    );
  }

  // decode json
  final decodedResponse = jsonDecode(response.body);
  assert(decodedResponse is Map);

  final cityWeather = CityWeather.fromJson(decodedResponse);
  return cityWeather;
}