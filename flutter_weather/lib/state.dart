import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_weather/models.dart';

class AppState with ChangeNotifier {
  // db
  Future<Database> get db async => await databaseGetOrCreate();

  // savedCityList
  List<City> _savedCityList = [];
  List<City> get savedCityList => _savedCityList;

  void savedCityListUpdate() async {
    dbCityGetAll(await db).then((savedCityList) {
      _savedCityList = savedCityList;

      if (kDebugMode) {
        print(_savedCityList);
      }
    });

    notifyListeners();
  }
}