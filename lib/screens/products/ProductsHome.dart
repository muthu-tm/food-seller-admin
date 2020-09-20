import 'package:chipchop_seller/screens/products/ActiveProductsScreen.dart';
import 'package:chipchop_seller/screens/products/InActiveProductsHome.dart';
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
            Card(
              elevation: 5.0,
              child: Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: 75,
                child: ListTile(
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
                  trailing: Icon(
                    Icons.keyboard_arrow_right,
                    size: 35,
                    color: CustomColors.sellerBlue,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActiveProductsScreen(),
                        settings:
                            RouteSettings(name: '/settings/products/active'),
                      ),
                    );
                  },
                ),
              ),
            ),
            Card(
              elevation: 5.0,
              child: Container(
                padding: EdgeInsets.all(5),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: 75,
                child: ListTile(
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
                  trailing: Icon(
                    Icons.keyboard_arrow_right,
                    size: 35,
                    color: CustomColors.sellerAlertRed,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InActiveProductsScreen(),
                        settings:
                            RouteSettings(name: '/settings/products/inactive'),
                      ),
                    );
                  },
                ),
              ),
            ),
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
}
