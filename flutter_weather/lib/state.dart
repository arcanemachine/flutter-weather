import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_weather/models.dart';

class AppState with ChangeNotifier {
  // db
  Future<Database> get db async => await databaseGetOrCreate();

  // savedCityList
  List<City> savedCityList = [];

  Future<void> savedCityListUpdate() async {
    // savedCityList = [];

    dbCityGetAll(await db).then((dbSavedCityList) {
      savedCityList = dbSavedCityList;

      // if (kDebugMode) {
      //   print(savedCityList);
      // }
    });

    notifyListeners();
  }

  // currentCityId
  late int? currentCityId;
  void currentCityIdSet(cityId) {
    currentCityId = cityId;

    // update weather for current city
    currentCityWeatherUpdateById(cityId);
  }

  // currentCityWeather
  late CityWeather currentCityWeather;
  Future<void> currentCityWeatherUpdateById(cityId) async {
    currentCityWeather = await weatherFetchByCityId(cityId);
  }
}