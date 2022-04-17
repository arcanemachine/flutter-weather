// ignore: unused_import
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_weather/models.dart';

Future main() async {
  runApp(const MyApp());
}

class MyViewModel with ChangeNotifier {
  // db
  Future<Database> get db async => await databaseGetOrCreate(); // get

  // savedCityList
  late List<City> _savedCityList = [];
  List<City> get savedCityList => _savedCityList; // get
  void savedCityListUpdate() { // update
    dbCityGetAll(db).then((savedCityList) {
      _savedCityList = savedCityList;
    });
  }

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // widget
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        title: "Flutter Weather",
        home: const HomeView(),
      )
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
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
          context.read<MyViewModel>().savedCityList.isEmpty
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
    final List savedCityList = context.read<MyViewModel>().savedCityList;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        context.read<MyViewModel>().savedCityList.isEmpty
          ? const Text("You have not added any cities.")
          : Text("You have added ${savedCityList.length} cities."),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            child: const Text("Refresh City List"),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

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
    final List savedCityList = context.read<MyViewModel>().savedCityList;

    // check if the city already exists in _cityListSaved
    for (var i = 0; i < savedCityList.length; i++) {
      if (savedCityList.contains(cityName)) {
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

      // dbCityCreate(widget.db, newCity);

    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(err.toString()),
        ),
      );
    }
  }
}