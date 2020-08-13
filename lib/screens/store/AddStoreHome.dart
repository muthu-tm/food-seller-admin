import 'package:chipchop_seller/app_localizations.dart';
import 'package:chipchop_seller/db/models/address.dart';
import 'package:chipchop_seller/db/models/product_categories.dart';
import 'package:chipchop_seller/screens/store/LocationPicker.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class AddNewStoreHome extends StatefulWidget {
  @override
  _AddNewStoreHomeState createState() => _AddNewStoreHomeState();
}

class _AddNewStoreHomeState extends State<AddNewStoreHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String storeName = '';
  List<int> availProducts = [];
  List<int> workingDays = [];
  int activeFrom;
  int activeTill;
  Address address = Address();
  List<String> _categories = ProductCategories.getCategories();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Create New Store"),
        backgroundColor: CustomColors.sellerPurple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: CustomColors.sellerPurple,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationPicker(),
                settings: RouteSettings(name: '/settings/store/add/location'),
              ),
            );
          },
          label: Text("Next")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context).translate('general_details'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Georgia",
                      fontWeight: FontWeight.bold,
                      color: CustomColors.sellerButtonGreen,
                    ),
                  ),
                ),
                Divider(
                  color: CustomColors.sellerPurple,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppLocalizations.of(context).translate('store_name'),
                      style: TextStyle(
                          fontFamily: "Georgia",
                          color: CustomColors.sellerGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.start,
                    initialValue: storeName,
                    decoration: InputDecoration(
                      fillColor: CustomColors.sellerWhite,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.sellerGrey)),
                    ),
                    validator: (name) {
                      if (name.isEmpty) {
                        return "Enter Store Name";
                      } else {
                        this.storeName = name.trim();
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppLocalizations.of(context)
                          .translate('available_products'),
                      style: TextStyle(
                          fontFamily: "Georgia",
                          color: CustomColors.sellerGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10, right: 10),
                  child: Container(
                    height: 300,
                    color: CustomColors.sellerGrey,
                    child: ListView.builder(
                      primary: true,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: _categories.length,
                      itemBuilder: (BuildContext context, int index) {
                        String _c = _categories[index];
                        return InkWell(
                          onTap: () {
                            if (availProducts.contains(index)) {
                              setState(() {
                                availProducts.remove(index);
                              });
                            } else {
                              setState(() {
                                availProducts.add(index);
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            color: availProducts.contains(index)
                                ? CustomColors.sellerPurple
                                : CustomColors.sellerWhite,
                            height: 40,
                            width: 50,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _c,
                              style: TextStyle(
                                  fontFamily: "Georgia",
                                  color: availProducts.contains(index)
                                      ? CustomColors.sellerWhite
                                      : CustomColors.sellerPurple),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
