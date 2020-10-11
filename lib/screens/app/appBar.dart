import 'package:chipchop_seller/screens/app/SearchAppBar.dart';
import 'package:flutter/material.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';

Widget appBar(BuildContext context) {
  return AppBar(
    backgroundColor: CustomColors.green,
    titleSpacing: 0.0,
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        Builder(
          builder: (context) => InkWell(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              padding: EdgeInsets.only(left: 5.0),
              child: Icon(
                Icons.menu,
                size: 30.0,
                color: CustomColors.black,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 15,
        ),
        Text(
          "Uniques",
          style: TextStyle(
              fontFamily: "OLED",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
      ],
    ),
    actions: <Widget>[
      IconButton(
        icon: Icon(
          Icons.search,
          size: 30.0,
          color: CustomColors.black,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchAppBar(),
              settings: RouteSettings(name: '/Search'),
            ),
          );
        },
      ),
    ],
  );
}
