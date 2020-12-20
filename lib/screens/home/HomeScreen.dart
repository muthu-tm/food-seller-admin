import 'package:chipchop_seller/db/models/chat_temp.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/app/appBar.dart';
import 'package:chipchop_seller/screens/app/sideDrawer.dart';
import 'package:chipchop_seller/screens/customers/CustomersHome.dart';
import 'package:chipchop_seller/screens/orders/OrdersHomeScreen.dart';
import 'package:chipchop_seller/screens/products/ProductsHome.dart';
import 'package:chipchop_seller/screens/settings/SettingsHome.dart';
import 'package:chipchop_seller/screens/store/StoreSearchBar.dart';
import 'package:chipchop_seller/screens/store/StoreWidget.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/NoStoresWidget.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

bool newStoreNotification = false;

class HomeScreen extends StatefulWidget {
  HomeScreen(this.index);

  final int index;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  bool _newStoreNotification = false;

  int backPressCounter = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;

    _newStoreNotification = newStoreNotification;
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (message['data']['type'] == '1') {
          await ChatTemplate().updateToUnRead(
            message['data']['store_uuid'],
            message['data']['customer_uuid'],
          );
          setState(() {
            _newStoreNotification = true;
            newStoreNotification = true;
          });
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (message['data']['type'] == '1') {
          await ChatTemplate().updateToUnRead(
            message['data']['store_uuid'],
            message['data']['customer_uuid'],
          );

          setState(() {
            _newStoreNotification = true;
            newStoreNotification = true;
          });
        }
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        if (message['data']['type'] == '1') {
          await ChatTemplate().updateToUnRead(
            message['data']['store_uuid'],
            message['data']['customer_uuid'],
          );

          setState(() {
            _newStoreNotification = true;
            newStoreNotification = true;
          });
        }
        print("onResume: $message");
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> onWillPop() {
    if (backPressCounter < 1) {
      backPressCounter++;
      Fluttertoast.showToast(msg: "Press again to exit !!");
      Future.delayed(Duration(seconds: 2, milliseconds: 0), () {
        backPressCounter--;
      });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = Size((MediaQuery.of(context).size.width / 5),
        MediaQuery.of(context).size.height * 0.1);
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: appBar(context),
        drawer: sideDrawer(context),
        body: SingleChildScrollView(
            child: _selectedIndex == 0
                ? Container(
                    child: Column(
                      children: [
                        getWidget(context),
                        RecentProductsWidget(''),
                      ],
                    ),
                  )
                : _selectedIndex == 1
                    ? ProductsHome()
                    : _selectedIndex == 2
                        ? CustomersHome()
                        : _selectedIndex == 3
                            ? OrdersHomeScreen()
                            : SettingsHome()),
        bottomNavigationBar: Container(
          height: 65,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [CustomColors.white, CustomColors.primary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox.fromSize(
                size: size,
                child: InkWell(
                  onTap: () {
                    _onItemTapped(0);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.home,
                        size: 20.0,
                        color: CustomColors.black,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Home",
                        style: GoogleFonts.orienta(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox.fromSize(
                size: size,
                child: InkWell(
                  onTap: () {
                    _onItemTapped(1);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.shoppingBasket,
                        size: 20.0,
                        color: CustomColors.black,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text("Products", style: GoogleFonts.orienta()),
                    ],
                  ),
                ),
              ),
              _newStoreNotification
                  ? SizedBox.fromSize(
                      size: size,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            newStoreNotification = false;
                            _newStoreNotification = false;

                            _selectedIndex = 2;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.group,
                                    size: 27.0,
                                    color: CustomColors.black,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: CustomColors.alertRed,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 11,
                                        minHeight: 11,
                                      ),
                                    ),
                                  )
                                ]),
                            Text("Customers",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.orienta()),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.fromSize(
                      size: size,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            newStoreNotification = false;
                            _newStoreNotification = false;

                            _selectedIndex = 2;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.group,
                              size: 27.0,
                              color: CustomColors.black,
                            ),
                            Text(
                              "Customers",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.orienta(),
                            ),
                          ],
                        ),
                      ),
                    ),
              SizedBox.fromSize(
                size: size,
                child: InkWell(
                  onTap: () {
                    _onItemTapped(3);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.shoppingBag,
                        size: 22.0,
                        color: CustomColors.black,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text("Orders", style: GoogleFonts.orienta()),
                    ],
                  ),
                ),
              ),
              SizedBox.fromSize(
                size: size,
                child: InkWell(
                  onTap: () {
                    _onItemTapped(4);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.settings,
                        size: 23.0,
                        color: CustomColors.black,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text("Settings", style: GoogleFonts.orienta()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getWidget(BuildContext context) {
    return Container(
      child: cachedLocalUser.stores == null || cachedLocalUser.stores.isEmpty
          ? Center(child: NoStoresWidget())
          : FutureBuilder(
              future: Store().getStoresForUser(),
              builder: (context, AsyncSnapshot<List<Store>> snapshot) {
                Widget child;

                if (snapshot.hasData) {
                  if (snapshot.data.length == 0) {
                    child = Center(child: NoStoresWidget());
                  } else {
                    child = Container(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              "My Stores",
                              style: TextStyle(
                                  color: CustomColors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                          ListView.builder(
                            scrollDirection: Axis.vertical,
                            primary: true,
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding:
                                    EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                                child: StoreWidget(snapshot.data[index]),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  child = Center(
                    child: Column(
                      children: AsyncWidgets.asyncError(),
                    ),
                  );
                } else {
                  child = Center(
                    child: Column(
                      children: AsyncWidgets.asyncWaiting(),
                    ),
                  );
                }
                return child;
              },
            ),
    );
  }
}
