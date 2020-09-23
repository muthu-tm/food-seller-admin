import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/products/ActiveProductsScreen.dart';
import 'package:chipchop_seller/screens/products/AddProducts.dart';
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
        child: getStores(context),
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
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.add_circle_outline,
                              size: 35,
                              color: CustomColors.sellerBlue,
                            ),
                            title: Text(
                              "Add Product",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: 'Georgia',
                                color: CustomColors.sellerBlack,
                              ),
                            ),
                          ),
                          Divider(color: CustomColors.sellerBlue),
                          TextFormField(
                            textAlign: TextAlign.center,
                            autofocus: false,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "Search & Load from existing Products",
                              fillColor: CustomColors.sellerWhite,
                              filled: true,
                              suffixIcon: Icon(
                                Icons.search,
                                color: CustomColors.sellerBlue,
                                size: 35.0,
                              ),
                            ),
                            onTap: () {
                              showSearch(context: context, delegate: Search());
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          Text(
                            "OR",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontFamily: 'Georgia',
                              color: CustomColors.sellerGrey,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          RaisedButton.icon(
                            padding: EdgeInsets.all(5),
                            color: CustomColors.sellerBlue,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddProduct(null),
                                  settings: RouteSettings(
                                      name: '/settings/products/add'),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.add_circle,
                              size: 30,
                              color: CustomColors.sellerGreen,
                            ),
                            label: Text(
                              "Add Custom Product",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: 'Georgia',
                                color: CustomColors.sellerLightGrey,
                              ),
                            ),
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
