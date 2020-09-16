import 'package:chipchop_seller/app_localizations.dart';
import 'package:chipchop_seller/db/models/address.dart';
import 'package:chipchop_seller/db/models/delivery_details.dart';
import 'package:chipchop_seller/db/models/product_categories.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/db/models/store_contacts.dart';
import 'package:chipchop_seller/db/models/store_locations.dart';
import 'package:chipchop_seller/db/models/store_user_access.dart';
import 'package:chipchop_seller/screens/store/LocationPicker.dart';
import 'package:chipchop_seller/screens/utils/AddressWidget.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:flutter/material.dart';

class AddNewStoreHome extends StatefulWidget {
  @override
  _AddNewStoreHomeState createState() => _AddNewStoreHomeState();
}

class _AddNewStoreHomeState extends State<AddNewStoreHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Address sAddress = Address();
  String storeName = '';
  String ownedBy = '';
  List<int> availProducts = [];
  List<int> workingDays = [1, 2, 3, 4, 5];
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

    ownedBy = cachedLocalUser.firstName + cachedLocalUser.lastName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('create_new_store'),
        ),
        backgroundColor: CustomColors.sellerGreen,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.sellerBlue,
        onPressed: () {
          final FormState form = _formKey.currentState;

          if (form.validate()) {
            if (availProducts.length == 0) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar(
                    "Please Select your available products!", 2),
              );
              return;
            }
            if (workingDays.length == 0) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar(
                    "Please Set your working days!", 2),
              );
              return;
            }
            if (sAddress.pincode == null || sAddress.pincode.isEmpty) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar("Please enter your PINCODE!", 2),
              );
              return;
            }
            Store store = Store();
            StoreLocations loc = StoreLocations();
            StoreContacts contacts = StoreContacts();
            contacts.contactName = cachedLocalUser.firstName;
            contacts.contactNumber = cachedLocalUser.mobileNumber;
            contacts.countryCode = cachedLocalUser.countryCode;
            contacts.isActive = true;
            contacts.isVerfied = true;

            store.storeName = this.storeName;
            store.ownedBy = this.ownedBy;
            loc.availProducts = this.availProducts;
            loc.activeFrom = activeFrom;
            loc.activeTill = activeTill;
            loc.locationName = storeName;
            loc.address = sAddress;
            loc.workingDays = workingDays;
            loc.contacts = [contacts];
            loc.deliveryDetails = [DeliveryDetails()];

            StoreUserAccess userAccess = StoreUserAccess();
            userAccess.positionName = "Owner";
            userAccess.userNumber = cachedLocalUser.getIntID();
            userAccess.accessLevel = [0];
            loc.users = [userAccess];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationPicker(store, loc),
                settings: RouteSettings(name: '/settings/store/add/location'),
              ),
            );
          } else {
            _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar("Please fill valid data!", 2));
          }
        },
        label: Text(
          AppLocalizations.of(context).translate('button_next'),
        ),
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
                      color: CustomColors.sellerBlue,
                    ),
                  ),
                ),
                Divider(
                  color: CustomColors.sellerGreen,
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
                    autofocus: false,
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
                  padding: EdgeInsets.only(left: 10.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppLocalizations.of(context).translate('owner_name'),
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
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.start,
                    initialValue: ownedBy,
                    decoration: InputDecoration(
                      fillColor: CustomColors.sellerWhite,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.sellerGrey)),
                    ),
                    validator: (owner) {
                      if (owner.isEmpty) {
                        return "Enter Owner Name";
                      } else {
                        this.ownedBy = owner.trim();
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
                                ? CustomColors.sellerBlue
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
                                      : CustomColors.sellerGreen),
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
                                ? CustomColors.sellerBlue
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
                                      : CustomColors.sellerGreen),
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
                          color: CustomColors.sellerGreen,
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
                  padding: EdgeInsets.all(5),
                  child: AddressWidget("Store Address", Address(), sAddress),
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
