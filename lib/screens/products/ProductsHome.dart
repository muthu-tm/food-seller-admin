import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/app/appBar.dart';
import 'package:chipchop_seller/screens/app/bottomBar.dart';
import 'package:chipchop_seller/screens/app/sideDrawer.dart';
import 'package:chipchop_seller/screens/products/AddProducts.dart';
import 'package:chipchop_seller/screens/products/ViewProductsList.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/NoStoresWidget.dart';
import 'package:flutter/material.dart';

class ProductsHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      drawer: sideDrawer(context),
      body: SingleChildScrollView(
        child: Container(
          color: CustomColors.lightGrey,
          child: SingleChildScrollView(
            child: getStores(context),
          ),
        ),
      ),
      bottomNavigationBar: bottomBar(context),
    );
  }

  Widget getStores(BuildContext context) {
    return FutureBuilder<List<Store>>(
      future: Store().getStoresForUser(),
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
                color: CustomColors.white,
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
                              color: CustomColors.blue,
                            ),
                            title: Text(
                              "Add Product",
                              style: TextStyle(
                                fontSize: 16.0,
                                
                                color: CustomColors.black,
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              showSearch(context: context, delegate: Search());
                            },
                            leading: Text(""),
                            title: Text(
                              "Search & Load from existing Products",
                              style: TextStyle(
                                fontSize: 14.0,
                                
                                color: CustomColors.black,
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          Text(
                            "OR",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              
                              color: CustomColors.grey,
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddProduct(null),
                                  settings: RouteSettings(
                                      name: '/settings/products/add'),
                                ),
                              );
                            },
                            leading: Text(""),
                            title: Text(
                              "Add Custom Product",
                              style: TextStyle(
                                fontSize: 14.0,
                                
                                color: CustomColors.black,
                              ),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
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
                          Icons.remove_red_eye,
                          size: 35,
                          color: CustomColors.blue,
                        ),
                        title: Text(
                          "View Products",
                          style: TextStyle(
                            fontSize: 16.0,
                            
                            color: CustomColors.black,
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
                                leading:
                                    Icon(Icons.store, color: CustomColors.blue),
                                title: Text(store.name),
                                trailing: Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 35,
                                  color: CustomColors.blue,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ViewProductsListScreen(store),
                                      settings: RouteSettings(
                                          name: '/settings/products/view'),
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
            children = NoStoresWidget();
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
