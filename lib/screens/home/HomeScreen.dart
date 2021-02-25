import 'package:chipchop_seller/db/models/chat_temp.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/main.dart';
import 'package:chipchop_seller/screens/app/appBar.dart';
import 'package:chipchop_seller/screens/app/sideDrawer.dart';
import 'package:chipchop_seller/screens/customers/CustomersHome.dart';
import 'package:chipchop_seller/screens/customers/StoreChatScreen.dart';
import 'package:chipchop_seller/screens/orders/OrderDetailsScreen.dart';
import 'package:chipchop_seller/screens/orders/OrdersHomeScreen.dart';
import 'package:chipchop_seller/screens/products/ProductDetailsScreen.dart';
import 'package:chipchop_seller/screens/products/ProductsHome.dart';
import 'package:chipchop_seller/screens/settings/SettingsHome.dart';
import 'package:chipchop_seller/screens/store/StoreSearchBar.dart';
import 'package:chipchop_seller/screens/store/StoreWidget.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/NoStoresWidget.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

bool newStoreNotification = false;
bool newOrderNotification = false;


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage event) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  Map<String, dynamic> msg = event.data;

  switch (msg['data']['screen']) {
    case "store-chat":
      navigatorKey.currentState.push(MaterialPageRoute(
        builder: (context) => StoreChatScreen(
            storeID: msg['data']['store_uuid'],
            custID: msg['data']['customer_uuid'],
            custName: msg['data']['customer_name'] ?? ''),
        settings: RouteSettings(name: '/customers/store/chats'),
      ));
      break;
    case "order":
      navigatorKey.currentState.push(MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(msg['data']['order_id'],
            msg['data']['order_uuid'], msg['data']['customer_id']),
        settings: RouteSettings(name: '/orders/details'),
      ));
      break;
    case "product":
      Products _p = await Products().getByProductID(msg['data']['product_id']);
      if (_p != null) {
        navigatorKey.currentState.push(MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(_p),
          settings: RouteSettings(name: '/store/products'),
        ));
      }
      break;
  }

  if (msg['type'] == '100') {
    await ChatTemplate().updateToUnRead(
      msg['data']['store_uuid'],
      msg['data']['customer_uuid'],
    );

    newStoreNotification = true;
  } else if (msg['type'] == '000' || msg['type'] == '001') {
    // Order update || Order chat
    newOrderNotification = true;
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen(this.index);

  final int index;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _newStoreNotification = false;
  bool _newOrderNotification = false;

  int backPressCounter = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;

    _newStoreNotification = newStoreNotification;
    _newOrderNotification = newOrderNotification;

    FirebaseMessaging.onMessage.listen((event) async {
      Map<String, dynamic> message = event.data;

      if (message['type'] == '100') {
        await ChatTemplate().updateToUnRead(
          message['store_uuid'],
          message['data']['customer_uuid'],
        );
        setState(() {
          _newStoreNotification = true;
          newStoreNotification = true;
        });
      } else if (message['type'] == '000' || message['type'] == '001') {
        // Order update || Order chat
        setState(() {
          _newOrderNotification = true;
          newOrderNotification = true;
        });
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      Map<String, dynamic> message = event.data;

      if (message['type'] == '100') {
        await ChatTemplate().updateToUnRead(
          message['store_uuid'],
          message['data']['customer_uuid'],
        );

        setState(() {
          _newStoreNotification = true;
          newStoreNotification = true;
        });
      } else if (message['type'] == '000' || message['type'] == '001') {
        // Order update || Order chat
        setState(() {
          _newOrderNotification = true;
          newOrderNotification = true;
        });
      }
      print("onLaunch: $message");
    });
  }

  Future<void> fcmMessageHandler(msg, context) async {
    switch (msg['data']['screen']) {
      case "store-chat":
        navigatorKey.currentState.push(MaterialPageRoute(
          builder: (context) => StoreChatScreen(
              storeID: msg['data']['store_uuid'],
              custID: msg['data']['customer_uuid'],
              custName: msg['data']['customer_name'] ?? ''),
          settings: RouteSettings(name: '/customers/store/chats'),
        ));
        break;
      case "order":
        navigatorKey.currentState.push(MaterialPageRoute(
          builder: (context) => OrderDetailsScreen(msg['data']['order_id'],
              msg['data']['order_uuid'], msg['data']['customer_id']),
          settings: RouteSettings(name: '/orders/details'),
        ));
        break;
      case "product":
        Products _p =
            await Products().getByProductID(msg['data']['product_id']);
        if (_p != null) {
          navigatorKey.currentState.push(MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(_p),
            settings: RouteSettings(name: '/store/products'),
          ));
        }
        break;
    }
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
              _newOrderNotification
                  ? SizedBox.fromSize(
                      size: size,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            newOrderNotification = false;
                            _newOrderNotification = false;

                            _selectedIndex = 3;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Icon(
                                    FontAwesomeIcons.shoppingBag,
                                    size: 22.0,
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
                            SizedBox(
                              height: 5,
                            ),
                            Text("Orders", style: GoogleFonts.orienta()),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.fromSize(
                      size: size,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            newOrderNotification = false;
                            _newOrderNotification = false;

                            _selectedIndex = 3;
                          });
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
