// ignore: unused_import
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flutter_weather/models.dart';
// import 'package:flutter_weather/helpers.dart';

Future<Database> databaseGetOrCreate() async {
  // platform-specific boilerplate
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit(); // initialize FFI
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
          'id INTEGER PRIMARY KEY,'
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

Future main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appTitle = "Flutter Weather";
  late List<City> _savedCityList = [];
  // late Database _db;

  // lifecycle
  @override
  void initState() {
    super.initState();

    savedCityListUpdate();
  }

  void savedCityListUpdate() {
    databaseGetOrCreate().then((database) {
      cityGetAll(database).then((savedCityList) {
        setState(() {
          _savedCityList = savedCityList;
        });
      });
    });
  }

  // widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      title: _appTitle,
      home: HomeView(
        title: _appTitle,
        // db: _db,
        savedCityList: _savedCityList,
        callback: savedCityListUpdate,
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key,
    required this.title,
    // required this.db,
    required this.savedCityList,
    required this.callback,
  }) : super(key: key);

  final String title;
  // final Database db;
  final List savedCityList;
  final Function callback;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: _drawer(),
      body: Center(
        child: _primaryWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { _showPopupCityAdd(context); },
        tooltip: "Add city",
        child: const Icon(Icons.add),
      ),
    );
  }

  // drawer
  Widget _drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Text(
                "Your Cities",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white
                ),
              ),
            ),
          ),
          widget.savedCityList.isEmpty
            ? ListTile(
                title: const Text(
                  "Add new city...",
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  _showPopupCityAdd(context);
              },
            )
            : ListTile(
                title: const Text("savedCityList goes here..."),
                onTap: () {
                // Navigator.pop(context);
                _showPopupCityAdd(context);
                },
            ),
        ],
      ),
    );
  }

  // primary widget
  Widget _primaryWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.savedCityList.isEmpty
          ? const Text("You have not added any cities.")
          : Text("You have added ${widget.savedCityList.length} cities."),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            child: const Text("Refresh City List"),
            onPressed: () { widget.callback(); },
          ),
        ),
      ],
    );
  }

  // add city
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textFieldController = TextEditingController();
  // String _textValue = "";

  // @override
  // void initState() {
  //   super.initState();

  //   _textFieldController.addListener(() {
  //     setState(() {
  //       _textValue = _textFieldController.text;
  //     });
  //   });
  // }

  @override
  void dispose() {
    _textFieldController.dispose();

    super.dispose();
  }


  Widget _cityAddForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            autofocus: true,
            controller: _textFieldController,
            decoration: const InputDecoration(
                hintText: "Enter city name..."
            ),
            onFieldSubmitted: (val) {
              _handleSubmit();
            },
            validator: (val) {
              if (val == "") return "Enter a city name";
              return null;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showPopupCityAdd(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New City"),
          content: _cityAddForm(),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: _handleSubmit,
              child: const Text("OK"),
            ),
          ],
        );
      }
    );
  }

  void _handleSubmit() {
    final cityName = _textFieldController.text;

    // validate the form
    if (!_formKey.currentState!.validate()) return;

    // reset the text field
    setState(() { _textFieldController.text = ""; });

    // hide the popup
    Navigator.of(context).pop();

    // add the city
    _cityAdd(cityName);
  }

  Future<void> _cityAdd(String cityName) async {
    // check if the city already exists in _cityListSaved
    for (var i = 0; i < widget.savedCityList.length; i++) {
      if (widget.savedCityList.contains(cityName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This city is already in your saved cities.")
          ),
        );
        return;
      }
    }

    try {
      // get weather for new city
      final CityWeather newCityWeather = await weatherFetchByCityName(cityName);

      // create object for new city
      final City newCity = City(
        // id: widget.savedCityList.length + 1,
        name: cityName,
        cityId: newCityWeather.cityId,
      );

      dbCityCreate(widget.db, newCity);

    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(err.toString()),
        ),
      );
    }
  }
}