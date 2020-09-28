import 'package:chipchop_seller/screens/settings/StoreSettings.dart';
import 'package:chipchop_seller/screens/settings/UserProfileSettings.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class SettingsHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: <Widget>[
            InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: 85,
                          height: 80,
                          decoration: BoxDecoration(
                            color: CustomColors.green,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: CustomColors.blue.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Icon(
                                  Icons.person,
                                  size: 35,
                                  color: CustomColors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Profile Settings",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Georgia',
                        color: CustomColors.black,
                      ),
                    ),
                  ),
                ],
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
              color: CustomColors.green,
              thickness: 2.0,
              height: 1,
            ),
            InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: 85,
                          height: 80,
                          decoration: BoxDecoration(
                            color: CustomColors.green,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: CustomColors.blue.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Icon(
                                  Icons.store,
                                  size: 35,
                                  color: CustomColors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Store Settings",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Georgia',
                        color: CustomColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoreSettings(),
                    settings: RouteSettings(name: '/settings/store'),
                  ),
                );
              },
            ),
            Divider(
              color: CustomColors.green,
              thickness: 2.0,
              height: 1,
            ),
            InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: 85,
                          height: 80,
                          decoration: BoxDecoration(
                            color: CustomColors.green,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: CustomColors.blue.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Icon(
                                  Icons.local_offer,
                                  size: 35,
                                  color: CustomColors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "PromoCode",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Georgia',
                        color: CustomColors.black,
                      ),
                    ),
                  ),
                ],
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
              color: CustomColors.green,
              thickness: 2.0,
              height: 1,
            ),
            InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: 85,
                          height: 80,
                          decoration: BoxDecoration(
                            color: CustomColors.green,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: CustomColors.blue.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: ClipRRect(
                                  child: Image.asset(
                                    "images/icons/logo.png",
                                    height: 25,
                                    width: 25,
                                    cacheHeight: 30,
                                    cacheWidth: 35,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "ChipChop Seller",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Georgia',
                        color: CustomColors.black,
                      ),
                    ),
                  ),
                ],
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
              color: CustomColors.green,
              thickness: 2.0,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }
}
