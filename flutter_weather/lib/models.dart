import 'package:sqflite/sqflite.dart';

class City {
  final int id;
  final String name;
  final String cityId;

  const City({
    required this.id,
    required this.name,
    required this.cityId,
  });

  // representations
  @override
  String toString() {
    return 'City{id: $id, name: $name, cityId: $cityId}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city_id': cityId,
    };
  }

  // methods
  City copyWith({int? id, String? name, String? cityId}) {
    return City(
      id: id ?? this.id,
      name: name ?? this.name,
      cityId: cityId ?? this.cityId,
    );
  }
}

// setter-like methods
City cityUpdateId(City city, int id) {
  return City(
      id: id,
      name: city.name,
      cityId: city.cityId,
  );
}

City cityUpdateName(City city, String name) {
  return City(
      id: city.id,
      name: name,
      cityId: city.cityId,
  );
}

City cityUpdateCityId(City city, String cityId) {
  return City(
    id: city.id,
    name: city.name,
    cityId: cityId,
  );
}


/* CITY DATABASE METHODS */
// list
Future<List<City>> cityGetAll(db) async {
  // final db = await database;

  // query the table for all cities
  final List<Map<String, dynamic>> maps = await db.query('cities');

  // convert the List<Map<String>> into a List<City>
  return List.generate(maps.length, (i) => City(
    id: maps[i]['id'],
    name: maps[i]['name'],
    cityId: maps[i]['city_id'],
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
Future<City> cityGetById(List<City> cities, int id) async {
  return cities.where((city) => city.id == id).first;
}

Future<City> cityGetByName(List<City> cities, String name) async {
  return cities.where((city) => city.name == name).first;
}

Future<City> cityGetByCityId(List<City> cities, String cityId) async {
  return cities.where((city) => city.cityId == cityId).first;
}

// update city
Future<void> cityUpdate(db, City city) async {
  // final db = await database;

  await db.update(
    'cities',
    city.toMap(),
    where: 'id = ?',
    whereArgs: [city.id],
  );
}


// delete city
Future<void> cityDelete(db, int id) async {
  // final db = await database;

  await db.delete(
    'cities',
    where: 'id = ?',
    whereArgs: [id],
  );
}