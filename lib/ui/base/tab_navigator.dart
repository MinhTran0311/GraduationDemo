import 'package:boilerplate/ui/history/history.dart';
import 'package:boilerplate/ui/home/home.dart';
import 'package:boilerplate/ui/profile/profile.dart';
import 'package:flutter/material.dart';


class TabNavigator extends StatelessWidget {
  TabNavigator({required this.navigatorKey, required this.tabItem});

  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;

  @override
  Widget build(BuildContext context) {
    late Widget child;
    if (tabItem == "HomeScreen")
      child = HomeScreen();
    else if (tabItem == "InfoScreen")
      child = ProfileScreen();
    else if (tabItem == "HistoryScreen")
      child = HistoryScreen();
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
