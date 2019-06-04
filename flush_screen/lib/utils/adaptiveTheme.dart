import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

final _androidTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  accentColor: Colors.deepPurple,
  buttonColor: Colors.deepPurple,
);

final _iOSTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.lime,
    accentColor: Colors.blueGrey,
    buttonColor: Colors.blueGrey,
    appBarTheme: AppBarTheme(elevation: 0.0));
ThemeData getAdaptiveTheme(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.iOS ? _iOSTheme : _androidTheme;
}

class AdaptiveProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? CupertinoActivityIndicator()
        : CircularProgressIndicator();
  }
}
