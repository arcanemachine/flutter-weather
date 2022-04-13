import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:p05_weather_app/models.dart';

Future<void> runExamples(database) async {
  Database db = await database;

  // list cities
  if (kDebugMode) {
    print("Listing cities...");
    print("cityGetAll: ${await cityGetAll(db)}");
  }

  // create city
  City exampleCity = const City(
    id: 0,
    name: "Edmonton",
    cityId: 'abc',
  );

  if (kDebugMode) {
    print("Creating city...");
    await cityCreate(db, exampleCity);

    print("cityGetAll: ${await cityGetAll(db)}");
  }

  // example: get city
  if (kDebugMode) {
    List<City> cities = await cityGetAll(db);

    print("Getting city by ID...");
    print("cityGet: ${await cityGetById(cities, 0)}");

    print("Getting city by name...");
    print("cityGet: ${await cityGetByName(cities, 'Edmonton')}");

    print("Getting city by city ID...");
    print("cityGet: ${await cityGetByCityId(cities, 'abc')}");
  }

  if (kDebugMode) {
    print("Updating city...");
    exampleCity = exampleCity.copyWith(name: "Super Edmonton");
    cityUpdate(db, exampleCity);

    print("cityGetAll: ${await cityGetAll(db)}");
  }

  // example: delete city
  if (kDebugMode) {
    print("Deleting city...");
    cityDelete(db, exampleCity.id);
    print("cityGetAll: ${await cityGetAll(db)}");
  }

  // example: delete database
  if (kDebugMode) {
    print("Deleting database...");
    deleteDatabase(join(await getDatabasesPath(), 'db.sqlite3'));
  }

}