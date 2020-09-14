import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uber_clone/screens/home.dart';
import 'package:uber_clone/screens/intro_screen.dart';
import 'package:uber_clone/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  runApp(MyApp(_prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences preferences;

  MyApp(this.preferences);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'uber clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _renderInitialRoute(),
    );
  }

  Widget _renderInitialRoute() {
    int state =
        preferences.getInt(Constants.APP_STATE) ?? Constants.FIRST_TIME_INTRO;
    switch (state) {
      case Constants.LOGGED_IN:
        return MyHomePage(title: Constants.APP_NAME);
    }

    if (state == Constants.FIRST_TIME_INTRO) {
      setAppState(Constants.LOGGED_IN);
      return IntroScreen();
    }
    return IntroScreen();
  }

  setAppState(int appState) async {
    await preferences.setInt(Constants.APP_STATE, appState);
  }
}
