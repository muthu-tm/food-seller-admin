import 'package:chipchop_seller/db/models/store_locations.dart';
import 'package:chipchop_seller/screens/app/appBar.dart';
import 'package:chipchop_seller/screens/app/sideDrawer.dart';
import 'package:chipchop_seller/screens/store/AddStoreHome.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoreSettings extends StatefulWidget {
  @override
  _StoreSettingsState createState() => _StoreSettingsState();
}

class _StoreSettingsState extends State<StoreSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      drawer: sideDrawer(context),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.sellerGreen,
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNewStoreHome(),
              settings: RouteSettings(name: '/settings/store'),
            ),
          );
        },
        label: Text("Add New Store"),
        icon: Icon(
          Icons.store,
          size: 35,
          color: CustomColors.sellerBlue,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
          child: Container(
        child: getStores(context),
      )),
    );
  }

  Widget getStores(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: StoreLocations().streamStoresForUser(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          List<Widget> children;

          if (snapshot.hasData) {
            if (snapshot.data.documents.isNotEmpty) {
              StoreLocations storeLoc =
                  StoreLocations.fromJson(snapshot.data.documents.first.data);
              children = [
                Container(
                  height: 90,
                  child: Text(
                    storeLoc.locationName,
                    style: TextStyle(color: CustomColors.sellerBlue),
                  ),
                ),
              ];
            } else {
              children = [
                Container(
                  height: 90,
                  child: Column(
                    children: <Widget>[
                      Spacer(),
                      Text(
                        "No Store Available",
                        style: TextStyle(
                          color: CustomColors.sellerAlertRed,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Text(
                        "Add your Store Now1",
                        style: TextStyle(
                          color: CustomColors.sellerBlue,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ];
            }
          } else if (snapshot.hasError) {
            children = AsyncWidgets.asyncError();
          } else {
            children = AsyncWidgets.asyncWaiting();
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: children,
            ),
          );
        });
  }
}
