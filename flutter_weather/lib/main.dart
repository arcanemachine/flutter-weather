import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// import 'package:flutter_weather/examples.dart';
import 'package:flutter_weather/models.dart';
import 'package:flutter_weather/keys.dart';
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
  late List<City> _cityList = [];

  // lifecycle
  @override
  void initState() {
    super.initState();

    databaseGetOrCreate().then((database) {
      cityGetAll(database).then((cityList) {
        setState(() {
          _cityList = cityList;
        });
      });
    });
  }

  // widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      title: _appTitle,
      home: HomeView(
        title: _appTitle,
        cityList: _cityList,
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({
    Key? key,
    required this.title,
    required this.cityList,
  }) : super(key: key);

  final String title;
  final List<City> cityList;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
                style: TextStyle(
                    fontSize: 24.0,
                    color: Colors.white
                ),
              ),
            ),
          ),
          widget.cityList.isEmpty
            ? ListTile(
              title: const Text(
                "Add new city...",
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CityAdd()
                  ),
                );
              },
            )
            : ListTile(
              title: const Text("City List"),
              onTap: () {
                // Navigator.pop(context);
              }
            ),
          ],
      ),
    );
  }

  Widget _primaryWidget() {
    return widget.cityList.isEmpty
      ? const Text("You have not added any cities.")
      : Text("You have added ${widget.cityList.length} cities.");
  }

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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CityAdd(),
            ),
          );
        },
        tooltip: "Add city",
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CityAdd extends StatefulWidget {
  const CityAdd({Key? key}) : super(key: key);

  @override
  State<CityAdd> createState() => _CityAddState();
}

class _CityAddState extends State<CityAdd> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // city_list
  Future<String> get _cityList async {
    final Directory appDocsDirectory = await getApplicationDocumentsDirectory();
    final cityListPath = path.join('$appDocsDirectory/city_list.json.gz');
    final fileCompressed = File(cityListPath);

    // if (await fileCompressed.exists()) {
    //   if (kDebugMode) print("Found city_list.json.gz");
    // } else {
    //   if (kDebugMode) print("city_list.json.gz not found.");
    // }

    // todo: if file doesn't exist, then download it

    // final decodedFile = base64Decode(fileCompressed.toString());
    final Uint8List uint8list = await fileCompressed.readAsBytes();
    final List<int> cityListJson = gzip.decode(uint8list);

    // return cityListJson.substring(0, 100);
    return "";
  }

  // form
  Future<void> _handleSubmit() async {
    if (kDebugMode) {
      print("Form submitted.");
    }
    print(await _cityList);
  }

  Widget _formSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Row(
          children: <Widget>[
            Flexible(child: TextFormField(
              decoration: const InputDecoration(
                hintText: "Enter a city name...",
              ),
              autofocus: true,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Enter a city name.";
                }
                return null;
              },
              onFieldSubmitted: (val) => _handleSubmit(),
            )),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: ElevatedButton(
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.search),
                ),
                onPressed: _handleSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New City")),
      body: Column(
        children: <Widget>[
          _formSection(),
        ],
      ),
    );
  }
}