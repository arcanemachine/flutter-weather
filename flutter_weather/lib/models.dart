import 'dart:convert';
// ignore: unused_import
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'package:flutter_weather/keys.dart';

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
// list
Future<List<City>> cityGetAll(db) async {
  // final db = await database;

  // query the table for all cities
  final List<Map<String, dynamic>> cities = await db.query('cities');

  // convert the List<Map<String>> into a List<City>
  return List.generate(cities.length, (i) => City(
    // id: cities[i]['id'],
    name: cities[i]['name'],
    cityId: cities[i]['city_id'],
  ));
}

// create city
Future<void> cityCreate(db, City city) async {
  // final db = await database;

  await db.insert(
    'cities',
    city.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}


// get city
Future<City> cityGetByName(List<City> cities, String name) async {
  return cities.where((city) => city.name == name).first;
}

Future<City> cityGetByCityId(List<City> cities, int cityId) async {
  return cities.where((city) => city.cityId == cityId).first;
}

// update city
Future<void> cityUpdate(db, City city) async {
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
Future<void> cityDelete(db, City city) async {
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