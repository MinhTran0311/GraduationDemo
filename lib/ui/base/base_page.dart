import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tab_navigator.dart';

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  String _currentPage = "HomeScreen";
  int _currentIndex = 1;
  late PageController _pageController;
  int _selectedIndex = 0;

  List<String> pageKeys = [
    "HistoryScreen",
    "HomeScreen",
    "InfoScreen",
  ];
  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "HistoryScreen": GlobalKey<NavigatorState>(),
    "HomeScreen": GlobalKey<NavigatorState>(),
    "InfoScreen": GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentPage]!.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_currentPage != "HomeScreen") {
            _selectTab("HomeScreen", 1);
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Stack(children: [
            _buildOffstageNavigator("HistoryScreen"),
            _buildOffstageNavigator("HomeScreen"),
            _buildOffstageNavigator("InfoScreen"),
          ]),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          height: 58,
          backgroundColor: Colors.white70,
          color: Colors.amber,
          items: <Widget>[
            Icon(Icons.history_rounded, size: 32, color: Colors.white),
            Icon(Icons.home_rounded, size: 32, color: Colors.white),
            Icon(Icons.account_circle, size: 32, color: Colors.white),
          ],
          index: _currentIndex,
          onTap: (index) {
            setState(() {
              _selectTab(pageKeys[index], index);
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
        _currentIndex = index;
      });
    }
    setState(() {});
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem]!,
        tabItem: tabItem,
      ),
    );
  }
}
