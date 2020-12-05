import 'package:chipchop_seller/screens/utils/AddStoreWidget.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class NoStoresWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: 150,
      child: Column(
        children: <Widget>[
          Spacer(),
          Text(
            "Hey, Yet No Stores has been Added !!",
            style: TextStyle(
              color: CustomColors.alertRed,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(
            flex: 2,
          ),
          AddStoreWidget(),
          Spacer(),
        ],
      ),
    );
  }
}
