import 'package:chipchop_seller/db/models/address.dart';
import 'package:chipchop_seller/db/models/product_categories.dart';
import 'package:chipchop_seller/db/models/product_sub_categories.dart';
import 'package:chipchop_seller/db/models/product_types.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/db/models/store_user_access.dart';
import 'package:chipchop_seller/screens/utils/AddressWidget.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app_localizations.dart';
import 'EditLocationPicker.dart';

class EditStoreScreen extends StatefulWidget {
  final Store store;

  EditStoreScreen(this.store);

  @override
  _EditStoreScreenState createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Address updateAddress = Address();
  String storeName = '';
  String ownedBy = '';
  String deliverFrom;
  String deliverTill;
  int maxDistance = 0;
  double deliveryCharge2 = 0.00;
  double deliveryCharge5 = 0.00;
  double deliveryCharge10 = 0.00;
  double deliveryChargeMax = 0.00;
  List<String> availProducts = [];
  List<String> availProductCategories = [];
  List<ProductCategories> productCategories = [];
  List<String> availProductSubCategories = [];
  List<int> workingDays = [1, 2, 3, 4, 5];

  TimeOfDay fromTime;
  TimeOfDay tillTime;
  TimeOfDay deliverFromTime;
  TimeOfDay deliverTillTime;

  String activeFrom;
  String activeTill;
  List<String> _days = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  List<int> deliveryTemp;
  bool _isCheckedPickUp;
  bool _isCheckedDelivery;

  @override
  void initState() {
    super.initState();

    deliveryTemp = [
      widget.store.deliveryDetails.availableOptions[0],
      widget.store.deliveryDetails.availableOptions[1]
    ];
    _isCheckedDelivery =
        widget.store.deliveryDetails.availableOptions[0] == 1 ? true : false;
    _isCheckedPickUp =
        widget.store.deliveryDetails.availableOptions[1] == 2 ? true : false;

    fromTime = TimeOfDay(
        hour: int.parse(widget.store.activeFrom.split(":")[0]),
        minute: int.parse(widget.store.activeFrom.split(":")[1]));
    tillTime = TimeOfDay(
        hour: int.parse(widget.store.activeTill.split(":")[0]),
        minute: int.parse(widget.store.activeTill.split(":")[1]));

    deliverFromTime = TimeOfDay(
        hour:
            int.parse(widget.store.deliveryDetails.deliveryFrom.split(":")[0]),
        minute:
            int.parse(widget.store.deliveryDetails.deliveryFrom.split(":")[1]));
    deliverTillTime = TimeOfDay(
        hour:
            int.parse(widget.store.deliveryDetails.deliveryTill.split(":")[0]),
        minute:
            int.parse(widget.store.deliveryDetails.deliveryTill.split(":")[1]));

    activeFrom = '${fromTime.hour}:${fromTime.minute}';
    activeTill = '${tillTime.hour}:${tillTime.minute}';
    deliverFrom = '${deliverFromTime.hour}:${deliverFromTime.minute}';
    deliverTill = '${deliverTillTime.hour}:${deliverTillTime.minute}';

    ownedBy = cachedLocalUser.firstName + cachedLocalUser.lastName;
  }

  @override
  Widget build(BuildContext context) {
    Widget getProductTypes(BuildContext context) {
      return StreamBuilder<QuerySnapshot>(
        stream: ProductTypes().streamProductTypes(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          Widget children;

          if (snapshot.hasData) {
            if (snapshot.data.documents.isNotEmpty) {
              children = ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  ProductTypes types = ProductTypes.fromJson(
                      snapshot.data.documents[index].data);
                  return InkWell(
                    onTap: () {
                      if (availProducts.contains(types.uuid)) {
                        setState(() {
                          availProducts.remove(types.uuid);
                        });
                      } else {
                        setState(() {
                          availProducts.add(types.uuid);
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      color: availProducts.contains(types.uuid)
                          ? CustomColors.blue
                          : CustomColors.white,
                      height: 40,
                      width: 50,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        types.name,
                        style: TextStyle(
                            fontFamily: "Georgia",
                            color: availProducts.contains(types.uuid)
                                ? CustomColors.white
                                : CustomColors.green),
                      ),
                    ),
                  );
                },
              );
            } else {
              children = Container(
                height: 90,
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    Text(
                      "No Product Types Available",
                      style: TextStyle(
                        color: CustomColors.alertRed,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(
                      flex: 2,
                    ),
                    Text(
                      "Sorry. Please Try Again Later!",
                      style: TextStyle(
                        color: CustomColors.blue,
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

    _pickDeliverFromTime() async {
      TimeOfDay t =
          await showTimePicker(context: context, initialTime: deliverFromTime);
      if (t != null)
        setState(() {
          deliverFromTime = t;
          deliverFrom = '${t.hour}:${t.minute}';
        });
    }

    _pickDeliverTillTime() async {
      TimeOfDay t =
          await showTimePicker(context: context, initialTime: deliverTillTime);
      if (t != null)
        setState(() {
          deliverTillTime = t;
          deliverTill = '${t.hour}:${t.minute}';
        });
    }

    _pickTillTime() async {
      TimeOfDay t =
          await showTimePicker(context: context, initialTime: tillTime);
      if (t != null)
        setState(() {
          tillTime = t;
          activeTill = '${t.hour}:${t.minute}';
        });
    }

    _pickFromTime() async {
      TimeOfDay t =
          await showTimePicker(context: context, initialTime: fromTime);
      if (t != null)
        setState(() {
          fromTime = t;
          activeFrom = '${t.hour}:${t.minute}';
        });
    }

    Widget getProductCategories(BuildContext context) {
      return FutureBuilder<List<ProductCategories>>(
        future: ProductCategories().getCategoriesForTypes(availProducts),
        builder: (BuildContext context,
            AsyncSnapshot<List<ProductCategories>> snapshot) {
          Widget children;

          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              children = ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  ProductCategories categories = snapshot.data[index];
                  return InkWell(
                    onTap: () {
                      if (availProductCategories.contains(categories.uuid)) {
                        setState(() {
                          availProductCategories.remove(categories.uuid);
                          productCategories.remove(categories);
                        });
                      } else {
                        setState(() {
                          availProductCategories.add(categories.uuid);
                          productCategories.add(categories);
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      color: availProductCategories.contains(categories.uuid)
                          ? CustomColors.blue
                          : CustomColors.white,
                      height: 40,
                      width: 50,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        categories.name,
                        style: TextStyle(
                            fontFamily: "Georgia",
                            color:
                                availProductCategories.contains(categories.uuid)
                                    ? CustomColors.white
                                    : CustomColors.green),
                      ),
                    ),
                  );
                },
              );
            } else {
              children = Container(
                height: 90,
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    Text(
                      "No Product Categories Available",
                      style: TextStyle(
                        color: CustomColors.alertRed,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(
                      flex: 2,
                    ),
                    Text(
                      "Sorry. Please Try Again Later!",
                      style: TextStyle(
                        color: CustomColors.blue,
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

    Widget getDeliveryDetails() {
      return Card(
        color: CustomColors.lightGrey,
        elevation: 5.0,
        margin: EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 40,
              alignment: Alignment.center,
              child: Text(
                "Delivery Details",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Georgia",
                  fontWeight: FontWeight.bold,
                  color: CustomColors.blue,
                ),
              ),
            ),
            Divider(
              color: CustomColors.blue,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.0, top: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ListTile(
                          title: Text("${deliverFromTime.format(context)}"),
                          trailing: Icon(Icons.keyboard_arrow_down),
                          onTap: () async {
                            await _pickDeliverFromTime();
                          },
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "--",
                    style: TextStyle(
                      fontFamily: "Georgia",
                      color: CustomColors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: ListTile(
                      title: Text("${deliverTillTime.format(context)}"),
                      trailing: Icon(Icons.keyboard_arrow_down),
                      onTap: () async {
                        await _pickDeliverTillTime();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: Text("Delivery from Store"),
                          value: _isCheckedDelivery,
                          onChanged: (val) {
                            setState(() {
                              _isCheckedDelivery = val;
                              if (_isCheckedDelivery) {
                                deliveryTemp[0] = 1;
                              } else {
                                deliveryTemp[0] = 0;
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: Text("Pickup from Store"),
                          value: _isCheckedPickUp,
                          onChanged: (val) {
                            setState(() {
                              _isCheckedPickUp = val;
                              if (_isCheckedDelivery) {
                                deliveryTemp[1] = 2;
                              } else {
                                deliveryTemp[1] = 0;
                              }
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
                      initialValue:
                          widget.store.deliveryDetails.maxDistance.toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        labelText: "Max Distance",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          fontSize: 10.0,
                          color: CustomColors.blue,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: CustomColors.lightGreen)),
                        fillColor: CustomColors.white,
                        filled: true,
                      ),
                      validator: (maxDistance) {
                        if (maxDistance.trim() != "" &&
                            maxDistance.isNotEmpty) {
                          this.maxDistance = int.parse(maxDistance);
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: widget
                          .store.deliveryDetails.deliveryCharges02
                          .toString(),
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        labelText: "Delivery Charge 2km",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          fontSize: 10.0,
                          color: CustomColors.blue,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: CustomColors.lightGreen)),
                        fillColor: CustomColors.white,
                        filled: true,
                      ),
                      validator: (delivery2Km) {
                        if (delivery2Km.trim() != "" &&
                            delivery2Km.isNotEmpty) {
                          this.deliveryCharge2 = double.parse(delivery2Km);
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 5)),
                  Flexible(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: widget
                          .store.deliveryDetails.deliveryCharges05
                          .toString(),
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        labelText: "Delivery Charge 5km",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          fontSize: 10.0,
                          color: CustomColors.blue,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: CustomColors.lightGreen)),
                        fillColor: CustomColors.white,
                        filled: true,
                      ),
                      validator: (delivery5Km) {
                        if (delivery5Km.trim() != "" &&
                            delivery5Km.isNotEmpty) {
                          this.deliveryCharge5 = double.parse(delivery5Km);
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: widget
                          .store.deliveryDetails.deliveryCharges10
                          .toString(),
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        labelText: "Delivery Charge 10km",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          fontSize: 10.0,
                          color: CustomColors.blue,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: CustomColors.lightGreen)),
                        fillColor: CustomColors.white,
                        filled: true,
                      ),
                      validator: (delivery10Km) {
                        if (delivery10Km.trim() != "" &&
                            delivery10Km.isNotEmpty) {
                          this.deliveryCharge10 = double.parse(delivery10Km);
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 5)),
                  Flexible(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: widget
                          .store.deliveryDetails.deliveryChargesMax
                          .toString(),
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        labelText: "Delivery Charge Max",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          fontSize: 10.0,
                          color: CustomColors.blue,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: CustomColors.lightGreen)),
                        fillColor: CustomColors.white,
                        filled: true,
                      ),
                      validator: (deliveryMax) {
                        if (deliveryMax.trim() != "") {
                          this.deliveryChargeMax = double.parse(deliveryMax);
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget getProductSubCategories(BuildContext context) {
      return FutureBuilder<List<ProductSubCategories>>(
        future: ProductSubCategories().getSubCategories(productCategories),
        builder: (BuildContext context,
            AsyncSnapshot<List<ProductSubCategories>> snapshot) {
          Widget children;

          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              children = ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  ProductSubCategories categories = snapshot.data[index];
                  return InkWell(
                    onTap: () {
                      if (availProductSubCategories.contains(categories.uuid)) {
                        setState(() {
                          availProductSubCategories.remove(categories.uuid);
                        });
                      } else {
                        setState(() {
                          availProductSubCategories.add(categories.uuid);
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      color: availProductSubCategories.contains(categories.uuid)
                          ? CustomColors.blue
                          : CustomColors.white,
                      height: 40,
                      width: 50,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        categories.name,
                        style: TextStyle(
                            fontFamily: "Georgia",
                            color: availProductSubCategories
                                    .contains(categories.uuid)
                                ? CustomColors.white
                                : CustomColors.green),
                      ),
                    ),
                  );
                },
              );
            } else {
              children = Container(
                height: 90,
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    Text(
                      "No Product SubCategories Available",
                      style: TextStyle(
                        color: CustomColors.alertRed,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(
                      flex: 2,
                    ),
                    Text(
                      "Sorry. Please Try Again Later!",
                      style: TextStyle(
                        color: CustomColors.blue,
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Edit Store",
        ),
        backgroundColor: CustomColors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.blue,
        onPressed: () {
          final FormState form = _formKey.currentState;

          if (form.validate()) {
            if (widget.store.availProducts.length == 0) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar(
                    "Please Select your available products!", 2),
              );
              return;
            }
            if (widget.store.workingDays.length == 0) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar(
                    "Please Set your working days!", 2),
              );
              return;
            }
            if (widget.store.address.pincode == null ||
                widget.store.address.pincode.isEmpty) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar("Please enter your PINCODE!", 2),
              );
              return;
            }
            Store store = widget.store;
            // StoreContacts contacts = widget.store.contacts;
            // contacts.contactName = cachedLocalUser.firstName;
            // contacts.contactNumber = cachedLocalUser.mobileNumber;
            // contacts.countryCode = cachedLocalUser.countryCode;
            // contacts.isActive = true;
            // contacts.isVerfied = true;

            store.name = widget.store.name;
            store.ownedBy = widget.store.ownedBy;
            store.users = [cachedLocalUser.getIntID()];
            store.availProducts = widget.store.availProducts;
            store.availProductCategories = widget.store.availProductCategories;
            store.availProductSubCategories =
                widget.store.availProductSubCategories;
            store.activeFrom = widget.store.activeFrom;
            store.activeTill = widget.store.activeTill;
            store.address = widget.store.address;
            store.workingDays = widget.store.workingDays;
            //store.contacts = [contacts];

            store.deliveryDetails = widget.store.deliveryDetails;
            store.deliveryDetails.deliveryFrom =
                widget.store.deliveryDetails.deliveryFrom;
            store.deliveryDetails.deliveryTill =
                widget.store.deliveryDetails.deliveryTill;
            store.deliveryDetails.maxDistance =
                widget.store.deliveryDetails.maxDistance;
            store.deliveryDetails.deliveryCharges02 =
                widget.store.deliveryDetails.deliveryCharges02;
            store.deliveryDetails.deliveryCharges05 =
                widget.store.deliveryDetails.deliveryCharges05;
            store.deliveryDetails.deliveryCharges10 =
                widget.store.deliveryDetails.deliveryCharges10;
            store.deliveryDetails.deliveryChargesMax =
                widget.store.deliveryDetails.deliveryChargesMax;

            StoreUserAccess userAccess = StoreUserAccess();
            userAccess.positionName = "Owner";
            userAccess.userNumber = cachedLocalUser.getIntID();
            userAccess.accessLevel = [0];
            store.users = [cachedLocalUser.getIntID()];
            store.usersAccess = [userAccess];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditLocationPicker(widget.store),
                settings: RouteSettings(name: '/settings/store/add/location'),
              ),
            );
          } else {
            _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar("Please fill valid data!", 2));
          }
        },
        label: Text(
          "Update Location",
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
                      color: CustomColors.blue,
                    ),
                  ),
                ),
                Divider(
                  color: CustomColors.green,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      AppLocalizations.of(context).translate('store_name'),
                      style: TextStyle(
                          fontFamily: "Georgia",
                          color: CustomColors.grey,
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
                    initialValue: widget.store.name,
                    decoration: InputDecoration(
                      fillColor: CustomColors.white,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.grey)),
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
                          color: CustomColors.grey,
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
                      fillColor: CustomColors.white,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.grey)),
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
                          color: CustomColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10, right: 10),
                  child: Container(
                    height: 300,
                    color: CustomColors.grey,
                    child: getProductTypes(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Product Categories",
                      style: TextStyle(
                          fontFamily: "Georgia",
                          color: CustomColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10, right: 10),
                  child: Container(
                    height: 300,
                    color: CustomColors.grey,
                    child: getProductCategories(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Product Sub Categories",
                      style: TextStyle(
                          fontFamily: "Georgia",
                          color: CustomColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10, right: 10),
                  child: Container(
                    height: 300,
                    color: CustomColors.grey,
                    child: getProductSubCategories(context),
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
                          color: CustomColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10, right: 10),
                  child: Container(
                    height: 200,
                    color: CustomColors.grey,
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
                            color: widget.store.workingDays.contains(index)
                                ? CustomColors.blue
                                : CustomColors.white,
                            height: 40,
                            width: 50,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _d,
                              style: TextStyle(
                                  fontFamily: "Georgia",
                                  color: widget.store.workingDays.contains(index)
                                      ? CustomColors.white
                                      : CustomColors.green),
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
                          color: CustomColors.grey,
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
                          color: CustomColors.green,
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
                  child: AddressWidget(
                      "Store Address", widget.store.address, updateAddress),
                ),
                getDeliveryDetails(),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
