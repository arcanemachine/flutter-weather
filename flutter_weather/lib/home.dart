import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:flutter_weather/drawer.dart';
import 'package:flutter_weather/models.dart';
import 'package:flutter_weather/state.dart';

// todo: remove unused/unnecessary imports
// ignore: unused_import
import 'dart:developer';
// ignore: unused_import, unnecessary_import
import 'package:flutter/foundation.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textFieldController = TextEditingController();

  late final AppState state;

  @override
  void initState() {
    super.initState();

    state = context.read<AppState>();
    state.savedCityListUpdate(); // get saved city list
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
          ? const Center(child: Text("Click the blue '+' icon to add a city."))
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
    late String resultMessage;
    try {
      // ensure this city exists by attempting to get its current weather
      final CityWeather newCityWeather = await weatherFetchByCityName(cityName);

      // create city object
      final City newCity = City(
        name: cityName,
        cityId: newCityWeather.cityId,
      );

      // ensure the city is not already in the database
      if (await dbCityGetByCityId(await state.db, newCity.cityId) != null) {
        throw Exception("This city is already in the list.");
      }

      // add city to the database
      dbCityCreate(await state.db, newCity);
      resultMessage = "New city added: $cityName";
      context.read<AppState>().savedCityListUpdate(); // refresh the city list
    } catch (e) {
      resultMessage = e.toString().substring(11);
    }

    // show resultMessage in snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultMessage),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}

class CityList extends StatelessWidget {
  const CityList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Padding(
      padding: const EdgeInsets.all(0),
      child: state.savedCityList.isEmpty
        ? const Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Text(
              "Click the blue '+' icon to add a city.",
              textAlign: TextAlign.center,
            )
          )
        : ListView.builder(
        itemCount: state.savedCityList.length,
        itemBuilder: (BuildContext context, int i) {
          return ListTile(
            title: Text(
              state.savedCityList[i].name,
              textAlign: TextAlign.center,
            ),
            onTap: () {
              // view current weather
              state.currentCityWeatherUpdateById(state.savedCityList[i].cityId)
                   .then((placeholderVar) {
                context.push('/weather');
              });
            },
            onLongPress: () => showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text("Remove City"),
                content: Text(
                  "Remove '${state.savedCityList[i].name}' from the list?"
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context, "Cancel"),
                  ),
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      databaseGetOrCreate().then((database) {
                        // delete the city
                        dbCityDelete(database, state.savedCityList[i]);
                        state.savedCityListUpdate();
                        Navigator.pop(context, "OK");

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("City deleted"),
                            action: SnackBarAction(
                              label: 'OK',
                              onPressed: () {},
                            ),
                          ),
                        );
                      });
                    }
                  ),
                ],
              )
            ),
          );
        },
        shrinkWrap: true,
      ),
    );
  }
}
