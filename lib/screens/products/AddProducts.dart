import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:chipchop_seller/db/models/product_description.dart';
import 'package:chipchop_seller/db/models/product_variants.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/screens/app/TakePicturePage.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:chipchop_seller/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_seller/screens/utils/ImageView.dart';
import 'package:chipchop_seller/services/storage/image_uploader.dart';
import 'package:chipchop_seller/services/storage/storage_utils.dart';
import 'package:chipchop_seller/services/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../db/models/product_categories.dart';
import '../../db/models/product_sub_categories.dart';
import '../../db/models/product_types.dart';
import '../../db/models/store.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<ProductVariants> _variants = [
    ProductVariants.fromJson({'id': "0"})
  ];

  List<ProductDescription> _descs = [ProductDescription.fromJson({})];

  List<TextEditingController> vPriceControllers = [
    TextEditingController(text: "0.00")
  ];

  List<String> imagePaths = [no_image_placeholder];
  String primaryImage = no_image_placeholder;

  Map<String, String> _stores = {"0": "Choose your Store"};
  Map<String, String> _types = {"0": "Choose Product Type"};
  Map<String, String> _categories = {"0": "Choose Product Category"};
  Map<String, String> _subcategories = {"0": "Choose Product SubCategory"};
  Map<String, String> _units = {
    "0": "Nos",
    "1": "Kg",
    "2": "gram",
    "3": "m.gram",
    "4": "Litre",
    "5": "m.litre"
  };

  String _selectedStore = "0";
  String _selectedType = "0";
  String _selectedCategory = "0";
  String _selectedSubCategory = "0";

  String pName = "";
  String brandName = "";
  String shortDetails = "";
  String productType = "";
  String productCategory = "";
  String productSubCategory = "";
  String storeID = "";
  int replaceWithinDays = 0;
  int returnWithinDays = 0;
  bool isAvailable = true;
  bool isDeliverable = true;
  bool isPopular = false;
  bool isReturnable = true;
  bool isReplaceable = true;
  List<String> keywords = [];

  @override
  void initState() {
    super.initState();

    loadStores();

    _variants = [
      ProductVariants.fromJson({'id': "0"})
    ];

    vPriceControllers = [TextEditingController(text: "0.00")];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColors.lightGrey,
      appBar: AppBar(
        backgroundColor: CustomColors.primary,
        title: Text(
          "Add Products",
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.primary,
        onPressed: () async {
          await _submit();
        },
        icon: Icon(
          Icons.done_all,
          size: 35,
        ),
        label: Text("Save"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: getBody(context),
          ),
        ),
      ),
    );
  }

  _submit() async {
    try {
      if (_selectedType == "0") {
        _scaffoldKey.currentState.showSnackBar(
          CustomSnackBar.errorSnackBar("Please select Product Type!", 2),
        );
        return;
      }

      if (_selectedStore == "0") {
        _scaffoldKey.currentState.showSnackBar(
          CustomSnackBar.errorSnackBar("Please select your store!", 2),
        );
        return;
      }

      if (_variants.length == 1 && _variants.first.weight.toInt() == 0) {
        _scaffoldKey.currentState.showSnackBar(
          CustomSnackBar.errorSnackBar("Please Fill Product Varients!", 2),
        );
        return;
      }

      vPriceControllers.forEach((element) {
        if (element.text.trim().isEmpty) {
          _scaffoldKey.currentState.showSnackBar(
            CustomSnackBar.errorSnackBar("Please Fill Price Details!", 2),
          );
          return;
        }
      });

      final FormState form = _formKey.currentState;

      if (form.validate()) {
        Products _p = Products();
        _p.name = pName;
        _p.shortDetails = shortDetails;
        _p.productImages = imagePaths;
        _p.image = primaryImage;
        _p.isAvailable = isAvailable;
        _p.isDeliverable = isDeliverable;
        _p.isPopular = isPopular;
        _p.isReturnable = isReturnable;
        _p.isReplaceable = isReplaceable;
        _p.replaceWithin = replaceWithinDays;
        _p.returnWithin = returnWithinDays;
        _p.storeID = _selectedStore;
        _p.storeName = _stores[_selectedStore];
        _p.brandName = brandName;
        _p.productType = _selectedType == "0" ? "" : _selectedType;
        _p.productCategory = _selectedCategory == "0" ? "" : _selectedCategory;
        _p.productSubCategory =
            _selectedSubCategory == "0" ? "" : _selectedSubCategory;
        _p.keywords = pName.split(" ");

        _p.variants = _variants;
        if (_descs.isNotEmpty && _descs.last.title.trim().isNotEmpty) {
          _p.productDescription = _descs;
        } else
          _p.productDescription = [];
        CustomDialogs.actionWaiting(context);
        await _p.create();
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        _scaffoldKey.currentState.showSnackBar(
            CustomSnackBar.errorSnackBar("Fill Required fields", 2));
      }
    } catch (err) {
      _scaffoldKey.currentState.showSnackBar(
        CustomSnackBar.errorSnackBar("Unable to create now! Try later!", 2),
      );
      // Navigator.pop(context);
    }
  }

  Widget getBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: CustomColors.white,
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.store,
                size: 35,
                color: CustomColors.black,
              ),
              title: Text(
                "Store",
                style: TextStyle(
                  fontSize: 16.0,
                  color: CustomColors.black,
                ),
              ),
            ),
            ListTile(
              title: Container(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all()),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items: _stores.entries.map(
                      (f) {
                        return DropdownMenuItem<String>(
                          value: f.key,
                          child: Text(f.value),
                        );
                      },
                    ).toList(),
                    onChanged: onStoreDropdownItem,
                    value: _selectedStore,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.view_stream,
                size: 35,
                color: CustomColors.black,
              ),
              title: Text(
                "Product Type",
                style: TextStyle(
                  fontSize: 16.0,
                  color: CustomColors.black,
                ),
              ),
            ),
            ListTile(
              title: Container(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all()),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items: _types.entries.map(
                      (f) {
                        return DropdownMenuItem<String>(
                          value: f.key,
                          child: Text(f.value),
                        );
                      },
                    ).toList(),
                    onChanged: onTypesDropdownItem,
                    value: _selectedType,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.menu,
                size: 35,
                color: CustomColors.black,
              ),
              title: Text(
                "Product Category",
                style: TextStyle(
                  fontSize: 16.0,
                  color: CustomColors.black,
                ),
              ),
            ),
            ListTile(
              title: Container(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all()),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items: _categories.entries.map(
                      (f) {
                        return DropdownMenuItem<String>(
                          value: f.key,
                          child: Text(f.value),
                        );
                      },
                    ).toList(),
                    onChanged: onCategoryDropdownItem,
                    value: _selectedCategory,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.apps,
                size: 35,
                color: CustomColors.black,
              ),
              title: Text(
                "Product SubCategory",
                style: TextStyle(
                  fontSize: 16.0,
                  color: CustomColors.black,
                ),
              ),
            ),
            ListTile(
              title: Container(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all()),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items: _subcategories.entries.map(
                      (f) {
                        return DropdownMenuItem<String>(
                          value: f.key,
                          child: Text(f.value),
                        );
                      },
                    ).toList(),
                    onChanged: (uuid) {
                      setState(
                        () {
                          _selectedSubCategory = uuid;
                        },
                      );
                    },
                    value: _selectedSubCategory,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.format_shapes,
                size: 35,
                color: CustomColors.black,
              ),
              title: Text(
                "Product Name",
                style: TextStyle(
                  fontSize: 16.0,
                  color: CustomColors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                initialValue: pName,
                textAlign: TextAlign.start,
                autofocus: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: CustomColors.lightGreen)),
                  hintText: "Ex, Rice",
                  fillColor: CustomColors.white,
                  filled: true,
                ),
                validator: (name) {
                  if (name.isEmpty) {
                    return "Must not be empty";
                  } else {
                    this.pName = name;
                    return null;
                  }
                },
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.business,
                size: 35,
                color: CustomColors.black,
              ),
              title: Text(
                "Product Brand Name",
                style: TextStyle(
                  fontSize: 16.0,
                  color: CustomColors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                initialValue: brandName,
                textAlign: TextAlign.start,
                autofocus: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: CustomColors.lightGreen)),
                  hintText: "Ex, India Brand",
                  fillColor: CustomColors.white,
                  filled: true,
                ),
                validator: (brand) {
                  if (brand.isEmpty) {
                    this.brandName = "";
                  } else {
                    this.brandName = brand;
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: ListTile(
                leading: Icon(
                  Icons.image,
                  size: 35,
                  color: CustomColors.black,
                ),
                title: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.green[300],
                      borderRadius: BorderRadius.circular(5.0)),
                  child: InkWell(
                    onTap: () async {
                      if (_selectedStore == "0") {
                        Fluttertoast.showToast(
                            msg: 'Please Select a Store First',
                            backgroundColor: CustomColors.alertRed,
                            textColor: CustomColors.white);
                        return;
                      }
                      String imageUrl = '';
                      try {
                        ImagePicker imagePicker = ImagePicker();
                        PickedFile pickedFile;

                        pickedFile = await imagePicker.getImage(
                            source: ImageSource.gallery);
                        if (pickedFile == null) return;

                        String fileName =
                            DateTime.now().millisecondsSinceEpoch.toString();
                        String fbFilePath =
                            'products/$_selectedStore/$fileName.png';
                        CustomDialogs.actionWaiting(context);
                        // Upload to storage
                        imageUrl = await Uploader()
                            .uploadImageFile(true, pickedFile.path, fbFilePath);
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.images,
                          size: 20,
                          color: CustomColors.black,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Upload Image",
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
                      if (_selectedStore == "0") {
                        Fluttertoast.showToast(
                            msg: 'Please Select a Store First',
                            backgroundColor: CustomColors.alertRed,
                            textColor: CustomColors.white);
                        return;
                      }

                      String imageUrl = '';
                      try {
                        String tempPath = (await getTemporaryDirectory()).path;
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
                          String fileName =
                              DateTime.now().millisecondsSinceEpoch.toString();
                          String fbFilePath =
                              'products/$_selectedStore/$fileName.png';
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
                          "Capture Image",
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
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: CachedNetworkImage(
                                        imageUrl: imagePaths[index],
                                        imageBuilder:
                                            (context, imageProvider) => Image(
                                          fit: BoxFit.fill,
                                          height: 150,
                                          width: 150,
                                          image: imageProvider,
                                        ),
                                        progressIndicatorBuilder:
                                            (context, url, downloadProgress) =>
                                                Center(
                                          child: SizedBox(
                                            height: 50.0,
                                            width: 50.0,
                                            child: CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        CustomColors.black),
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
                                top: 5,
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
                                      if (primaryImage == imagePaths[index]) {
                                        Fluttertoast.showToast(
                                            msg:
                                                'You cannot remove Primary Image');

                                        return;
                                      }

                                      if (imagePaths[index] ==
                                          no_image_placeholder) {
                                        setState(() {
                                          imagePaths
                                              .remove(no_image_placeholder);
                                        });
                                        return;
                                      }
                                      CustomDialogs.actionWaiting(context);
                                      bool res = await StorageUtils()
                                          .removeFile(imagePaths[index]);
                                      Navigator.of(context).pop();
                                      if (res)
                                        setState(() {
                                          imagePaths.remove(imagePaths[index]);
                                        });
                                      else
                                        Fluttertoast.showToast(
                                            msg: 'Unable to remove image');
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
                                    borderRadius: BorderRadius.circular(5),
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
            ListTile(
              leading: Icon(
                Icons.description,
                size: 35,
                color: CustomColors.black,
              ),
              title: Text(
                "Product Details",
                style: TextStyle(
                  fontSize: 16.0,
                  color: CustomColors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextFormField(
                initialValue: shortDetails,
                textAlign: TextAlign.start,
                autofocus: false,
                keyboardType: TextInputType.text,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.lightGreen)),
                  hintText: "Ex, Boiled Rice",
                  fillColor: CustomColors.white,
                  filled: true,
                ),
                validator: (details) {
                  if (details.isEmpty) {
                    this.shortDetails = "";
                  } else {
                    this.shortDetails = details;
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Container(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Inventory',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          "Is product deliverable ?",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: CustomColors.black,
                          ),
                        ),
                        trailing: Switch(
                          value: isDeliverable,
                          onChanged: (value) {
                            setState(() {
                              isDeliverable = value;
                            });
                          },
                          inactiveTrackColor: CustomColors.alertRed,
                          activeTrackColor: Colors.green,
                          activeColor: Colors.white,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          "Is this item popular in your store ?",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: CustomColors.black,
                          ),
                        ),
                        trailing: Switch(
                          value: isPopular,
                          onChanged: (value) {
                            setState(() {
                              isPopular = value;
                            });
                          },
                          inactiveTrackColor: CustomColors.alertRed,
                          activeTrackColor: Colors.green,
                          activeColor: Colors.white,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          "Is it returnable ?",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: CustomColors.black,
                          ),
                        ),
                        trailing: Switch(
                          value: isReturnable,
                          onChanged: (value) {
                            setState(() {
                              isReturnable = value;
                            });
                          },
                          inactiveTrackColor: CustomColors.alertRed,
                          activeTrackColor: Colors.green,
                          activeColor: Colors.white,
                        ),
                      ),
                      isReturnable
                          ? Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 25, 0),
                              child: TextFormField(
                                initialValue: returnWithinDays.toString(),
                                textAlign: TextAlign.start,
                                autofocus: false,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CustomColors.lightGreen)),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  labelText: "Max no. of days to return",
                                  fillColor: CustomColors.white,
                                  filled: true,
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Must not be empty";
                                  } else {
                                    this.returnWithinDays = int.parse(value);
                                    return null;
                                  }
                                },
                              ),
                            )
                          : Container(),
                      ListTile(
                        title: Text(
                          "Is it replaceable ?",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: CustomColors.black,
                          ),
                        ),
                        trailing: Switch(
                          value: isReplaceable,
                          onChanged: (value) {
                            setState(() {
                              isReplaceable = value;
                            });
                          },
                          inactiveTrackColor: CustomColors.alertRed,
                          activeTrackColor: Colors.green,
                          activeColor: Colors.white,
                        ),
                      ),
                      isReplaceable
                          ? Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 25, 0),
                              child: TextFormField(
                                initialValue: replaceWithinDays.toString(),
                                textAlign: TextAlign.start,
                                autofocus: false,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CustomColors.lightGreen)),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  labelText: "Max no. of days to replace",
                                  fillColor: CustomColors.white,
                                  filled: true,
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Must not be empty";
                                  } else {
                                    this.replaceWithinDays = int.parse(value);
                                    return null;
                                  }
                                },
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Having many Varients ?",
                    style: TextStyle(
                        fontSize: 14,
                        color: CustomColors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  Container(
                    width: 135,
                    child: FlatButton.icon(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      color: Colors.green,
                      onPressed: () async {
                        if (_variants.isNotEmpty &&
                            _variants.last.weight.toInt() == 0) {
                          Fluttertoast.showToast(
                              msg: "Please fill the Product Varient");
                          return;
                        } else {
                          setState(() {
                            _variants.add(
                              ProductVariants.fromJson(
                                {'id': (_variants.length).toString()},
                              ),
                            );
                            vPriceControllers
                                .add(TextEditingController(text: "0.00"));
                          });
                        }
                      },
                      icon: Icon(Icons.add),
                      label: Text(
                        "Add",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: _variants.length,
              itemBuilder: (BuildContext context, int index) {
                ProductVariants _pv = _variants[index];

                return Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Varient ${index + 1}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(children: [
                            Flexible(
                              child: TextFormField(
                                initialValue: _pv.weight.toString(),
                                textAlign: TextAlign.start,
                                autofocus: false,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CustomColors.lightGreen)),
                                  labelText: "Weight",
                                  labelStyle: TextStyle(
                                      fontSize: 13, color: CustomColors.black),
                                  fillColor: CustomColors.white,
                                  filled: true,
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _pv.weight = double.parse(val);
                                  });
                                },
                                validator: (weight) {
                                  if (weight.isEmpty) {
                                    _pv.weight = 0.00;
                                  } else {
                                    _pv.weight = double.parse(weight);
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(left: 5)),
                            Flexible(
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CustomColors.lightGreen)),
                                  labelText: "Unit",
                                  labelStyle: TextStyle(
                                      fontSize: 13, color: CustomColors.black),
                                  fillColor: CustomColors.white,
                                  filled: true,
                                ),
                                value: _pv.unit.toString(),
                                items: _units.entries.map((f) {
                                  return DropdownMenuItem<String>(
                                    value: f.key,
                                    child: Text(f.value),
                                  );
                                }).toList(),
                                onChanged: (unit) {
                                  setState(
                                    () {
                                      _pv.unit = int.parse(unit);
                                    },
                                  );
                                },
                              ),
                            ),
                          ]),
                          SizedBox(
                            height: 5,
                          ),
                          Row(children: [
                            Flexible(
                              child: TextFormField(
                                initialValue: _pv.originalPrice.toString(),
                                textAlign: TextAlign.start,
                                autofocus: false,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CustomColors.lightGreen)),
                                  labelText: "Product MRP",
                                  labelStyle: TextStyle(
                                      fontSize: 13, color: CustomColors.black),
                                  fillColor: CustomColors.white,
                                  filled: true,
                                ),
                                onChanged: (val) {
                                  if (_pv.offer > 0) {
                                    vPriceControllers[index].text =
                                        (double.parse(val) - _pv.offer)
                                            .toString();
                                  } else {
                                    vPriceControllers[index].text = val;
                                  }

                                  _pv.originalPrice = double.parse(val);
                                },
                                validator: (price) {
                                  if (price.isEmpty &&
                                      _pv.weight.toInt() != 0) {
                                    return "Must not be empty";
                                  } else {
                                    _pv.originalPrice = double.parse(price);
                                    return null;
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: TextFormField(
                                initialValue: _pv.offer.toString(),
                                textAlign: TextAlign.start,
                                autofocus: false,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CustomColors.lightGreen)),
                                  labelText: "Offer Price",
                                  labelStyle: TextStyle(
                                      fontSize: 13, color: CustomColors.black),
                                  fillColor: CustomColors.white,
                                  filled: true,
                                ),
                                onChanged: (val) {
                                  if (_pv.originalPrice >= 0) {
                                    vPriceControllers[index].text =
                                        (_pv.originalPrice - double.parse(val))
                                            .toString();
                                  } else {
                                    vPriceControllers[index].text = "0.00";
                                  }
                                },
                                validator: (offer) {
                                  if (offer.isEmpty &&
                                      _pv.weight.toInt() != 0) {
                                    return "Must not be empty";
                                  } else {
                                    _pv.offer = double.parse(offer);
                                    return null;
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: TextFormField(
                                controller: vPriceControllers[index],
                                textAlign: TextAlign.end,
                                readOnly: true,
                                decoration: InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CustomColors.lightGreen)),
                                  labelText: "Selling Price",
                                  labelStyle: TextStyle(
                                      fontSize: 13, color: CustomColors.black),
                                  fillColor: CustomColors.white,
                                  filled: true,
                                ),
                                validator: (price) {
                                  if (price.isEmpty &&
                                      _pv.weight.toInt() != 0) {
                                    return "Must not be empty";
                                  } else {
                                    _pv.currentPrice = double.parse(price);
                                    return null;
                                  }
                                },
                              ),
                            ),
                          ]),
                          ListTile(
                            title: Text(
                              "Is product in stock ?",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: CustomColors.black,
                              ),
                            ),
                            trailing: Switch(
                              value: _pv.isAvailable,
                              onChanged: (value) {
                                setState(() {
                                  _pv.isAvailable = value;
                                });
                              },
                              inactiveTrackColor: CustomColors.alertRed,
                              activeTrackColor: Colors.green,
                              activeColor: Colors.white,
                            ),
                          ),
                          isAvailable
                              ? Row(
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 5, 0),
                                        child: TextFormField(
                                          initialValue: _pv.quantity.toString(),
                                          textAlign: TextAlign.start,
                                          autofocus: false,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: CustomColors
                                                        .lightGreen)),
                                            labelText: "Available Quantity",
                                            labelStyle: TextStyle(
                                                fontSize: 13,
                                                color: CustomColors.black),
                                            fillColor: CustomColors.white,
                                            filled: true,
                                          ),
                                          validator: (quantity) {
                                            if (quantity.isEmpty) {
                                              _pv.quantity = 0;
                                            } else {
                                              _pv.quantity =
                                                  int.parse(quantity);
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: DropdownButtonFormField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      CustomColors.lightGreen)),
                                          labelText: "Unit",
                                          labelStyle: TextStyle(
                                              fontSize: 13,
                                              color: CustomColors.black),
                                          fillColor: CustomColors.white,
                                          filled: true,
                                        ),
                                        value: _pv.availableUnit.toString(),
                                        items: _units.entries.map((f) {
                                          return DropdownMenuItem<String>(
                                            value: f.key,
                                            child: Text(f.value),
                                          );
                                        }).toList(),
                                        onChanged: (unit) {
                                          setState(
                                            () {
                                              _pv.availableUnit =
                                                  int.parse(unit);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Product Details",
                    style: TextStyle(
                        fontSize: 14,
                        color: CustomColors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  Container(
                    width: 135,
                    child: FlatButton.icon(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      color: Colors.green,
                      onPressed: () async {
                        if (_descs.isNotEmpty &&
                            _descs.last.title.trim().isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Please fill the last Detail");
                          return;
                        } else {
                          setState(() {
                            _descs.add(
                              ProductDescription.fromJson(
                                {},
                              ),
                            );
                          });
                        }
                      },
                      icon: Icon(Icons.add),
                      label: Text(
                        "Add",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: _descs.length,
              itemBuilder: (BuildContext context, int index) {
                ProductDescription _pd = _descs[index];

                return Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Detail : ${index + 1}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            child: TextFormField(
                              initialValue: _pd.title.toString(),
                              textAlign: TextAlign.start,
                              autofocus: false,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: CustomColors.lightGreen)),
                                labelText: "Title",
                                labelStyle: TextStyle(
                                    fontSize: 13, color: CustomColors.black),
                                fillColor: CustomColors.white,
                                filled: true,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _pd.title = val;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            child: TextFormField(
                              initialValue: _pd.description.toString(),
                              textAlign: TextAlign.start,
                              maxLines: 5,
                              autofocus: false,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: CustomColors.lightGreen)),
                                labelText: "Description",
                                labelStyle: TextStyle(
                                    fontSize: 13, color: CustomColors.black),
                                fillColor: CustomColors.white,
                                filled: true,
                              ),
                              onChanged: (val) {
                                _pd.description = val;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 70)
          ],
        ),
      ),
    );
  }

  loadStores() async {
    List<Store> stores = await Store().getStoresForUser();
    Map<String, String> storeList = Map();
    if (stores.length > 0) {
      stores.forEach(
        (b) {
          storeList[b.uuid] = b.name;
        },
      );

      setState(
        () {
          _stores = _stores..addAll(storeList);
        },
      );
    }
  }

  loadProductTypes() async {
    List<ProductTypes> types =
        await ProductTypes().getProductTypesForStoreID(this._selectedStore);
    Map<String, String> ptypes = Map();
    if (types.length > 0) {
      types.forEach(
        (b) {
          ptypes[b.uuid] = b.name;
        },
      );

      setState(
        () {
          _types = _types..addAll(ptypes);
        },
      );
    }
    if (this.productType != "") _selectedType = this.productType;
  }

  onStoreDropdownItem(String uuid) async {
    setState(
      () {
        _selectedStore = uuid;
      },
    );

    await loadProductTypes();
  }

  onTypesDropdownItem(String uuid) async {
    _selectedSubCategory = '0';
    _selectedCategory = '0';
    _categories = {"0": "Choose Product Category"};
    _subcategories = {"0": "Choose Product SubCategory"};

    if (uuid == "0") {
      setState(
        () {
          _selectedType = uuid;
        },
      );
      return;
    }

    List<ProductCategories> categories = await ProductCategories()
        .getCategoriesForStoreID(this._selectedStore, uuid);
    Map<String, String> cList = Map();
    if (categories.length > 0) {
      categories.forEach(
        (b) {
          cList[b.uuid] = b.name;
        },
      );

      _categories = _categories..addAll(cList);
      setState(
        () {
          _selectedType = uuid;
        },
      );
    } else {
      setState(
        () {
          _selectedType = uuid;
        },
      );
    }
  }

  onCategoryDropdownItem(String uuid) async {
    _selectedSubCategory = '0';
    _subcategories = {"0": "Choose Product SubCategory"};

    if (uuid == "0") {
      setState(
        () {
          _selectedCategory = uuid;
        },
      );
      return;
    }

    List<ProductSubCategories> subCategories =
        await ProductSubCategories().getSubCategoriesByIDs([uuid]);
    Map<String, String> scList = Map();
    if (subCategories.length > 0) {
      subCategories.forEach(
        (b) {
          scList[b.uuid] = b.name;
        },
      );

      _subcategories = _subcategories..addAll(scList);
      setState(
        () {
          _selectedCategory = uuid;
        },
      );
    } else {
      setState(
        () {
          _selectedCategory = uuid;
        },
      );
    }
  }
}
