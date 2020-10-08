import 'package:chipchop_seller/screens/app/appBar.dart';
import 'package:chipchop_seller/screens/app/sideDrawer.dart';
import 'package:chipchop_seller/screens/home/HomeScreenStoreWidget.dart';
import 'package:chipchop_seller/screens/orders/OrdersHomeScreen.dart';
import 'package:chipchop_seller/screens/products/ProductsHome.dart';
import 'package:chipchop_seller/screens/settings/SettingsHome.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen([this.selectedIndex = 0]);

  final int selectedIndex;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreenStoreWidget(),
    ProductsHome(),
    OrdersHomeScreen(cachedLocalUser.stores),
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

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(
                message['notification']['title'],
                style: TextStyle(
                    color: CustomColors.green,
                    fontSize: 16.0,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
              subtitle: Text(
                message['notification']['body'],
                style: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // _navigateToItemDetail(message);
      },
    );
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
                FontAwesomeIcons.storeAlt,
                color: CustomColors.blue,
                size: 30,
              ),
              title: 'Home'),
          TabItem(
              icon: Icon(
                FontAwesomeIcons.shoppingBasket,
                color: CustomColors.blue,
                size: 30,
              ),
              title: 'Products'),
          TabItem(
              icon: Icon(
                FontAwesomeIcons.shippingFast,
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
