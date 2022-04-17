import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_weather/state.dart';

class CityList extends StatelessWidget {
  const CityList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: ListView.builder(
        itemCount: context.watch<AppState>().savedCityList.length,
        itemBuilder: (BuildContext context, int i) {
          return ListTile(
            title: Text(
              context.watch<AppState>().savedCityList[i].name,
              textAlign: TextAlign.center,
            ),
            onTap: () {
              // todo: Create window for item
            },
          );
        },
        shrinkWrap: true,
      ),
    );
  }
}