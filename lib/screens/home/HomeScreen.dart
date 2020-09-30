import 'package:chipchop_seller/screens/app/appBar.dart';
import 'package:chipchop_seller/screens/app/sideDrawer.dart';
import 'package:chipchop_seller/screens/home/HomeScreenStoreWidget.dart';
import 'package:chipchop_seller/screens/orders/OrdersHomeScreen.dart';
import 'package:chipchop_seller/screens/products/ProductsHome.dart';
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

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreenStoreWidget(),
    ProductsHome(),
    OrdersHomeScreen("2RDH3xSNLY8aB9OM0PlQ"),
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
        backgroundColor: CustomColors.green,
        style: TabStyle.flip,
        items: [
          TabItem(
              icon: Icon(
                Icons.store,
                color: CustomColors.blue,
                size: 30,
              ),
              title: 'Home'),
          TabItem(
              icon: Icon(
                Icons.add_shopping_cart,
                color: CustomColors.blue,
                size: 30,
              ),
              title: 'Products'),
          TabItem(
              icon: Icon(
                Icons.assessment,
                color: CustomColors.blue,
                size: 30,
              ),
              title: 'Orders'),
          TabItem(
              icon: Icon(
                Icons.settings,
                color: CustomColors.blue,
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
