import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_weather/city_list.dart';
import 'package:flutter_weather/drawer.dart';
import 'package:flutter_weather/models.dart';
import 'package:flutter_weather/state.dart';

// todo: remove unused/unnecessary imports
// ignore: unused_import
import 'dart:developer';
// ignore: unused_import, unnecessary_import
import 'package:flutter/foundation.dart';


class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textFieldController = TextEditingController();

  late Database db;

  @override
  void initState() {
    super.initState();

    databaseGetOrCreate().then((database) { db = database; }); // get database
    context.read<AppState>().savedCityListUpdate(); // get saved city list
  }

  @override
  void dispose() {
    _textFieldController.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: const MyDrawer(),
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

  // primary widget
  Widget _primaryWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: context.watch<AppState>().savedCityList.isEmpty
          ? const Text("")
          : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  "Select a City:",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 16.0,
                ),
                CityList(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            child: const Text("Refresh City List"),
            onPressed: () { context.read<AppState>().savedCityListUpdate(); },
          ),
        ),
      ],
    );
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

    if (!_formKey.currentState!.validate()) return; // validate the form
    setState(() { _textFieldController.text = ""; }); // reset the text field
    Navigator.of(context).pop(); // hide the popup
    _cityAdd(cityName); // add the city
  }

  Future<void> _cityAdd(String cityName) async {
    final Database db = await context.read<AppState>().db;
    final List savedCityList = context.read<AppState>().savedCityList;

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

    late String resultMessage;
    try {
      // get weather for new city (to ensure the city exists
      final CityWeather newCityWeather = await weatherFetchByCityName(cityName);

      // create object for new city
      final City newCity = City(
        // id: widget.savedCityList.length + 1,
        name: cityName,
        cityId: newCityWeather.cityId,
      );

      dbCityCreate(db, newCity); // add city to database
      context.read<AppState>().savedCityListUpdate(); // refresh the city list
      resultMessage = "New city added: $cityName";
    } catch (err) {
      resultMessage = err.toString();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultMessage.toString()),
      ),
    );
  }
}
