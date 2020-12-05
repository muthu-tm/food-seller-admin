import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/app/appBar.dart';
import 'package:chipchop_seller/screens/app/bottomBar.dart';
import 'package:chipchop_seller/screens/app/sideDrawer.dart';
import 'package:chipchop_seller/screens/customers/CustomersScreen.dart';
import 'package:chipchop_seller/screens/store/StoreWidget.dart';
import 'package:chipchop_seller/screens/store/ViewStoreScreen.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/NoStoresWidget.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:chipchop_seller/services/utils/DateUtils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatelessWidget {
  int backPressCounter = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: appBar(context),
        drawer: sideDrawer(context),
        body: getWidget(context),
        bottomNavigationBar: bottomBar(context),
      ),
    );
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
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        primary: true,
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {

                          return Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                            child: StoreWidget(snapshot.data[index]),
                          );
                        },
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
