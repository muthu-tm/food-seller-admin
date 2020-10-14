import 'package:chipchop_seller/screens/app/CustomersBottomWidget.dart';
import 'package:chipchop_seller/screens/home/HomeScreen.dart';
import 'package:chipchop_seller/screens/orders/OrdersHomeScreen.dart';
import 'package:chipchop_seller/screens/products/ProductsHome.dart';
import 'package:chipchop_seller/screens/settings/SettingsHome.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget bottomBar(BuildContext context) {
  Size size = Size(screenWidth(context, dividedBy: 5), 100);

  return Container(
    height: 60,
    decoration: BoxDecoration(
      gradient: LinearGradient(
          colors: [CustomColors.white, CustomColors.green],
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                  settings: RouteSettings(name: '/'),
                ),
                (Route<dynamic> route) => false,
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.home,
                  size: 25.0,
                  color: CustomColors.black,
                ),
                Text(
                  "HOME",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Georgia",
                    fontSize: 11,
                    color: CustomColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox.fromSize(
          size: size,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsHome(),
                  settings: RouteSettings(name: '/products'),
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  FontAwesomeIcons.shoppingBasket,
                  size: 25.0,
                  color: CustomColors.black,
                ),
                Text(
                  "PRODUCTS",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Georgia",
                    fontSize: 11,
                    color: CustomColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        CustomersBottomWidget(size),
        SizedBox.fromSize(
          size: size,
          child: InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => OrdersHomeScreen(cachedLocalUser.stores),
                  settings: RouteSettings(name: '/orders'),
                ),
                (Route<dynamic> route) => false,
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.content_copy,
                  size: 25.0,
                  color: CustomColors.black,
                ),
                Text(
                  "ORDERS",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Georgia",
                    fontSize: 11,
                    color: CustomColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox.fromSize(
          size: size,
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsHome(),
                    settings: RouteSettings(name: '/settings'),
                  ));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.settings,
                  size: 25.0,
                  color: CustomColors.black,
                ),
                Text(
                  "SETTINGS",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Georgia",
                    fontSize: 11,
                    color: CustomColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

double screenWidth(BuildContext context, {double dividedBy = 1}) {
  return screenSize(context).width / dividedBy;
}

Size screenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double screenHeight(BuildContext context, {double dividedBy = 1}) {
  return screenSize(context).height / dividedBy;
}
