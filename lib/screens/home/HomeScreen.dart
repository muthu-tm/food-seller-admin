import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/app/appBar.dart';
import 'package:chipchop_seller/screens/app/bottomBar.dart';
import 'package:chipchop_seller/screens/app/sideDrawer.dart';
import 'package:chipchop_seller/screens/store/StoreSearchBar.dart';
import 'package:chipchop_seller/screens/store/StoreWidget.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/NoStoresWidget.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
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
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                getWidget(context),
                RecentProductsWidget(''),
              ],
            ),
          ),
        ),
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
