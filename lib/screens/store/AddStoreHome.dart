import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/app_localizations.dart';
import 'package:chipchop_seller/db/models/address.dart';
import 'package:chipchop_seller/db/models/delivery_details.dart';
import 'package:chipchop_seller/db/models/product_categories.dart';
import 'package:chipchop_seller/db/models/product_sub_categories.dart';
import 'package:chipchop_seller/db/models/product_types.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/db/models/store_contacts.dart';
import 'package:chipchop_seller/db/models/store_user_access.dart';
import 'package:chipchop_seller/screens/store/LocationPicker.dart';
import 'package:chipchop_seller/screens/utils/AddressWidget.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:chipchop_seller/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_seller/screens/utils/ImageView.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:chipchop_seller/services/storage/image_uploader.dart';
import 'package:chipchop_seller/services/storage/storage_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class AddNewStoreHome extends StatefulWidget {
  @override
  _AddNewStoreHomeState createState() => _AddNewStoreHomeState();
}

class _AddNewStoreHomeState extends State<AddNewStoreHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> imagePaths = [];
  Address sAddress = Address();
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
  List<String> availProductSubCategories = [];
  List<int> workingDays = [1, 2, 3, 4, 5];
  TimeOfDay fromTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay tillTime = TimeOfDay(hour: 18, minute: 0);
  TimeOfDay deliverFromTime = TimeOfDay(hour: 09, minute: 00);
  TimeOfDay deliverTillTime = TimeOfDay(hour: 18, minute: 00);
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

  List<int> deliveryTemp = [0, 1, 2, 3];
  bool _isCheckedPickUp;
  bool _isCheckedInstant;
  bool _isCheckedSameDay;
  bool _isCheckedScheduled;
  List<int> paymentOptions = [0, 1];
  bool _isCheckedCash;
  bool _isCheckedGpay;
  bool _isCheckedCard;
  bool _isCheckedPaytm;

  @override
  void initState() {
    super.initState();

    _isCheckedPickUp = true;
    _isCheckedInstant = true;
    _isCheckedSameDay = true;
    _isCheckedScheduled = true;

    _isCheckedCash = true;
    _isCheckedGpay = true;
    _isCheckedCard = false;
    _isCheckedPaytm = false;

    activeFrom = '${fromTime.hour}:${fromTime.minute}';
    activeTill = '${tillTime.hour}:${tillTime.minute}';
    deliverFrom = '${deliverFromTime.hour}:${deliverFromTime.minute}';
    deliverTill = '${deliverTillTime.hour}:${deliverTillTime.minute}';

    ownedBy = cachedLocalUser.firstName + cachedLocalUser.lastName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('create_new_store'),
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.alertRed,
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
            if (paymentOptions.length == 0) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar(
                    "Please Select atlease one Payment Option!", 2),
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
            StoreContacts contacts = StoreContacts();
            contacts.contactName = cachedLocalUser.firstName;
            contacts.contactNumber = cachedLocalUser.getID();
            contacts.isActive = true;
            contacts.isVerfied = true;

            store.name = this.storeName;
            store.ownedBy = this.ownedBy;
            store.users = [cachedLocalUser.getIntID()];
            store.availablePayments = paymentOptions;
            store.storeImages = imagePaths;
            store.availProducts = this.availProducts;
            store.availProductCategories = this.availProductCategories;
            store.availProductSubCategories = this.availProductSubCategories;
            store.activeFrom = activeFrom;
            store.activeTill = activeTill;
            store.address = sAddress;
            store.workingDays = workingDays;
            store.contacts = [contacts];

            store.deliveryDetails = DeliveryDetails();
            store.deliveryDetails.deliveryFrom = this.deliverFrom;
            store.deliveryDetails.deliveryTill = this.deliverTill;
            store.deliveryDetails.maxDistance = this.maxDistance;
            store.deliveryDetails.deliveryCharges02 = this.deliveryCharge2;
            store.deliveryDetails.deliveryCharges05 = this.deliveryCharge5;
            store.deliveryDetails.deliveryCharges10 = this.deliveryCharge10;
            store.deliveryDetails.deliveryChargesMax = this.deliveryChargeMax;
            store.deliveryDetails.availableOptions = this.deliveryTemp;

            StoreUserAccess userAccess = StoreUserAccess();
            userAccess.positionName = "Owner";
            userAccess.userNumber = cachedLocalUser.getIntID();
            userAccess.accessLevel = [0];
            store.users = [cachedLocalUser.getIntID()];
            store.usersAccess = [userAccess];
            store.isActive = false;

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
        label: Text(
          AppLocalizations.of(context).translate('button_next'),
        ),
        icon: Icon(Icons.arrow_forward_ios),
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
                    initialValue: storeName,
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
                  padding: EdgeInsets.only(top: 10),
                  child: ListTile(
                    title: Text(
                      "Store Images",
                      style: TextStyle(
                          fontFamily: "Georgia",
                          color: CustomColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    trailing: Container(
                      alignment: Alignment.centerRight,
                      width: 175,
                      child: FlatButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        color: CustomColors.grey,
                        onPressed: () async {
                          String imageUrl = '';
                          try {
                            ImagePicker imagePicker = ImagePicker();
                            PickedFile pickedFile;

                            pickedFile = await imagePicker.getImage(
                                source: ImageSource.gallery);
                            if (pickedFile == null) return;

                            String fileName = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            String fbFilePath =
                                'store_profile/${cachedLocalUser.getID()}/$fileName.png';
                            CustomDialogs.actionWaiting(context);
                            // Upload to storage
                            imageUrl = await Uploader().uploadImageFile(
                                true, pickedFile.path, fbFilePath);
                            Navigator.of(context).pop();
                          } catch (err) {
                            Fluttertoast.showToast(
                                msg: 'This file is not an image');
                          }
                          if (imageUrl != "")
                            setState(() {
                              imagePaths.add(imageUrl);
                            });
                        },
                        label: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 15.0,
                          ),
                          child: Text(
                            "Pick Image",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: "Georgia",
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        icon: Icon(FontAwesomeIcons.images),
                      ),
                    ),
                  ),
                ),
                imagePaths.length > 0
                    ? GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.95,
                        shrinkWrap: true,
                        primary: false,
                        mainAxisSpacing: 10,
                        children: List.generate(
                          imagePaths.length,
                          (index) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 5),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ImageView(
                                            url: imagePaths[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: CachedNetworkImage(
                                          imageUrl: imagePaths[index],
                                          imageBuilder:
                                              (context, imageProvider) => Image(
                                            fit: BoxFit.fill,
                                            image: imageProvider,
                                          ),
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Center(
                                            child: SizedBox(
                                              height: 50.0,
                                              width: 50.0,
                                              child: CircularProgressIndicator(
                                                  value:
                                                      downloadProgress.progress,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          CustomColors.blue),
                                                  strokeWidth: 2.0),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.error,
                                            size: 35,
                                          ),
                                          fadeOutDuration: Duration(seconds: 1),
                                          fadeInDuration: Duration(seconds: 2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CustomColors.alertRed,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: InkWell(
                                      child: Icon(
                                        Icons.close,
                                        size: 25,
                                        color: CustomColors.white,
                                      ),
                                      onTap: () async {
                                        CustomDialogs.actionWaiting(context);
                                        bool res = await StorageUtils()
                                            .removeFile(imagePaths[index]);
                                        Navigator.of(context).pop();
                                        if (res)
                                          setState(() {
                                            imagePaths
                                                .remove(imagePaths[index]);
                                          });
                                        else
                                          Fluttertoast.showToast(
                                              msg: 'Unable to remove image');
                                      },
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Store Type",
                      style: TextStyle(
                          fontFamily: "Georgia",
                          color: CustomColors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 10, right: 10),
                  child: Container(
                    height: 200,
                    child: getProductTypes(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Categories",
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
                    child: getProductCategories(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.0, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Sub Categories",
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
                            color: workingDays.contains(index)
                                ? CustomColors.alertRed
                                : CustomColors.white,
                            height: 40,
                            width: 50,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _d,
                              style: TextStyle(
                                  fontFamily: "Georgia",
                                  color: workingDays.contains(index)
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
                          color: CustomColors.black,
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
                getPaymentDetails(),
                getDeliveryDetails(),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                ProductTypes types =
                    ProductTypes.fromJson(snapshot.data.documents[index].data);
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
                        ? CustomColors.alertRed
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
                    "No Store Types Available",
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
                      });
                    } else {
                      setState(() {
                        availProductCategories.add(categories.uuid);
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: availProductCategories.contains(categories.uuid)
                        ? CustomColors.alertRed
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
            children = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Select Your Store Type",
                    style: TextStyle(
                      color: CustomColors.alertRed,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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

  Widget getPaymentDetails() {
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
              "Accepted Payments",
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
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                Flexible(
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text("Cash"),
                        value: _isCheckedCash,
                        onChanged: (val) {
                          setState(() {
                            _isCheckedCash = val;
                            if (_isCheckedCash) {
                              paymentOptions.add(0);
                            } else {
                              paymentOptions.remove(0);
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
                        title: Text("Google Pay"),
                        value: _isCheckedGpay,
                        onChanged: (val) {
                          setState(() {
                            _isCheckedGpay = val;
                            if (_isCheckedGpay) {
                              paymentOptions.add(1);
                            } else {
                              paymentOptions.remove(1);
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
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                Flexible(
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text("Card Payments"),
                        value: _isCheckedCard,
                        onChanged: (val) {
                          setState(() {
                            _isCheckedCard = val;
                            if (_isCheckedCard) {
                              paymentOptions.add(2);
                            } else {
                              paymentOptions.remove(2);
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
                        title: Text("Paytm"),
                        value: _isCheckedPaytm,
                        onChanged: (val) {
                          setState(() {
                            _isCheckedPaytm = val;
                            if (_isCheckedPaytm) {
                              paymentOptions.add(3);
                            } else {
                              paymentOptions.remove(3);
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
        ],
      ),
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
                    color: CustomColors.black,
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
                        title: Text("Pickup from Store"),
                        value: _isCheckedPickUp,
                        onChanged: (val) {
                          setState(() {
                            _isCheckedPickUp = val;
                            if (_isCheckedPickUp) {
                              deliveryTemp.add(0);
                            } else {
                              deliveryTemp.remove(0);
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
                        title: Text("Instant Delivery from Store"),
                        value: _isCheckedInstant,
                        onChanged: (val) {
                          setState(() {
                            _isCheckedInstant = val;
                            if (_isCheckedInstant) {
                              deliveryTemp.add(1);
                            } else {
                              deliveryTemp.remove(1);
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
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                Flexible(
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text("Same-Day Delivery from Store"),
                        value: _isCheckedSameDay,
                        onChanged: (val) {
                          setState(() {
                            _isCheckedSameDay = val;
                            if (_isCheckedSameDay) {
                              deliveryTemp.add(2);
                            } else {
                              deliveryTemp.remove(2);
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
                        title: Text("Scheduled Delivery from Store"),
                        value: _isCheckedScheduled,
                        onChanged: (val) {
                          setState(() {
                            _isCheckedScheduled = val;
                            if (_isCheckedScheduled) {
                              deliveryTemp.add(3);
                            } else {
                              deliveryTemp.remove(3);
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
                    initialValue: maxDistance.toString(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      labelText: "Max Distance",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        fontSize: 10.0,
                        color: CustomColors.blue,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.lightGreen)),
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                    validator: (maxDistance) {
                      if (maxDistance.trim() != "" && maxDistance.isNotEmpty) {
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
                    initialValue: deliveryCharge2.toString(),
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      labelText: "Delivery Charge 2km",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        fontSize: 10.0,
                        color: CustomColors.blue,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.lightGreen)),
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                    validator: (delivery2Km) {
                      if (delivery2Km.trim() != "" && delivery2Km.isNotEmpty) {
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
                    initialValue: deliveryCharge5.toString(),
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      labelText: "Delivery Charge 5km",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        fontSize: 10.0,
                        color: CustomColors.blue,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.lightGreen)),
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                    validator: (delivery5Km) {
                      if (delivery5Km.trim() != "" && delivery5Km.isNotEmpty) {
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
                    initialValue: deliveryCharge10.toString(),
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      labelText: "Delivery Charge 10km",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        fontSize: 10.0,
                        color: CustomColors.blue,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
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
                    initialValue: deliveryChargeMax.toString(),
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      labelText: "Delivery Charge Max",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        fontSize: 10.0,
                        color: CustomColors.blue,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
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
      future: ProductSubCategories().getSubCategories(availProductCategories),
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
                        ? CustomColors.alertRed
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
            children = Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Select Available Categories",
                    style: TextStyle(
                      color: CustomColors.alertRed,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

  _pickFromTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: fromTime);
    if (t != null)
      setState(() {
        fromTime = t;
        activeFrom = '${t.hour}:${t.minute}';
      });
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

  _pickTillTime() async {
    TimeOfDay t =
        await showTimePicker(context: context, initialTime: deliverTillTime);
    if (t != null)
      setState(() {
        tillTime = t;
        activeTill = '${t.hour}:${t.minute}';
      });
  }

  _pickDeliverTillTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: tillTime);
    if (t != null)
      setState(() {
        deliverTillTime = t;
        deliverTill = '${t.hour}:${t.minute}';
      });
  }
}
