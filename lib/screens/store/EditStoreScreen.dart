import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:chipchop_seller/app_localizations.dart';
import 'package:chipchop_seller/db/models/address.dart';
import 'package:chipchop_seller/db/models/product_categories.dart';
import 'package:chipchop_seller/db/models/product_categories_map.dart';
import 'package:chipchop_seller/db/models/product_sub_categories.dart';
import 'package:chipchop_seller/db/models/product_types.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/app/TakePicturePage.dart';
import 'package:chipchop_seller/screens/store/EditLocationPicker.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class EditStoreScreen extends StatefulWidget {
  final Store store;

  EditStoreScreen(this.store);

  @override
  _EditStoreScreenState createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> imagePaths = [noImagePlaceholder];
  String primaryImage = noImagePlaceholder;

  Address updatedAddress = Address();
  String storeName = '';
  String shortDetails = '';
  String ownedBy = '';

  Map<String, ProductCategoriesMap> availProducts = {
    '0': ProductCategoriesMap.fromJson({'uuid': '0', 'name': 'Select Types'})
  };
  List<int> _selectedProducts = [0];
  Map<String, ProductCategoriesMap> availProductCategories = {
    '0': ProductCategoriesMap.fromJson(
        {'uuid': '0', 'name': 'Select Categories'})
  };
  List<int> _selectedCategories = [0];
  Map<String, ProductCategoriesMap> availProductSubCategories = {
    '0': ProductCategoriesMap.fromJson(
        {'uuid': '0', 'name': 'Select Sub-Categories'})
  };
  List<int> _selectedSubCategories = [0];

  @override
  void initState() {
    super.initState();

    loadTypes();

    storeName = widget.store.name;
    shortDetails = widget.store.shortDetails;

    imagePaths = widget.store.storeImages;
    primaryImage = widget.store.image;

    ownedBy = widget.store.ownedBy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Edit - ${widget.store.name}",
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
            _selectedProducts.remove(0);
            if (_selectedProducts.length == 0) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar(
                    "Please Select your Store Product Type!", 2),
              );
              return;
            }

            _selectedCategories.remove(0);
            if (_selectedCategories.length == 0) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar(
                    "Please Select Store Categories!", 2),
              );
              return;
            }

            _selectedSubCategories.remove(0);
            if (_selectedSubCategories.length == 0) {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar(
                    "Please Select Store Sub-Categories!", 2),
              );
              return;
            }

            if (primaryImage == "") {
              _scaffoldKey.currentState.showSnackBar(
                CustomSnackBar.errorSnackBar("Please Set Primary Image!", 2),
              );
              return;
            }

            Store store = widget.store;
            store.name = storeName;
            store.image = primaryImage;
            store.storeImages = imagePaths;
            store.shortDetails = this.shortDetails;
            store.ownedBy = ownedBy;

            Map<int, ProductCategoriesMap> _t =
                availProducts.values.toList().asMap();
            store.availProducts = [];

            _selectedProducts.forEach((e) {
              if (_t.containsKey(e)) store.availProducts.add(_t[e]);
            });

            Map<int, ProductCategoriesMap> _c =
                availProductCategories.values.toList().asMap();
            store.availProductCategories = [];

            _selectedCategories.forEach((e) {
              if (_c.containsKey(e)) store.availProductCategories.add(_c[e]);
            });

            Map<int, ProductCategoriesMap> _sc =
                availProductSubCategories.values.toList().asMap();
            store.availProductSubCategories = [];

            _selectedSubCategories.forEach((e) {
              if (_sc.containsKey(e))
                store.availProductSubCategories.add(_sc[e]);
            });

            store.address = updatedAddress;
            store.keywords =
                storeName.split(" ").map((e) => e.toLowerCase()).toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditStoreStepTwo(widget.store),
                settings: RouteSettings(name: '/settings/store/edit'),
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
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
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
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
                      style: TextStyle(color: CustomColors.black, fontSize: 14),
                    ),
                  ),
                ),
                imagePaths.length > 0
                    ? Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          primary: true,
                          child: Row(
                            children: [
                              ListView.builder(
                                scrollDirection: Axis.horizontal,
                                primary: false,
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
                                                  builder: (context) =>
                                                      ImageView(
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
                                                  imageBuilder: (context,
                                                          imageProvider) =>
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
                                                          value:
                                                              downloadProgress
                                                                  .progress,
                                                          valueColor:
                                                              AlwaysStoppedAnimation(
                                                                  CustomColors
                                                                      .black),
                                                          strokeWidth: 2.0),
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(
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
                                                    noImagePlaceholder) {
                                                  setState(() {
                                                    imagePaths.remove(
                                                        noImagePlaceholder);
                                                  });
                                                  return;
                                                }
                                                CustomDialogs.actionWaiting(
                                                    context);
                                                bool res = await StorageUtils()
                                                    .removeFile(
                                                        imagePaths[index]);
                                                Navigator.of(context).pop();
                                                if (res)
                                                  setState(() {
                                                    imagePaths.remove(
                                                        imagePaths[index]);
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
                                                primaryImage ==
                                                        imagePaths[index]
                                                    ? Icons.check_box
                                                    : Icons
                                                        .check_box_outline_blank,
                                                size: 25,
                                                color: CustomColors.primary,
                                              ),
                                              onTap: () async {
                                                setState(() {
                                                  primaryImage =
                                                      imagePaths[index];
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
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 5, right: 10, top: 5, bottom: 5),
                                child: Container(
                                  height: 120,
                                  width: 130,
                                  decoration: BoxDecoration(
                                    color: CustomColors.grey,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: 100,
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: CustomColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          child: InkWell(
                                            onTap: () async {
                                              String imageUrl = '';
                                              try {
                                                ImagePicker imagePicker =
                                                    ImagePicker();
                                                PickedFile pickedFile;

                                                pickedFile =
                                                    await imagePicker.getImage(
                                                        source: ImageSource
                                                            .gallery);
                                                if (pickedFile == null) return;

                                                String fileName = DateTime.now()
                                                    .millisecondsSinceEpoch
                                                    .toString();
                                                String fbFilePath =
                                                    'store_profile/${cachedLocalUser.getID()}/$fileName.png';
                                                CustomDialogs.actionWaiting(
                                                    context);
                                                // Upload to storage
                                                imageUrl = await Uploader()
                                                    .uploadImageFile(
                                                        true,
                                                        pickedFile.path,
                                                        fbFilePath);
                                                Navigator.of(context).pop();
                                              } catch (err) {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        'This file is not an image',
                                                    backgroundColor:
                                                        CustomColors.alertRed,
                                                    textColor:
                                                        CustomColors.black);
                                              }
                                              if (imageUrl != "")
                                                setState(() {
                                                  imagePaths.add(imageUrl);
                                                });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 100,
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              color: CustomColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          child: InkWell(
                                            onTap: () async {
                                              String imageUrl = '';
                                              try {
                                                String tempPath =
                                                    (await getTemporaryDirectory())
                                                        .path;
                                                String filePath =
                                                    '$tempPath/chipchop_image.png';
                                                if (File(filePath).existsSync())
                                                  await File(filePath).delete();

                                                List<CameraDescription>
                                                    cameras =
                                                    await availableCameras();
                                                CameraDescription camera =
                                                    cameras.first;

                                                var result =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TakePicturePage(
                                                      camera: camera,
                                                      path: filePath,
                                                    ),
                                                  ),
                                                );
                                                if (result != null) {
                                                  String fileName = DateTime
                                                          .now()
                                                      .millisecondsSinceEpoch
                                                      .toString();
                                                  String fbFilePath =
                                                      'store_profile/${cachedLocalUser.getID()}/$fileName.png';
                                                  CustomDialogs.actionWaiting(
                                                      context);
                                                  // Upload to storage
                                                  imageUrl = await Uploader()
                                                      .uploadImageFile(true,
                                                          result, fbFilePath);
                                                  Navigator.of(context).pop();
                                                }
                                              } catch (err) {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        'This file is not an image',
                                                    backgroundColor:
                                                        CustomColors.alertRed,
                                                    textColor:
                                                        CustomColors.white);
                                              }
                                              if (imageUrl != "")
                                                setState(() {
                                                  imagePaths.add(imageUrl);
                                                });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                              )
                            ],
                          ),
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
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all()),
                    child: getProductTypes(),
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
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all()),
                    child: getProductCategories(),
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
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all()),
                    child: getProductSubCategories(),
                  ),
                ),
                Padding(
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
                                initialValue: widget.store.address.street,
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
                                initialValue: widget.store.address.landmark,
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
                                    updatedAddress.landmark = landmark.trim();
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
                                initialValue: widget.store.address.city,
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
                                initialValue: widget.store.address.state,
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
                                initialValue: widget.store.address.pincode,
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
                                    widget.store.address.country ?? "India",
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
                SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  loadTypes() async {
    List<String> _productTypes =
        widget.store.availProducts.map((value) => value.uuid).toList();

    List<ProductTypes> data = await ProductTypes().getProductTypes();
    data.forEach((element) {
      availProducts[element.uuid] = ProductCategoriesMap.fromJson(
          {'uuid': element.uuid, 'name': element.name});
      if (_productTypes.contains(element.uuid)) {
        _selectedProducts.add(availProducts.length - 1);
      }
    });

    setState(() {
      _selectedProducts.remove(0);
    });

    await loadCategories();
  }

  loadCategories() async {
    List<String> _productCat =
        widget.store.availProductCategories.map((value) => value.uuid).toList();

    List<ProductCategories> data = await ProductCategories()
        .getCategoriesForTypes(
            widget.store.availProducts.map((value) => value.uuid).toList());
    data.forEach((element) {
      availProductCategories[element.uuid] = ProductCategoriesMap.fromJson(
          {'uuid': element.uuid, 'name': element.name});
      if (_productCat.contains(element.uuid)) {
        _selectedCategories.add(availProductCategories.length - 1);
      }
    });

    setState(() {
      _selectedCategories.remove(0);
    });

    await loadSubCategories();
  }

  loadSubCategories() async {
    List<String> _productCat = widget.store.availProductSubCategories
        .map((value) => value.uuid)
        .toList();

    List<ProductSubCategories> data = await ProductSubCategories()
        .getSubCategoriesByIDs(widget.store.availProductCategories
            .map((value) => value.uuid)
            .toList());
    data.forEach((element) {
      availProductSubCategories[element.uuid] = ProductCategoriesMap.fromJson(
          {'uuid': element.uuid, 'name': element.name});
      if (_productCat.contains(element.uuid)) {
        _selectedSubCategories.add(availProductSubCategories.length - 1);
      }
    });

    setState(() {
      _selectedSubCategories.remove(0);
    });
  }

  Widget getProductTypes() {
    return SearchableDropdown.multiple(
      icon: Container(),
      clearIcon: Icon(Icons.clear_all),
      onClear: () {
        onTypesDropdownItem([]);
      },
      underline: Container(),
      items: availProducts.values.map(
        (f) {
          return DropdownMenuItem<String>(
            value: f.uuid,
            child: Text(f.name),
          );
        },
      ).toList(),
      selectedItems: _selectedProducts,
      hint: "Select Types",
      searchHint: "Select Any",
      onChanged: (value) {},
      dialogBox: true,
      displayItem: (item, selected) {
        return Row(
          children: [
            selected
                ? Icon(
                    Icons.check_box,
                    color: CustomColors.primary,
                  )
                : Icon(
                    Icons.check_box_outline_blank,
                    color: Colors.grey,
                  ),
            SizedBox(width: 7),
            Expanded(
              child: item,
            ),
          ],
        );
      },
      doneButton: (selectedItemsDone, doneContext) {
        return RaisedButton(
          onPressed: () {
            Navigator.pop(doneContext);
            onTypesDropdownItem(selectedItemsDone);
          },
          child: Text("Save"),
        );
      },
      searchFn: (String keyword, items) {
        List<int> ret = List<int>();
        if (keyword != null && items != null && keyword.isNotEmpty) {
          keyword.split(" ").forEach((k) {
            int i = 0;
            items.forEach((item) {
              if (k.isNotEmpty &&
                  (availProducts[item.value.toString()]
                      .name
                      .toLowerCase()
                      .contains(
                        k.toLowerCase(),
                      ))) {
                ret.add(i);
              }
              i++;
            });
          });
        }
        if (keyword.isEmpty) {
          ret = Iterable<int>.generate(items.length).toList();
        }
        return (ret);
      },
      isExpanded: true,
    );
  }

  Widget getProductCategories() {
    return SearchableDropdown.multiple(
      icon: Container(),
      clearIcon: Icon(Icons.clear_all),
      onClear: () {
        onCategoryDropdownItem([]);
      },
      underline: Container(),
      items: availProductCategories.values.map(
        (f) {
          return DropdownMenuItem<String>(
            value: f.uuid,
            child: Text(f.name),
          );
        },
      ).toList(),
      selectedItems: _selectedCategories,
      hint: "Select Categories",
      searchHint: "Select Any",
      onChanged: (value) {},
      dialogBox: true,
      displayItem: (item, selected) {
        return Row(
          children: [
            selected
                ? Icon(
                    Icons.check_box,
                    color: CustomColors.primary,
                  )
                : Icon(
                    Icons.check_box_outline_blank,
                    color: Colors.grey,
                  ),
            SizedBox(width: 7),
            Expanded(
              child: item,
            ),
          ],
        );
      },
      doneButton: (selectedItemsDone, doneContext) {
        return RaisedButton(
          onPressed: () {
            Navigator.pop(doneContext);
            onCategoryDropdownItem(selectedItemsDone);
          },
          child: Text("Save"),
        );
      },
      searchFn: (String keyword, items) {
        List<int> ret = List<int>();
        if (keyword != null && items != null && keyword.isNotEmpty) {
          keyword.split(" ").forEach((k) {
            int i = 0;
            items.forEach((item) {
              if (k.isNotEmpty &&
                  (availProductCategories[item.value.toString()]
                      .name
                      .toLowerCase()
                      .contains(
                        k.toLowerCase(),
                      ))) {
                ret.add(i);
              }
              i++;
            });
          });
        }
        if (keyword.isEmpty) {
          ret = Iterable<int>.generate(items.length).toList();
        }
        return (ret);
      },
      isExpanded: true,
    );
  }

  Widget getProductSubCategories() {
    return SearchableDropdown.multiple(
      icon: Container(),
      clearIcon: Icon(Icons.clear_all),
      onClear: () {
        setState(() {
          _selectedSubCategories.clear();
        });
      },
      underline: Container(),
      items: availProductSubCategories.values.map(
        (f) {
          return DropdownMenuItem<String>(
            value: f.uuid,
            child: Text(f.name),
          );
        },
      ).toList(),
      selectedItems: _selectedSubCategories,
      hint: "Select Sub-Categories",
      searchHint: "Select Any",
      onChanged: (value) {},
      dialogBox: true,
      displayItem: (item, selected) {
        return Row(
          children: [
            selected
                ? Icon(
                    Icons.check_box,
                    color: CustomColors.primary,
                  )
                : Icon(
                    Icons.check_box_outline_blank,
                    color: Colors.grey,
                  ),
            SizedBox(width: 7),
            Expanded(
              child: item,
            ),
          ],
        );
      },
      doneButton: (selectedItemsDone, doneContext) {
        return RaisedButton(
          onPressed: () {
            Navigator.pop(doneContext);
            selectedItemsDone.remove(0);
            setState(() {
              _selectedSubCategories = selectedItemsDone;
            });
          },
          child: Text("Save"),
        );
      },
      searchFn: (String keyword, items) {
        List<int> ret = List<int>();
        if (keyword != null && items != null && keyword.isNotEmpty) {
          keyword.split(" ").forEach((k) {
            int i = 0;
            items.forEach((item) {
              if (k.isNotEmpty &&
                  (availProductSubCategories[item.value.toString()]
                      .name
                      .toLowerCase()
                      .contains(
                        k.toLowerCase(),
                      ))) {
                ret.add(i);
              }
              i++;
            });
          });
        }
        if (keyword.isEmpty) {
          ret = Iterable<int>.generate(items.length).toList();
        }
        return (ret);
      },
      isExpanded: true,
    );
  }

  onTypesDropdownItem(List<int> ids) async {
    // Do nothing for no change
    if (_selectedProducts == ids) {
      return;
    }

    _selectedCategories = [0];
    _selectedSubCategories = [0];
    availProductCategories = {
      '0': ProductCategoriesMap.fromJson(
          {'uuid': '0', 'name': 'Select Categories'})
    };
    availProductSubCategories = {
      '0': ProductCategoriesMap.fromJson(
          {'uuid': '0', 'name': 'Select Sub-Categories'})
    };

    if (ids == null || ids.isEmpty) {
      setState(
        () {
          _selectedProducts.clear();
        },
      );
      return;
    }

    ids.remove(0);

    Map<int, ProductCategoriesMap> _val = availProducts.values.toList().asMap();
    List<String> uuids = [];

    ids.forEach((e) {
      if (_val.containsKey(e)) uuids.add(_val[e].uuid);
    });

    List<ProductCategories> categories =
        await ProductCategories().getCategoriesForTypes(uuids);

    if (categories.length > 0) {
      categories.forEach(
        (b) {
          availProductCategories[b.uuid] =
              ProductCategoriesMap.fromJson({'uuid': b.uuid, 'name': b.name});
        },
      );

      setState(
        () {
          _selectedProducts = ids;
        },
      );
    } else {
      setState(
        () {
          _selectedProducts = ids;
        },
      );
    }
  }

  onCategoryDropdownItem(List<int> ids) async {
    // Do nothing for no change
    if (_selectedCategories == ids) {
      return;
    }

    _selectedSubCategories = [0];
    availProductSubCategories = {
      '0': ProductCategoriesMap.fromJson(
          {'uuid': '0', 'name': 'Select Sub-Categories'})
    };

    if (ids == null || ids.isEmpty) {
      setState(
        () {
          _selectedCategories.clear();
        },
      );
      return;
    }

    ids.remove(0);

    Map<int, ProductCategoriesMap> _val =
        availProductCategories.values.toList().asMap();
    List<String> uuids = [];

    ids.forEach((e) {
      if (_val.containsKey(e)) uuids.add(_val[e].uuid);
    });

    List<ProductSubCategories> subCategories =
        await ProductSubCategories().getSubCategoriesByIDs(uuids);

    if (subCategories.length > 0) {
      subCategories.forEach(
        (b) {
          availProductSubCategories[b.uuid] =
              ProductCategoriesMap.fromJson({'uuid': b.uuid, 'name': b.name});
        },
      );

      setState(
        () {
          _selectedCategories = ids;
        },
      );
    } else {
      setState(
        () {
          _selectedCategories = ids;
        },
      );
    }
  }
}

class EditStoreStepTwo extends StatefulWidget {
  EditStoreStepTwo(this.store);

  final Store store;
  @override
  _EditStoreStepTwoState createState() => _EditStoreStepTwoState();
}

class _EditStoreStepTwoState extends State<EditStoreStepTwo> {
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
  bool _isCheckedUPI;
  bool _isCheckedCard;
  bool _isCheckedBank;

  List<String> workingDays = [];
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

    maxDistance = widget.store.deliveryDetails.maxDistance;
    deliveryTemp = widget.store.deliveryDetails.availableOptions;
    paymentOptions = widget.store.availablePayments;

    _isCheckedPickUp =
        widget.store.deliveryDetails.availableOptions.contains(0);
    _isCheckedInstant =
        widget.store.deliveryDetails.availableOptions.contains(1);
    _isCheckedSameDay =
        widget.store.deliveryDetails.availableOptions.contains(2);
    _isCheckedScheduled =
        widget.store.deliveryDetails.availableOptions.contains(3);

    _isCheckedCash = widget.store.availablePayments.contains(0);
    _isCheckedUPI = widget.store.availablePayments.contains(1);
    _isCheckedCard = widget.store.availablePayments.contains(2);
    _isCheckedBank = widget.store.availablePayments.contains(3);

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

    widget.store.workingDays.forEach((element) {
      workingDays.add(element.toString());
    });

    deliveryCharge2 = widget.store.deliveryDetails.deliveryCharges02;
    deliveryCharge5 = widget.store.deliveryDetails.deliveryCharges05;
    deliveryCharge10 = widget.store.deliveryDetails.deliveryCharges10;
    deliveryChargeMax = widget.store.deliveryDetails.deliveryChargesMax;

    deliverAnywhere = widget.store.deliverAnywhere;
    upiID = widget.store.upiID;
    walletNumber = widget.store.walletNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "Edit - ${widget.store.name}",
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
          onTap: () async {
            final FormState form = _formKey.currentState;

            if (form.validate()) {
              if (deliveryTemp.length == 0) {
                _scaffoldKey.currentState.showSnackBar(
                  CustomSnackBar.errorSnackBar(
                      "Please Select atleast one Delivery Option!", 2),
                );
                return;
              }

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

              await _store.update(_store.toJson());

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditLocationPicker(_store),
                  settings:
                      RouteSettings(name: '/settings/store/edit/location'),
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
                      elevation: 3,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.radio_button_off_rounded),
                                SizedBox(width: 3),
                                Text(
                                  "ChipChop Easy Delivery Service",
                                  style: TextStyle(
                                      color:
                                          CustomColors.black.withOpacity(0.5),
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
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
                      elevation: 3,
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.radio_button_on_rounded,
                                    color: CustomColors.primary),
                                SizedBox(width: 3),
                                Text(
                                  "Ship & Deliver your Own",
                                  style: TextStyle(
                                      color: CustomColors.black, fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
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
                      value: _isCheckedUPI,
                      onChanged: (val) {
                        setState(() {
                          _isCheckedUPI = val;
                          if (_isCheckedUPI) {
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
        _isCheckedUPI
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
        _isCheckedUPI
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
                      value: _isCheckedBank,
                      onChanged: (val) {
                        setState(() {
                          _isCheckedBank = val;
                          if (_isCheckedBank) {
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
