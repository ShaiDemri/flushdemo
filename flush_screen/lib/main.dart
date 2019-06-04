import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flush_screen/providers/main.dart';
import 'package:flush_screen/screens/HomeScreen.dart';
import 'package:flush_screen/screens/AuthScreen.dart';
import 'package:flush_screen/utils/adaptiveTheme.dart';
import 'package:flush_screen/screens/SeconedScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProviderInfo>(
      builder: (context) {
        return ProviderInfo();
      },
      child: Consumer<ProviderInfo>(
        builder: (context, providerInfo, child) => MaterialApp(
              title: "Title",
              theme: getAdaptiveTheme(context),
              routes: {
                '/': (BuildContext context) {
                  return providerInfo.isAuthenticated == false ? AuthPage() : HomePage();
                },
                '/seconedScreen': (BuildContext context) {
                  return providerInfo.isAuthenticated == false ? AuthPage() : SeconedScreen();
                },
              },
              onUnknownRoute: (RouteSettings settings) {
                return MaterialPageRoute(
                  builder: (BuildContext context) =>
                      providerInfo.isAuthenticated == false ? AuthPage() : HomePage(),
                );
              },
            ),
      ),
    );
  }
}
