import 'package:chipchop_seller/screens/store/AddStoreHome.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class AddStoreWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewStoreHome(),
              settings: RouteSettings(name: '/settings/store/add'),
            ),
          );
        },
        textColor: Colors.white,
        padding: const EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Container(
          width: 175,
          height: 50,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                CustomColors.blueGreen,
                CustomColors.green,
              ],
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(
                Icons.store_mall_directory,
                color: CustomColors.white,
                size: 30,
              ),
              Text(
                "Add New Store",
                style: TextStyle(color: CustomColors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
