import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:chipchop_seller/app_localizations.dart';
import 'package:chipchop_seller/db/models/address.dart';
import 'package:chipchop_seller/db/models/delivery_details.dart';
import 'package:chipchop_seller/db/models/product_categories.dart';
import 'package:chipchop_seller/db/models/product_categories_map.dart';
import 'package:chipchop_seller/db/models/product_sub_categories.dart';
import 'package:chipchop_seller/db/models/product_types.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/db/models/store_contacts.dart';
import 'package:chipchop_seller/db/models/store_user_access.dart';
import 'package:chipchop_seller/screens/app/TakePicturePage.dart';
import 'package:chipchop_seller/screens/store/LocationPicker.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:chipchop_seller/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_seller/screens/utils/ImageView.dart';
import 'package:chipchop_seller/screens/utils/MultiSelectDialog.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:chipchop_seller/services/storage/image_uploader.dart';
import 'package:chipchop_seller/services/storage/storage_utils.dart';
import 'package:chipchop_seller/services/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AddNewStoreHome extends StatefulWidget {
  @override
  _AddNewStoreHomeState createState() => _AddNewStoreHomeState();
}

class _AddNewStoreHomeState extends State<AddNewStoreHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> imagePaths = [no_image_placeholder];
  String primaryImage = no_image_placeholder;

  Address updatedAddress = Address();
  String storeName = '';
  String shortDetails = '';
  String ownedBy = '';

  List<ProductCategoriesMap> availProducts = [];
  List<ProductCategoriesMap> availProductCategories = [];
  List<ProductCategoriesMap> availProductSubCategories = [];

  @override
  void initState() {
    super.initState();

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
        backgroundColor: CustomColors.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: InkWell(
        onTap: () {
          final FormState form = _formKey.currentState;

          if (form.validate()) {
            if (availProducts.length == 0) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar(
                    "Please Select your Store Product Type!", 2),
              );
              return;
            }

            if (availProductCategories.length == 0) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar(
                    "Please Select Store Categories!", 2),
              );
              return;
            }

            if (availProductSubCategories.length == 0) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar(
                    "Please Select Store Sub-Categories!", 2),
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
            store.shortDetails = this.shortDetails;
            store.ownedBy = this.ownedBy;
            store.users = [cachedLocalUser.getID()];
            store.image = primaryImage;
            store.storeImages = imagePaths;
            store.availProducts = this.availProducts;
            store.availProductCategories = this.availProductCategories;
            store.availProductSubCategories = this.availProductSubCategories;
            store.address = updatedAddress;
            store.contacts = [contacts];

            StoreUserAccess userAccess = StoreUserAccess();
            userAccess.positionName = "Owner";
            userAccess.userNumber = cachedLocalUser.getID();
            userAccess.accessLevel = [0];
            store.usersAccess = [userAccess];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddStoreStepTwo(store),
                settings: RouteSettings(name: '/settings/store/add/'),
              ),
            );
          } else {
            _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar("Please fill valid data!", 2));
          }
        },
        child: Container(
          height: 40,
          width: 120,
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: CustomColors.primary,
              border: Border.all(color: CustomColors.black),
              borderRadius: BorderRadius.circular(10.0)),
          child: Text(
            "Continue",
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10.0, top: 10),
                    height: 40,
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Tell us About Your Business",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CustomColors.alertRed,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 10),
                    child: Text(
                      "Store / Business Name",
                      style: TextStyle(color: CustomColors.black, fontSize: 14),
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
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 5.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: CustomColors.grey)),
                      ),
                      validator: (name) {
                        if (name.isEmpty) {
                          return "Enter Store Name";
                        } else {
                          this.storeName = name.trim();
                          return null;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 10),
                    child: Text(
                      "Short Description",
                      style: TextStyle(color: CustomColors.black, fontSize: 14),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                    child: TextFormField(
                      autofocus: false,
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.start,
                      initialValue: shortDetails,
                      maxLines: 3,
                      decoration: InputDecoration(
                        fillColor: CustomColors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 1.0, horizontal: 5.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: CustomColors.grey)),
                      ),
                      validator: (desc) {
                        if (desc.isEmpty) {
                          this.shortDetails = "";
                        } else {
                          this.shortDetails = desc.trim();
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: ListTile(
                      leading: Text(
                        "Store Images",
                        style:
                            TextStyle(color: CustomColors.black, fontSize: 14),
                      ),
                      title: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.green[300],
                            borderRadius: BorderRadius.circular(5.0)),
                        child: InkWell(
                          onTap: () async {
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
                                  msg: 'This file is not an image',
                                  backgroundColor: CustomColors.alertRed,
                                  textColor: CustomColors.black);
                            }
                            if (imageUrl != "")
                              setState(() {
                                imagePaths.add(imageUrl);
                              });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.fileUpload,
                                size: 20,
                                color: CustomColors.black,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Upload",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      trailing: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.green[300],
                            borderRadius: BorderRadius.circular(5.0)),
                        child: InkWell(
                          onTap: () async {
                            String imageUrl = '';
                            try {
                              String tempPath =
                                  (await getTemporaryDirectory()).path;
                              String filePath = '$tempPath/chipchop_image.png';
                              if (File(filePath).existsSync())
                                await File(filePath).delete();

                              List<CameraDescription> cameras =
                                  await availableCameras();
                              CameraDescription camera = cameras.first;

                              var result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TakePicturePage(
                                    camera: camera,
                                    path: filePath,
                                  ),
                                ),
                              );
                              if (result != null) {
                                String fileName = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                String fbFilePath =
                                    'store_profile/${cachedLocalUser.getID()}/$fileName.png';
                                CustomDialogs.actionWaiting(context);
                                // Upload to storage
                                imageUrl = await Uploader()
                                    .uploadImageFile(true, result, fbFilePath);
                                Navigator.of(context).pop();
                              }
                            } catch (err) {
                              Fluttertoast.showToast(
                                  msg: 'This file is not an image',
                                  backgroundColor: CustomColors.alertRed,
                                  textColor: CustomColors.white);
                            }
                            if (imageUrl != "")
                              setState(() {
                                imagePaths.add(imageUrl);
                              });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FontAwesomeIcons.cameraRetro,
                                size: 20,
                                color: CustomColors.black,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Capture",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  imagePaths.length > 0
                      ? SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            primary: true,
                            shrinkWrap: true,
                            itemCount: imagePaths.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                child: Stack(
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
                                                  (context, imageProvider) =>
                                                      Image(
                                                fit: BoxFit.fill,
                                                height: 150,
                                                width: 150,
                                                image: imageProvider,
                                              ),
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      Center(
                                                child: SizedBox(
                                                  height: 50.0,
                                                  width: 50.0,
                                                  child: CircularProgressIndicator(
                                                      value: downloadProgress
                                                          .progress,
                                                      valueColor:
                                                          AlwaysStoppedAnimation(
                                                              CustomColors
                                                                  .black),
                                                      strokeWidth: 2.0),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                Icons.error,
                                                size: 35,
                                              ),
                                              fadeOutDuration:
                                                  Duration(seconds: 1),
                                              fadeInDuration:
                                                  Duration(seconds: 2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 10,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: CustomColors.alertRed,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: InkWell(
                                          child: Icon(
                                            Icons.close,
                                            size: 25,
                                            color: CustomColors.white,
                                          ),
                                          onTap: () async {
                                            if (primaryImage ==
                                                imagePaths[index]) {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      'You cannot remove Primary Image');

                                              return;
                                            }

                                            if (imagePaths[index] ==
                                                no_image_placeholder) {
                                              setState(() {
                                                imagePaths.remove(
                                                    no_image_placeholder);
                                              });
                                              return;
                                            }
                                            CustomDialogs.actionWaiting(
                                                context);
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
                                                  msg:
                                                      'Unable to remove image');
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      left: 8,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: CustomColors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: InkWell(
                                          child: Icon(
                                            primaryImage == imagePaths[index]
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            size: 25,
                                            color: CustomColors.primary,
                                          ),
                                          onTap: () async {
                                            setState(() {
                                              primaryImage = imagePaths[index];
                                            });
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                          child: Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: CachedNetworkImage(
                                imageUrl: primaryImage,
                                imageBuilder: (context, imageProvider) => Image(
                                  fit: BoxFit.fill,
                                  image: imageProvider,
                                ),
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
                                  child: SizedBox(
                                    height: 50.0,
                                    width: 50.0,
                                    child: CircularProgressIndicator(
                                        value: downloadProgress.progress,
                                        valueColor: AlwaysStoppedAnimation(
                                            CustomColors.black),
                                        strokeWidth: 2.0),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  size: 35,
                                ),
                                fadeOutDuration: Duration(seconds: 1),
                                fadeInDuration: Duration(seconds: 2),
                              ),
                            ),
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 10),
                    child: Text(
                      "Store Product Types",
                      style: TextStyle(color: CustomColors.black, fontSize: 14),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 10, right: 10),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all()),
                      child: getProductTypes(context),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 10),
                    child: Text(
                      "Select Store Categories",
                      style: TextStyle(color: CustomColors.black, fontSize: 14),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 10, right: 10),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all()),
                      child: getProductCategories(context),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 10),
                    child: Text(
                      "Select Sub-Categories",
                      style: TextStyle(color: CustomColors.black, fontSize: 14),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, top: 10, right: 10),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all()),
                      child: getProductSubCategories(context),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 40,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Address",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: TextFormField(
                                    initialValue: updatedAddress.street,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)
                                          .translate('building_and_street'),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      labelStyle: TextStyle(
                                        fontSize: 12.0,
                                        color: CustomColors.black,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 10.0),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CustomColors.lightGreen)),
                                      fillColor: CustomColors.white,
                                      filled: true,
                                    ),
                                    validator: (street) {
                                      if (street.trim().isEmpty) {
                                        return "Enter your Street";
                                      } else {
                                        updatedAddress.street = street.trim();
                                        return null;
                                      }
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
                                    initialValue: updatedAddress.landmark,
                                    textAlign: TextAlign.start,
                                    decoration: InputDecoration(
                                      labelText: "Landmark",
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      labelStyle: TextStyle(
                                        fontSize: 12.0,
                                        color: CustomColors.black,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 3.0, horizontal: 10.0),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CustomColors.lightGreen)),
                                      fillColor: CustomColors.white,
                                      filled: true,
                                    ),
                                    validator: (landmark) {
                                      if (landmark.trim() != "") {
                                        updatedAddress.landmark =
                                            landmark.trim();
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
                                    initialValue: updatedAddress.city,
                                    textAlign: TextAlign.start,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)
                                          .translate('city'),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      labelStyle: TextStyle(
                                        fontSize: 12.0,
                                        color: CustomColors.black,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 3.0, horizontal: 10.0),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CustomColors.lightGreen)),
                                      fillColor: CustomColors.white,
                                      filled: true,
                                    ),
                                    validator: (city) {
                                      if (city.trim().isEmpty) {
                                        return "Enter your City";
                                      } else {
                                        updatedAddress.city = city.trim();
                                        return null;
                                      }
                                    },
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(left: 5)),
                                Flexible(
                                  child: TextFormField(
                                    initialValue: updatedAddress.state,
                                    textAlign: TextAlign.start,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)
                                          .translate('state'),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      labelStyle: TextStyle(
                                        fontSize: 12.0,
                                        color: CustomColors.black,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 3.0, horizontal: 10.0),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CustomColors.lightGreen)),
                                      fillColor: CustomColors.white,
                                      filled: true,
                                    ),
                                    validator: (state) {
                                      if (state.trim().isEmpty) {
                                        return "Enter Your State";
                                      } else {
                                        updatedAddress.state = state.trim();
                                        return null;
                                      }
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
                                    initialValue: updatedAddress.pincode,
                                    textAlign: TextAlign.start,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context)
                                          .translate('pincode'),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      labelStyle: TextStyle(
                                        fontSize: 12.0,
                                        color: CustomColors.black,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 3.0, horizontal: 10.0),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CustomColors.lightGreen)),
                                      fillColor: CustomColors.white,
                                      filled: true,
                                    ),
                                    validator: (pinCode) {
                                      if (pinCode.trim().isEmpty) {
                                        return "Enter Your Pincode";
                                      } else {
                                        updatedAddress.pincode = pinCode.trim();

                                        return null;
                                      }
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
                                    initialValue:
                                        updatedAddress.country ?? "India",
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.start,
                                    decoration: InputDecoration(
                                      labelText: "Country / Region",
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      labelStyle: TextStyle(
                                        fontSize: 12.0,
                                        color: CustomColors.black,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 3.0, horizontal: 10.0),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CustomColors.lightGreen)),
                                      fillColor: CustomColors.white,
                                      filled: true,
                                    ),
                                    validator: (country) {
                                      if (country.trim().isEmpty) {
                                        updatedAddress.country = "India";
                                      } else {
                                        updatedAddress.country = country.trim();
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
                    ),
                  ),
                  SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getProductTypes(BuildContext context) {
    List<MultiSelectDialogItem> buildingDropdownItems = [];
    Map<String, ProductCategoriesMap> _productTypes = {};
    return InkWell(
      onTap: () async {
        _productTypes.clear();
        buildingDropdownItems.clear();
        CustomDialogs.actionWaiting(context);
        List<ProductTypes> data = await ProductTypes().getProductTypes();
        data.forEach((element) {
          _productTypes[element.uuid] = ProductCategoriesMap.fromJson(
              {'uuid': element.uuid, 'name': element.name});
          buildingDropdownItems
              .add(MultiSelectDialogItem(element.uuid, element.name));
        });
        Navigator.pop(context);
        final selectedValues = await showDialog<Set<String>>(
          context: context,
          builder: (BuildContext context) {
            return MultiSelectDialog(
                title: "Product Types",
                items: buildingDropdownItems,
                initialSelectedValues:
                    availProducts.map((e) => e.uuid).toSet());
          },
        );

        if (selectedValues != null) {
          availProducts.clear();
          selectedValues.forEach((element) {
            if (element != null) {
              availProducts.add(_productTypes[element]);
            }
          });

          availProductCategories.clear();
          setState(() {});
        }
      },
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(availProducts.isNotEmpty
                      ? availProducts.map((e) => e.name).toString()
                      : "")),
              Icon(
                Icons.keyboard_arrow_down,
                color: CustomColors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getProductCategories(BuildContext context) {
    Map<String, ProductCategoriesMap> _productCategories = {};
    return FutureBuilder<List<ProductCategories>>(
      future: ProductCategories()
          .getCategoriesForTypes(availProducts.map((e) => e.uuid).toList()),
      builder: (BuildContext context,
          AsyncSnapshot<List<ProductCategories>> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            List<MultiSelectDialogItem> buildingDropdownItems = [];
            _productCategories.clear();
            snapshot.data.forEach((element) {
              _productCategories[element.uuid] = ProductCategoriesMap.fromJson(
                  {'uuid': element.uuid, 'name': element.name});
              buildingDropdownItems
                  .add(MultiSelectDialogItem(element.uuid, element.name));
            });
            return InkWell(
                onTap: () async {
                  final selectedValues = await showDialog<Set<String>>(
                    context: context,
                    builder: (BuildContext context) {
                      return MultiSelectDialog(
                        title: "Product Categories",
                        items: buildingDropdownItems,
                        initialSelectedValues:
                            availProductCategories.map((e) => e.uuid).toSet(),
                      );
                    },
                  );

                  if (selectedValues != null) {
                    availProductCategories.clear();
                    selectedValues.forEach((element) {
                      if (element != null) {
                        availProductCategories.add(_productCategories[element]);
                      }
                    });
                    availProductSubCategories.clear();

                    setState(() {});
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child: Text(availProductCategories.isNotEmpty
                                ? availProductCategories
                                    .map((e) => e.name)
                                    .toString()
                                : "")),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: CustomColors.black,
                        ),
                      ],
                    ),
                  ),
                ));
          } else {
            children = Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 2),
                  Flexible(child: Text("No Categories Available !!")),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: CustomColors.black,
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

  Widget getProductSubCategories(BuildContext context) {
    Map<String, ProductCategoriesMap> _productSubCategories = {};

    return FutureBuilder<List<ProductSubCategories>>(
      future: ProductSubCategories().getSubCategoriesByIDs(
          availProductCategories.map((e) => e.uuid).toList()),
      builder: (BuildContext context,
          AsyncSnapshot<List<ProductSubCategories>> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            List<MultiSelectDialogItem> buildingDropdownItems = [];
            _productSubCategories.clear();
            snapshot.data.forEach((element) {
              _productSubCategories[element.uuid] =
                  ProductCategoriesMap.fromJson(
                      {'uuid': element.uuid, 'name': element.name});
              buildingDropdownItems
                  .add(MultiSelectDialogItem(element.uuid, element.name));
            });
            return InkWell(
              onTap: () async {
                final selectedValues = await showDialog<Set<String>>(
                  context: context,
                  builder: (BuildContext context) {
                    return MultiSelectDialog(
                      title: "Product Sub-Categories",
                      items: buildingDropdownItems,
                      initialSelectedValues:
                          availProductSubCategories.map((e) => e.uuid).toSet(),
                    );
                  },
                );

                if (selectedValues != null) {
                  availProductSubCategories.clear();
                  selectedValues.forEach((element) {
                    if (element != null) {
                      availProductSubCategories
                          .add(_productSubCategories[element]);
                    }
                  });

                  setState(() {});
                }
              },
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          child: Text(availProductSubCategories.isNotEmpty
                              ? availProductSubCategories
                                  .map((e) => e.name)
                                  .toString()
                              : "")),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: CustomColors.black,
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            children = Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 2),
                  Flexible(child: Text("No Sub-Categories Available !!")),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: CustomColors.black,
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
}

class AddStoreStepTwo extends StatefulWidget {
  AddStoreStepTwo(this.store);

  final Store store;
  @override
  _AddStoreStepTwoState createState() => _AddStoreStepTwoState();
}

class _AddStoreStepTwoState extends State<AddStoreStepTwo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Store _store;

  String deliverFrom;
  String deliverTill;
  int maxDistance = 0;
  double deliveryCharge2 = 0.00;
  double deliveryCharge5 = 0.00;
  double deliveryCharge10 = 0.00;
  double deliveryChargeMax = 0.00;

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

  List<String> workingDays = ['1', '2', '3', '4', '5'];
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

  bool deliverAnywhere = false;
  String upiID = "";
  String walletNumber = "";

  @override
  void initState() {
    super.initState();

    _store = widget.store;

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
          backgroundColor: CustomColors.primary,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: InkWell(
          onTap: () {
            final FormState form = _formKey.currentState;

            if (form.validate()) {
              if (paymentOptions.length == 0) {
                _scaffoldKey.currentState.showSnackBar(
                  CustomSnackBar.errorSnackBar(
                      "Please Select atleast one Payment Option!", 2),
                );
                return;
              }
              if (workingDays.length == 0) {
                _scaffoldKey.currentState.showSnackBar(
                  CustomSnackBar.errorSnackBar(
                      "Please Set your Business Working Days!", 2),
                );
                return;
              }

              if (!deliverAnywhere && this.maxDistance == 0) {
                _scaffoldKey.currentState.showSnackBar(
                  CustomSnackBar.errorSnackBar(
                      "Please Set your Maximum Delivery Range!", 2),
                );
                return;
              }

              _store.deliverAnywhere = this.deliverAnywhere;
              _store.upiID = upiID;
              _store.walletNumber = walletNumber;

              _store.availablePayments = paymentOptions;
              _store.activeFrom = activeFrom;
              _store.activeTill = activeTill;
              List<int> workingDaysInt = workingDays.map(int.parse).toList();
              _store.workingDays = workingDaysInt;

              _store.deliveryDetails = DeliveryDetails();
              _store.deliveryDetails.deliveryFrom = this.deliverFrom;
              _store.deliveryDetails.deliveryTill = this.deliverTill;
              _store.deliveryDetails.maxDistance = this.maxDistance;
              _store.deliveryDetails.deliveryCharges02 = this.deliveryCharge2;
              _store.deliveryDetails.deliveryCharges05 = this.deliveryCharge5;
              _store.deliveryDetails.deliveryCharges10 = this.deliveryCharge10;
              _store.deliveryDetails.deliveryChargesMax =
                  this.deliveryChargeMax;
              _store.deliveryDetails.availableOptions = this.deliveryTemp;
              _store.keywords = _store.name.split(" ");
              _store.isActive = true;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationPicker(_store),
                  settings: RouteSettings(name: '/settings/store/add/location'),
                ),
              );
            } else {
              _scaffoldKey.currentState.showSnackBar(
                  CustomSnackBar.errorSnackBar("Please fill valid data!", 2));
            }
          },
          child: Container(
            height: 40,
            width: 120,
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: CustomColors.primary,
                border: Border.all(color: CustomColors.black),
                borderRadius: BorderRadius.circular(10.0)),
            child: Text("Continue"),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                child: Column(children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10.0, top: 10),
                    height: 40,
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Tell us About Your Business",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Set Your Business Days",
                        style:
                            TextStyle(color: CustomColors.black, fontSize: 16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all()),
                      child: InkWell(
                        onTap: () async {
                          List<MultiSelectDialogItem> buildingDropdownItems =
                              [];
                          for (var i = 0; i < _days.length; i++) {
                            buildingDropdownItems.add(
                                MultiSelectDialogItem(i.toString(), _days[i]));
                          }

                          final selectedValues = await showDialog<Set<String>>(
                            context: context,
                            builder: (BuildContext context) {
                              return MultiSelectDialog(
                                title: "Working Days",
                                items: buildingDropdownItems,
                                initialSelectedValues: workingDays.toSet(),
                              );
                            },
                          );

                          if (selectedValues != null) {
                            workingDays.clear();

                            setState(() {
                              workingDays = selectedValues.toList();
                            });
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(child: Text("Working Days")),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: CustomColors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Set Your Business Timing",
                        style:
                            TextStyle(color: CustomColors.black, fontSize: 16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 5, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: InputDecorator(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: CustomColors.white,
                                labelText: 'Opening Time',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: InkWell(
                                child: Text("${fromTime.format(context)}"),
                                onTap: () async {
                                  await _pickFromTime();
                                },
                              ),
                            )),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: CustomColors.white,
                              labelText: 'Closing Time',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: InkWell(
                              child: Text("${tillTime.format(context)}"),
                              onTap: () async {
                                await _pickTillTime();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Delivery Details",
                        style: TextStyle(
                            color: CustomColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 10),
                    child: Card(
                      color: CustomColors.grey,
                      elevation: 2,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.radio_button_off_rounded),
                                SizedBox(width: 2),
                                Text(
                                  "ChipChop Easy Delivery Service",
                                  style: TextStyle(
                                      color:
                                          CustomColors.black.withOpacity(0.5),
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            Text(
                              "You store & pack your orders at your location. Our delivery agent pick them from your address & deliver to customer safely.",
                              style: TextStyle(
                                  color: CustomColors.black.withOpacity(0.5),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, top: 10),
                    child: Card(
                      color: CustomColors.lightGrey,
                      elevation: 2,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.radio_button_on_rounded,
                                    color: CustomColors.primary),
                                SizedBox(width: 2),
                                Text(
                                  "Ship & Deliver your Own",
                                  style: TextStyle(
                                      color: CustomColors.black, fontSize: 16),
                                ),
                              ],
                            ),
                            Text(
                              "You store & pack your orders at your location. Also deliver the orders to customers safely using your own employees or via Third-party couriers couriers.",
                              style: TextStyle(
                                  color: CustomColors.black, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  getDeliveryDetails(),
                  getPaymentDetails(),
                  SizedBox(height: 60)
                ]),
              ),
            ),
          ),
        ));
  }

  Widget getPaymentDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 15.0, top: 10),
          child: Container(
            height: 40,
            alignment: Alignment.centerLeft,
            child: Text(
              "Your Payment Options",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
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
                      activeColor: CustomColors.primary,
                      title: Text("Cash On Delivery"),
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
                      activeColor: CustomColors.primary,
                      title: Text("UPI / Wallet"),
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
        _isCheckedGpay
            ? Padding(
                padding: EdgeInsets.fromLTRB(20.0, 5, 20, 5),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextFormField(
                        initialValue: upiID.toString(),
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          labelText: "UPI ID",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: TextStyle(
                            fontSize: 12.0,
                            color: CustomColors.black,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: CustomColors.lightGreen)),
                          fillColor: CustomColors.white,
                          filled: true,
                        ),
                        validator: (upi) {
                          if (upi.trim() != "" && upi.isNotEmpty) {
                            this.upiID = upi.trim();
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        _isCheckedGpay
            ? Padding(
                padding: EdgeInsets.fromLTRB(20.0, 5, 20, 5),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextFormField(
                        initialValue: walletNumber.toString(),
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          labelText: "Wallet ID / Number",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: TextStyle(
                            fontSize: 12.0,
                            color: CustomColors.black,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: CustomColors.lightGreen)),
                          fillColor: CustomColors.white,
                          filled: true,
                        ),
                        validator: (id) {
                          if (id.trim() != "" && id.isNotEmpty) {
                            this.walletNumber = id;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Flexible(
                child: Column(
                  children: [
                    CheckboxListTile(
                      activeColor: CustomColors.primary,
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
                      activeColor: CustomColors.primary,
                      title: Text("Bank Transfer"),
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
    );
  }

  Widget getDeliveryDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              Flexible(
                child: Column(
                  children: [
                    CheckboxListTile(
                      activeColor: CustomColors.primary,
                      title: Text(
                        "Pickup from Store",
                        style: TextStyle(fontSize: 12),
                      ),
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
                      activeColor: CustomColors.primary,
                      title: Text(
                        "Instant Delivery from Store",
                        style: TextStyle(fontSize: 12),
                      ),
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
                      activeColor: CustomColors.primary,
                      title: Text(
                        "Standard Delivery from Store",
                        style: TextStyle(fontSize: 12),
                      ),
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
                      activeColor: CustomColors.primary,
                      title: Text(
                        "Scheduled Delivery from Store",
                        style: TextStyle(fontSize: 12),
                      ),
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
          padding: EdgeInsets.only(left: 15.0, top: 10),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Set Your Delivery Range",
              style: TextStyle(color: CustomColors.black, fontSize: 16),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(5.0),
          child: Row(
            children: <Widget>[
              Flexible(
                  child: Row(
                children: [
                  Flexible(
                    child: CheckboxListTile(
                      activeColor: CustomColors.primary,
                      title: Text(
                        "To Specific Distance",
                        style: TextStyle(fontSize: 12),
                      ),
                      value: !deliverAnywhere,
                      onChanged: (val) {
                        setState(() {
                          deliverAnywhere = !val;
                        });
                      },
                    ),
                  ),
                  Flexible(
                    child: CheckboxListTile(
                      activeColor: CustomColors.primary,
                      title: Text(
                        "Deliver To Any Range",
                        style: TextStyle(fontSize: 12),
                      ),
                      value: deliverAnywhere,
                      onChanged: (val) {
                        setState(() {
                          deliverAnywhere = val;
                        });
                      },
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
        !deliverAnywhere
            ? Padding(
                padding: EdgeInsets.fromLTRB(20.0, 5, 20, 5),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextFormField(
                        initialValue: maxDistance.toString(),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          labelText: "Max Distance (KMs)",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: TextStyle(
                            fontSize: 12.0,
                            color: CustomColors.black,
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
              )
            : Container(),
        Padding(
          padding: EdgeInsets.only(left: 15.0, top: 10),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Set Your Delivery Timing",
              style: TextStyle(color: CustomColors.black, fontSize: 16),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 15.0, top: 5, right: 10, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: CustomColors.white,
                      labelText: 'From',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: InkWell(
                      child: Text("${deliverFromTime.format(context)}"),
                      onTap: () async {
                        await _pickDeliverFromTime();
                      },
                    ),
                  )),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: InputDecorator(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: CustomColors.white,
                    labelText: 'To',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: InkWell(
                    child: Text("${deliverTillTime.format(context)}"),
                    onTap: () async {
                      await _pickDeliverTillTime();
                    },
                  ),
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
                      fontSize: 12.0,
                      color: CustomColors.black,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.lightGreen)),
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
                      fontSize: 12.0,
                      color: CustomColors.black,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.lightGreen)),
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
                      fontSize: 12.0,
                      color: CustomColors.black,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.lightGreen)),
                    fillColor: CustomColors.white,
                    filled: true,
                  ),
                  validator: (delivery10Km) {
                    if (delivery10Km.trim() != "" && delivery10Km.isNotEmpty) {
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
                      fontSize: 12.0,
                      color: CustomColors.black,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.lightGreen)),
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
