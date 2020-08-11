import 'package:chipchop_seller/screens/app/appBar.dart';
import 'package:chipchop_seller/screens/app/sideDrawer.dart';
import 'package:chipchop_seller/screens/settings/UserProfileSettings.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class SettingsHome extends StatefulWidget {
  @override
  _SettingsHomeState createState() => _SettingsHomeState();
}

class _SettingsHomeState extends State<SettingsHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      drawer: sideDrawer(context),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.home, color: CustomColors.mfinButtonGreen),
                title: Text(
                  "Profile Settings",
                ),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserSetting(),
                      settings: RouteSettings(name: '/settings/profile'),
                    ),
                  );
                },
              ),
              Divider(
                  indent: 15.0, color: CustomColors.mfinBlue, thickness: 1.0),
              ExpansionTile(
                title: Text(
                  "Store",
                ),
                leading: Icon(Icons.content_copy,
                    color: CustomColors.mfinButtonGreen),
                children: <Widget>[
                  ListTile(
                    title: Text(
                      "General Info",
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                  ListTile(
                    title: Text(
                      "Locations",
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                ],
              ),
              Divider(
                  indent: 15.0, color: CustomColors.mfinBlue, thickness: 1.0),
              ExpansionTile(
                leading: Icon(Icons.supervisor_account,
                    color: CustomColors.mfinButtonGreen),
                title: Text(
                  "PromoCode",
                ),
                children: <Widget>[
                  ListTile(
                    title: Text(
                      "Add Promo",
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                  ListTile(
                    title: Text(
                      "View Promo",
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                  ),
                ],
              ),
              Divider(
                  indent: 15.0, color: CustomColors.mfinBlue, thickness: 1.0),
              ListTile(
                leading: Icon(Icons.home, color: CustomColors.mfinButtonGreen),
                title: Text(
                  "ChipChop Seller",
                ),
                onTap: () async {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
