import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/products/ActiveProductsScreen.dart';
import 'package:chipchop_seller/screens/products/InActiveProductsHome.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class ProductsHome extends StatefulWidget {
  @override
  _ProductsHomeState createState() => _ProductsHomeState();
}

class _ProductsHomeState extends State<ProductsHome> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        color: CustomColors.sellerLightGrey,
        child: Column(
          children: [
            getStores(context),
            Padding(padding: EdgeInsets.all(40)),
            Card(
              elevation: 10,
              child: Container(
                padding: EdgeInsets.all(5),
                width: 200,
                child: InkWell(
                  splashColor: CustomColors.sellerGreen,
                  onTap: () {
                    print("Add Product");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.add_circle,
                          size: 35,
                          color: CustomColors.sellerGreen,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          "Add Product",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Georgia',
                            color: CustomColors.sellerBlack,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getStores(BuildContext context) {
    return FutureBuilder<List<Store>>(
      future: Store().getStoresWithLocation(),
      builder: (BuildContext context, AsyncSnapshot<List<Store>> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            children = Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                color: CustomColors.sellerWhite,
              ),
              child: Column(
                children: [
                  Card(
                    elevation: 5.0,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: ExpansionTile(
                        leading: Icon(
                          Icons.adjust,
                          size: 35,
                          color: CustomColors.sellerBlue,
                        ),
                        title: Text(
                          "Active Products",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Georgia',
                            color: CustomColors.sellerBlack,
                          ),
                        ),
                        children: [
                          ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              Store store = snapshot.data[index];
                              return ListTile(
                                leading: Icon(Icons.store,
                                    color: CustomColors.sellerBlue),
                                title: Text(
                                  store.storeName,
                                ),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 35,
                                  color: CustomColors.sellerBlue,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ActiveProductsScreen(store),
                                      settings: RouteSettings(
                                          name: '/settings/products/active'),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 5.0,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: ExpansionTile(
                        leading: Icon(
                          Icons.adjust,
                          size: 35,
                          color: CustomColors.sellerAlertRed,
                        ),
                        title: Text(
                          "InActive Products",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontFamily: 'Georgia',
                            color: CustomColors.sellerBlack,
                          ),
                        ),
                        children: [
                          ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              Store store = snapshot.data[index];
                              return ListTile(
                                leading: Icon(Icons.store,
                                    color: CustomColors.sellerBlue),
                                title: Text(
                                  store.storeName,
                                ),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 35,
                                  color: CustomColors.sellerBlue,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          InActiveProductsScreen(store),
                                      settings: RouteSettings(
                                          name: '/settings/products/active'),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            children = Container(
              color: CustomColors.sellerWhite,
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
                    "Add your Store Now!",
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
            );
          }
        } else if (snapshot.hasError) {
          children = Center(
            child: Column(
              children: AsyncWidgets.asyncError(),
            ),
          );
        } else {
          children = Center(
            child: Column(
              children: AsyncWidgets.asyncWaiting(),
            ),
          );
        }
        return children;
      },
    );
  }
}
