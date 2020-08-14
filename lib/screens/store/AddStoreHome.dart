import 'package:chipchop_seller/app_localizations.dart';
import 'package:chipchop_seller/db/models/address.dart';
import 'package:chipchop_seller/db/models/product_categories.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/db/models/store_locations.dart';
import 'package:chipchop_seller/screens/store/LocationPicker.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomSnackBar.dart';
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
  TimeOfDay fromTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay tillTime = TimeOfDay(hour: 18, minute: 0);
  String activeFrom;
  String activeTill;
  List<String> _categories = ProductCategories.getCategories();
  List<String> _days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  @override
  void initState() {
    super.initState();
    activeFrom = '${fromTime.hour}:${fromTime.minute}';
    activeTill = '${tillTime.hour}:${tillTime.minute}';
  }

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
          final FormState form = _formKey.currentState;

          if (form.validate()) {
            Store store = Store();
            StoreLocations loc = StoreLocations();
            store.storeName = this.storeName;
            loc.availProducts = this.availProducts;
            loc.activeFrom = activeFrom;
            loc.activeTill = activeTill;
            loc.locationName = storeName;
            loc.workingDays = workingDays;
            store.locations = [loc];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationPicker(store),
                settings: RouteSettings(name: '/settings/store/add/location'),
              ),
            );
          } else {
            _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar("Please fill valid data!", 2));
          }
        },
        label: Text("Next"),
      ),
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
                          fontSize: 16),
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
                          fontSize: 16),
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
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppLocalizations.of(context).translate('working_days'),
                      style: TextStyle(
                          fontFamily: "Georgia",
                          color: CustomColors.sellerGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10, right: 10),
                  child: Container(
                    height: 200,
                    color: CustomColors.sellerGrey,
                    child: ListView.builder(
                      primary: true,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: 7,
                      itemBuilder: (BuildContext context, int index) {
                        String _d = _days[index];
                        return InkWell(
                          onTap: () {
                            if (workingDays.contains(index)) {
                              setState(() {
                                workingDays.remove(index);
                              });
                            } else {
                              setState(() {
                                workingDays.add(index);
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            color: workingDays.contains(index)
                                ? CustomColors.sellerPurple
                                : CustomColors.sellerWhite,
                            height: 40,
                            width: 50,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _d,
                              style: TextStyle(
                                  fontFamily: "Georgia",
                                  color: workingDays.contains(index)
                                      ? CustomColors.sellerWhite
                                      : CustomColors.sellerPurple),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppLocalizations.of(context).translate('working_hours'),
                      style: TextStyle(
                          fontFamily: "Georgia",
                          color: CustomColors.sellerGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ListTile(
                          title: Text("${fromTime.format(context)}"),
                          trailing: Icon(Icons.keyboard_arrow_down),
                          onTap: () async {
                            await _pickFromTime();
                          },
                        ),
                      ),
                      Text(
                        "--",
                        style: TextStyle(
                          fontFamily: "Georgia",
                          color: CustomColors.sellerPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ListTile(
                          title: Text("${tillTime.format(context)}"),
                          trailing: Icon(Icons.keyboard_arrow_down),
                          onTap: () async {
                            await _pickTillTime();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10, right: 10),
                  child: Card(
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            alignment: Alignment.center,
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate('delivery_details'),
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
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 85,
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate('max_delivery'),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Georgia",
                                      fontWeight: FontWeight.bold,
                                      color: CustomColors.sellerButtonGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _pickFromTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: fromTime);
    if (t != null)
      setState(() {
        fromTime = t;
        activeFrom = '${t.hour}:${t.minute}';
      });
  }

  _pickTillTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: tillTime);
    if (t != null)
      setState(() {
        tillTime = t;
        activeTill = '${t.hour}:${t.minute}';
      });
  }
}
