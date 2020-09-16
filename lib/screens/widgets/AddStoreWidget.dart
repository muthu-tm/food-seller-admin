import 'package:chipchop_seller/screens/store/AddStoreHome.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class AddStoreWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Material(
        elevation: 5.0,
        shadowColor: CustomColors.sellerBlue,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: 225,
          height: 50,
          child: FlatButton.icon(
            icon: Icon(
              Icons.store,
              size: 35.0,
              color: CustomColors.sellerBlue,
            ),
            label: Text(
              "Create New Store",
              style: TextStyle(
                  fontFamily: 'Georgia',
                  color: CustomColors.sellerGreen,
                  fontSize: 15.0),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewStoreHome(),
                settings: RouteSettings(name: '/settings/store/add'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
