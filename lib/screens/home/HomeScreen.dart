import 'package:chipchop_seller/screens/app/appBar.dart';
import 'package:chipchop_seller/screens/app/sideDrawer.dart';
import 'package:chipchop_seller/screens/settings/SettingsHome.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen([this.selectedIndex = 0]);

  final int selectedIndex;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const TextStyle optionStyle = TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: CustomColors.sellerGreen);

  static List<Widget> _widgetOptions = <Widget>[
    Text(
      'TODO: Home',
      style: optionStyle,
    ),
    Text(
      'TODO: Products',
      style: optionStyle,
    ),
    Text(
      'TODO: Sales',
      style: optionStyle,
    ),
    Text(
      'TODO: Reports',
      style: optionStyle,
    ),
    SettingsHome(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    this._selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar(context),
      drawer: sideDrawer(context),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ),
      ),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: CustomColors.sellerGreen,
        style: TabStyle.flip,
        items: [
          TabItem(
              icon: Icon(
                Icons.store,
                color: CustomColors.sellerBlue,
                size: 30,
              ),
              title: 'Home'),
          TabItem(
              icon: Icon(
                Icons.add_shopping_cart,
                color: CustomColors.sellerBlue,
                size: 30,
              ),
              title: 'Products'),
          TabItem(
              icon: Icon(
                Icons.assessment,
                color: CustomColors.sellerBlue,
                size: 30,
              ),
              title: 'Sales'),
          TabItem(
              icon: Icon(
                Icons.description,
                color: CustomColors.sellerBlue,
                size: 30,
              ),
              title: 'Reports'),
          TabItem(
              icon: Icon(
                Icons.settings,
                color: CustomColors.sellerBlue,
                size: 30,
              ),
              title: 'Settings'),
        ],
        initialActiveIndex: _selectedIndex, //optional, default as 0
        onTap: _onItemTapped,
      ),
    );
  }
}
