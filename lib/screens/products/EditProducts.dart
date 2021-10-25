import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:chipchop_seller/db/models/product_categories.dart';
import 'package:chipchop_seller/db/models/product_categories_map.dart';
import 'package:chipchop_seller/db/models/product_description.dart';
import 'package:chipchop_seller/db/models/product_sub_categories.dart';
import 'package:chipchop_seller/db/models/product_variants.dart';
import 'package:chipchop_seller/db/models/product_avail_time.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/db/models/store.dart';
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
// import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:search_choices/search_choices.dart';

class EditProducts extends StatefulWidget {
  final Products product;
  EditProducts(this.product);

  @override
  _EditProductsState createState() => _EditProductsState();
}

class _EditProductsState extends State<EditProducts> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> imagePaths = [];
  String primaryImage = noImagePlaceholder;

  List<ProductVariants> _variants = [];
  List<ProductDescription> _descs = [ProductDescription.fromJson({})];

  List<TextEditingController> vPriceControllers = [];

  Map<String, String> _stores = {"0": "Choose your Store"};
  Map<String, String> _types = {"0": "Choose Product Type"};
  Map<String, String> _categories = {"0": "Choose Product Category"};
  Map<String, String> _subcategories = {"0": "Choose Product SubCategory"};

  Map<String, ProductCategoriesMap> type = {};
  Map<String, ProductCategoriesMap> category = {};
  Map<String, ProductCategoriesMap> subcategory = {};

  Map<String, String> _units = {
    "0": "Nos",
    "1": "Kg",
    "2": "gram",
    "3": "m.gram",
    "4": "Litre",
    "5": "m.litre"
  };

  String _selectedType = "0";
  String _selectedCategory = "0";
  String _selectedSubCategory = "0";

  String pName = "";
  String brandName = "";
  String shortDetails = "";
  ProductCategoriesMap productType;
  ProductCategoriesMap productCategory;
  ProductCategoriesMap productSubCategory;
  String storeID = "";
  double weight = 0.00;
  int unit = 0;
  int quantity = 0;
  double originalPrice = 0.00;
  double offer = 0.00;
  double currentPrice = 0.00;
  int replaceWithinDays = 0;
  int returnWithinDays = 0;
  bool isDeliverable = true;
  bool isPopular = false;
  bool isReturnable = true;
  bool isReplaceable = true;
  List<String> keywords = [];

  Map<String, Store> _storeMap = {};

  @override
  void initState() {
    super.initState();

    loadStores();

    this.imagePaths = widget.product.productImages;
    this.primaryImage = widget.product.image;
    this.pName = widget.product.name;
    this.brandName = widget.product.brandName;
    this.shortDetails = widget.product.shortDetails;
    this.productType = widget.product.productType;
    this.productCategory = widget.product.productType;
    this.productSubCategory = widget.product.productSubCategory;
    this._variants = widget.product.variants;
    this.keywords = widget.product.keywords;
    this.isDeliverable = widget.product.isDeliverable;
    this.isPopular = widget.product.isPopular;
    this.isReturnable = widget.product.isReturnable;
    this.returnWithinDays = widget.product.returnWithin;
    this.isReplaceable = widget.product.isReplaceable;
    this.replaceWithinDays = widget.product.replaceWithin;

    widget.product.variants.forEach((element) {
      TextEditingController _controller =
          TextEditingController(text: element.currentPrice.toString());
      vPriceControllers.add(_controller);
    });

    this._descs = widget.product.productDescription == null ||
            widget.product.productDescription.isEmpty
        ? [ProductDescription.fromJson({})]
        : widget.product.productDescription;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColors.lightGrey,
      appBar: AppBar(
        backgroundColor: CustomColors.primary,
        title: Text(
          "Edit - ${widget.product.name}",
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
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
      if (_selectedType == "0" || _selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.errorSnackBar("Please select Product Type!", 2),
        );
        return;
      }

      if (_selectedCategory == "0" || _selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.errorSnackBar("Please select Product Category!", 2),
        );
        return;
      }

      if (_variants.isEmpty ||
          (_variants.length == 1 && _variants.first.weight.toDouble() <= 0)) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.errorSnackBar("Please Fill Product Variants!", 2),
        );
        return;
      }

      vPriceControllers.forEach((element) {
        if (element.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.errorSnackBar("Please Fill Price Details!", 2),
          );
          return;
        }
      });

      final FormState form = _formKey.currentState;

      if (form.validate()) {
        Products _p = widget.product;
        _p.name = pName;
        _p.brandName = brandName;
        _p.shortDetails = shortDetails;
        _p.productImages = imagePaths;
        _p.image = primaryImage;
        _p.isDeliverable = isDeliverable;
        _p.isPopular = isPopular;
        _p.isReturnable = isReturnable;
        _p.returnWithin = returnWithinDays;
        _p.isReplaceable = isReplaceable;
        _p.replaceWithin = replaceWithinDays;
        _p.productType = _selectedType == "0" ? null : type[_selectedType];
        _p.productCategory =
            _selectedCategory == "0" ? null : category[_selectedCategory];
        _p.productSubCategory = _selectedSubCategory == "0"
            ? null
            : subcategory[_selectedSubCategory];

        _p.keywords = pName.split(" ").map((e) => e.toLowerCase()).toList();

        _p.variants = _variants;
        if (_descs.isNotEmpty) {
          if (_descs.length == 1 && _descs.first.title.trim().isEmpty)
            _p.productDescription = [];
          else
            _p.productDescription = _descs;
        } else
          _p.productDescription = [];
        CustomDialogs.actionWaiting(context);
        await _p.updateByID(_p.toJson(), _p.uuid);
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.errorSnackBar("Fill Required fields", 2));
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.errorSnackBar("Unable to create now! Try later!", 2),
      );
    }
  }

  Widget getBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: CustomColors.white,
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            ListTile(
              leading: Icon(
                FontAwesomeIcons.storeAlt,
                size: 35,
                color: CustomColors.black,
              ),
              title: Container(
                child: TextFormField(
                  initialValue: widget.product.storeName,
                  textAlign: TextAlign.end,
                  autofocus: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    fillColor: CustomColors.white,
                    filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: CustomColors.grey)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Container(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(fontWeight: FontWeight.w700),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: Column(children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: CustomColors.grey),
                      ),
                      child: SearchChoices.single(
                        icon: Container(),
                        clearIcon: Icon(Icons.clear_all),
                        onClear: () {
                          onTypesDropdownItem('0');
                        },
                        underline: Container(),
                        items: _types.entries.map(
                          (f) {
                            return DropdownMenuItem<String>(
                              value: f.key,
                              child: Text(f.value),
                            );
                          },
                        ).toList(),
                        displayItem: (item, selected) {
                          return (Row(
                            children: [
                              selected
                                  ? Icon(
                                      Icons.radio_button_checked,
                                      color: CustomColors.primary,
                                    )
                                  : Icon(
                                      Icons.radio_button_unchecked,
                                      color: Colors.grey,
                                    ),
                              SizedBox(width: 7),
                              Expanded(
                                child: item,
                              ),
                            ],
                          ));
                        },
                        searchFn: (String keyword, items) {
                          List<int> ret = [];
                          if (keyword != null &&
                              items != null &&
                              keyword.isNotEmpty) {
                            keyword.split(" ").forEach((k) {
                              int i = 0;
                              items.forEach((item) {
                                if (k.isNotEmpty &&
                                    (_types[item.value.toString()]
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
                        value: _selectedType,
                        hint: "Select Type",
                        searchHint: null,
                        onChanged: onTypesDropdownItem,
                        dialogBox: true,
                        isExpanded: true,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: CustomColors.grey),
                      ),
                      child: SearchChoices.single(
                        icon: Container(),
                        clearIcon: Icon(Icons.clear_all),
                        onClear: () {
                          onCategoryDropdownItem('0');
                        },
                        underline: Container(),
                        items: _categories.entries.map(
                          (f) {
                            return DropdownMenuItem<String>(
                              value: f.key,
                              child: Text(f.value),
                            );
                          },
                        ).toList(),
                        displayItem: (item, selected) {
                          return (Row(
                            children: [
                              selected
                                  ? Icon(
                                      Icons.radio_button_checked,
                                      color: CustomColors.primary,
                                    )
                                  : Icon(
                                      Icons.radio_button_unchecked,
                                      color: Colors.grey,
                                    ),
                              SizedBox(width: 7),
                              Expanded(
                                child: item,
                              ),
                            ],
                          ));
                        },
                        searchFn: (String keyword, items) {
                          List<int> ret = [];
                          if (keyword != null &&
                              items != null &&
                              keyword.isNotEmpty) {
                            keyword.split(" ").forEach((k) {
                              int i = 0;
                              items.forEach((item) {
                                if (k.isNotEmpty &&
                                    (_categories[item.value.toString()]
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
                        value: _selectedCategory,
                        hint: "Select Category",
                        searchHint: null,
                        onChanged: onCategoryDropdownItem,
                        dialogBox: true,
                        isExpanded: true,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: CustomColors.grey),
                      ),
                      child: SearchChoices.single(
                        icon: Container(),
                        clearIcon: Icon(Icons.clear_all),
                        onClear: () {
                          setState(
                            () {
                              _selectedSubCategory = '0';
                            },
                          );
                        },
                        underline: Container(),
                        items: _subcategories.entries.map(
                          (f) {
                            return DropdownMenuItem<String>(
                              value: f.key,
                              child: Text(f.value),
                            );
                          },
                        ).toList(),
                        displayItem: (item, selected) {
                          return (Row(
                            children: [
                              selected
                                  ? Icon(
                                      Icons.radio_button_checked,
                                      color: CustomColors.primary,
                                    )
                                  : Icon(
                                      Icons.radio_button_unchecked,
                                      color: Colors.grey,
                                    ),
                              SizedBox(width: 7),
                              Expanded(
                                child: item,
                              ),
                            ],
                          ));
                        },
                        searchFn: (String keyword, items) {
                          List<int> ret = [];
                          if (keyword != null &&
                              items != null &&
                              keyword.isNotEmpty) {
                            keyword.split(" ").forEach((k) {
                              int i = 0;
                              items.forEach((item) {
                                if (k.isNotEmpty &&
                                    (_subcategories[item.value.toString()]
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
                        value: _selectedSubCategory,
                        hint: "Select Sub-Category",
                        searchHint: null,
                        onChanged: (uuid) {
                          setState(
                            () {
                              _selectedSubCategory = uuid;
                            },
                          );
                        },
                        dialogBox: true,
                        isExpanded: true,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
              child: Container(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Product Info',
                    labelStyle: TextStyle(fontWeight: FontWeight.w700),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: TextFormField(
                        initialValue: widget.product.name,
                        textAlign: TextAlign.start,
                        autofocus: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: "Product Name (Ex, Rice)",
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                      child: TextFormField(
                        initialValue: brandName,
                        textAlign: TextAlign.start,
                        autofocus: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: "Brand Name (Ex, India Brand)",
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
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: TextFormField(
                        initialValue: widget.product.shortDetails,
                        textAlign: TextAlign.start,
                        autofocus: false,
                        keyboardType: TextInputType.multiline,
                        maxLines: 8,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: "Short Details (Ex, Boiled Rice)",
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
                  ]),
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Product Images",
                style: TextStyle(fontWeight: FontWeight.w700),
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
                                                noImagePlaceholder) {
                                              setState(() {
                                                imagePaths
                                                    .remove(noImagePlaceholder);
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
                                                    source:
                                                        ImageSource.gallery);
                                            if (pickedFile == null) return;

                                            String fileName = DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString();
                                            String fbFilePath =
                                                'products/${widget.product.storeID}/$fileName.png';
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
                                                textColor: CustomColors.black);
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
                                                  fontWeight: FontWeight.bold),
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

                                            List<CameraDescription> cameras =
                                                await availableCameras();
                                            CameraDescription camera =
                                                cameras.first;

                                            var result = await Navigator.push(
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
                                              String fileName = DateTime.now()
                                                  .millisecondsSinceEpoch
                                                  .toString();
                                              String fbFilePath =
                                                  'products/${widget.product.storeID}/$fileName.png';
                                              CustomDialogs.actionWaiting(
                                                  context);
                                              // Upload to storage
                                              imageUrl = await Uploader()
                                                  .uploadImageFile(
                                                      true, result, fbFilePath);
                                              Navigator.of(context).pop();
                                            }
                                          } catch (err) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'This file is not an image',
                                                backgroundColor:
                                                    CustomColors.alertRed,
                                                textColor: CustomColors.white);
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
                                                  fontWeight: FontWeight.bold),
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
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Container(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Inventory',
                    labelStyle: TextStyle(fontWeight: FontWeight.w700),
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Product Variants",
                  style: TextStyle(
                      fontSize: 14,
                      color: CustomColors.black,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: _variants.length,
              itemBuilder: (BuildContext context, int index) {
                ProductVariants _pv = _variants[index];

                return Padding(
                  key: ObjectKey(_pv),
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Variant ${index + 1}',
                        labelStyle: TextStyle(fontWeight: FontWeight.w700),
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
                                  contentPadding: EdgeInsets.all(10),
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
                                  contentPadding: EdgeInsets.all(10),
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
                                  contentPadding: EdgeInsets.all(10),
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
                                  contentPadding: EdgeInsets.all(10),
                                  labelStyle: TextStyle(
                                      fontSize: 13, color: CustomColors.black),
                                  fillColor: CustomColors.white,
                                  filled: true,
                                ),
                                onChanged: (val) {
                                  if (_pv.originalPrice >= 0) {
                                    double _cp =
                                        (_pv.originalPrice - double.parse(val));
                                    vPriceControllers[index].text =
                                        _cp.toString();

                                    _pv.currentPrice = _cp;
                                  } else {
                                    vPriceControllers[index].text = "0.00";
                                    _pv.currentPrice = 0.00;
                                  }

                                  _pv.offer = double.parse(val);
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
                                  contentPadding: EdgeInsets.all(10),
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
                          Padding(
                            padding: EdgeInsets.only(bottom: 1, top: 1),
                            child: Container(
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Available Timings',
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.w700),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                child: _pv.availableTimes != null &&
                                        _pv.availableTimes.length > 0
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        primary: false,
                                        itemCount: _pv.availableTimes.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          ProductAvailTime _pa =
                                              _pv.availableTimes[index];

                                          TimeOfDay fromTime = TimeOfDay(
                                            hour: int.parse(
                                                _pa.activeFrom.split(":")[0]),
                                            minute: int.parse(
                                                _pa.activeFrom.split(":")[1]),
                                          );
                                          TimeOfDay tillTime = TimeOfDay(
                                            hour: int.parse(
                                                _pa.activeTill.split(":")[0]),
                                            minute: int.parse(
                                                _pa.activeTill.split(":")[1]),
                                          );

                                          return Padding(
                                            key: ObjectKey(_pa),
                                            padding:
                                                EdgeInsets.only(bottom: 8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: InputDecorator(
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor:
                                                          CustomColors.white,
                                                      labelText: 'From Time',
                                                      labelStyle: TextStyle(
                                                          fontSize: 13,
                                                          color: CustomColors
                                                              .black),
                                                      contentPadding:
                                                          EdgeInsets.all(10),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                    ),
                                                    child: InkWell(
                                                      child: Text(
                                                          "${fromTime.format(context)}"),
                                                      onTap: () async {
                                                        await _pickFromTime(fromTime, 
                                                            _pv, index);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: InputDecorator(
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor:
                                                          CustomColors.white,
                                                      labelText: 'Closing Time',
                                                      labelStyle: TextStyle(
                                                          fontSize: 13,
                                                          color: CustomColors
                                                              .black),
                                                      contentPadding:
                                                          EdgeInsets.all(10),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                    ),
                                                    child: InkWell(
                                                      child: Text(
                                                          "${tillTime.format(context)}"),
                                                      onTap: () async {
                                                        await _pickTillTime(tillTime, 
                                                            _pv, index);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 2),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        _pv.availableTimes
                                                            .removeAt(index);
                                                      });
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 30,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .remove_circle_outline,
                                                        color:
                                                            CustomColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 2),
                                                  child: InkWell(
                                                    onTap: () {
                                                      if (_pv.availableTimes
                                                              .isNotEmpty &&
                                                          _pv.availableTimes.last
                                                                  .activeTill ==
                                                              "0:0") {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Please fill the Product Avail Time");
                                                        return;
                                                      } else {
                                                        setState(() {
                                                          _pv.availableTimes
                                                              .add(
                                                            ProductAvailTime
                                                                .fromJson(
                                                              {
                                                                'id': (_pv
                                                                        .availableTimes
                                                                        .length)
                                                                    .toString()
                                                              },
                                                            ),
                                                          );
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width: 30,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        color:
                                                            CustomColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        })
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                    "Set Available Timings for this Variant ?"),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (_pv.availableTimes ==
                                                      null) {
                                                    _pv.availableTimes = [];
                                                  }

                                                  setState(() {
                                                    _pv.availableTimes.add(
                                                      ProductAvailTime.fromJson(
                                                        {
                                                          'id': (_pv
                                                                  .availableTimes
                                                                  .length)
                                                              .toString(),
                                                        },
                                                      ),
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Icon(
                                                    Icons.add_circle_outline,
                                                    color: CustomColors.white,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      ),
                              ),
                            ),
                          ),
                          // _pv.isAvailable
                          //     ? Row(
                          //         children: [
                          //           Flexible(
                          //             child: Padding(
                          //               padding:
                          //                   EdgeInsets.fromLTRB(10, 0, 5, 0),
                          //               child: TextFormField(
                          //                 initialValue: _pv.quantity.toString(),
                          //                 textAlign: TextAlign.start,
                          //                 autofocus: false,
                          //                 keyboardType: TextInputType.number,
                          //                 decoration: InputDecoration(
                          //                   border: OutlineInputBorder(
                          //                       borderSide: BorderSide(
                          //                           color: CustomColors
                          //                               .lightGreen)),
                          //                   labelText: "Available Quantity",
                          //                   contentPadding: EdgeInsets.all(10),
                          //                   labelStyle: TextStyle(
                          //                       fontSize: 13,
                          //                       color: CustomColors.black),
                          //                   fillColor: CustomColors.white,
                          //                   filled: true,
                          //                 ),
                          //                 onChanged: (val) {
                          //                   _pv.quantity = int.parse(val);
                          //                 },
                          //                 validator: (quantity) {
                          //                   if (quantity.isEmpty) {
                          //                     _pv.quantity = 0;
                          //                   } else {
                          //                     _pv.quantity =
                          //                         int.parse(quantity);
                          //                   }
                          //                   return null;
                          //                 },
                          //               ),
                          //             ),
                          //           ),
                          //           Flexible(
                          //             child: DropdownButtonFormField(
                          //               decoration: InputDecoration(
                          //                 border: OutlineInputBorder(
                          //                     borderSide: BorderSide(
                          //                         color:
                          //                             CustomColors.lightGreen)),
                          //                 labelText: "Unit",
                          //                 contentPadding: EdgeInsets.all(10),
                          //                 labelStyle: TextStyle(
                          //                     fontSize: 13,
                          //                     color: CustomColors.black),
                          //                 fillColor: CustomColors.white,
                          //                 filled: true,
                          //               ),
                          //               value: _pv.availableUnit.toString(),
                          //               items: _units.entries.map((f) {
                          //                 return DropdownMenuItem<String>(
                          //                   value: f.key,
                          //                   child: Text(f.value),
                          //                 );
                          //               }).toList(),
                          //               onChanged: (unit) {
                          //                 setState(
                          //                   () {
                          //                     _pv.availableUnit =
                          //                         int.parse(unit);
                          //                   },
                          //                 );
                          //               },
                          //             ),
                          //           ),
                          //         ],
                          //       )
                          //     : Container(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: InkWell(
                                onTap: () {
                                  vPriceControllers.removeAt(index);
                                  setState(() {
                                    _variants.removeAt(index);
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 100,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text("Remove"),
                                ),
                              ),
                            ),
                          ),
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
                    Flexible(
                        child:
                            Text("More Varients Available for this Product ?")),
                    FlatButton.icon(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      color: Colors.green,
                      onPressed: () async {
                        if (_variants.isNotEmpty &&
                            _variants.last.weight.toDouble() <= 0) {
                          Fluttertoast.showToast(
                              msg: "Please fill the Product Variant");
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
                        "ADD",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ]),
            ),
            SizedBox(height: 10),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Text(
            //       "Product Description",
            //       style: TextStyle(
            //           fontSize: 14,
            //           color: CustomColors.black,
            //           fontWeight: FontWeight.w600),
            //     ),
            //   ),
            // ),
            // ListView.builder(
            //   shrinkWrap: true,
            //   primary: false,
            //   itemCount: _descs.length,
            //   itemBuilder: (BuildContext context, int index) {
            //     ProductDescription _pd = _descs[index];

            //     return Padding(
            //       key: ObjectKey(_pd),
            //       padding: EdgeInsets.all(10.0),
            //       child: Container(
            //         child: InputDecorator(
            //           decoration: InputDecoration(
            //             labelText: 'Description : ${index + 1}',
            //             labelStyle: TextStyle(fontWeight: FontWeight.w700),
            //             border: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(5.0),
            //             ),
            //           ),
            //           child: Column(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               Container(
            //                 child: TextFormField(
            //                   initialValue: _pd.title.toString(),
            //                   textAlign: TextAlign.start,
            //                   autofocus: false,
            //                   keyboardType: TextInputType.text,
            //                   decoration: InputDecoration(
            //                     border: OutlineInputBorder(
            //                         borderSide: BorderSide(
            //                             color: CustomColors.lightGreen)),
            //                     labelText: "Title",
            //                     contentPadding: EdgeInsets.all(10),
            //                     labelStyle: TextStyle(
            //                         fontSize: 13, color: CustomColors.black),
            //                     fillColor: CustomColors.white,
            //                     filled: true,
            //                   ),
            //                   onChanged: (val) {
            //                     setState(() {
            //                       _pd.title = val;
            //                     });
            //                   },
            //                 ),
            //               ),
            //               SizedBox(height: 5),
            //               Container(
            //                 child: TextFormField(
            //                   initialValue: _pd.description.toString(),
            //                   textAlign: TextAlign.start,
            //                   maxLines: 5,
            //                   autofocus: false,
            //                   keyboardType: TextInputType.multiline,
            //                   decoration: InputDecoration(
            //                     border: OutlineInputBorder(
            //                         borderSide: BorderSide(
            //                             color: CustomColors.lightGreen)),
            //                     labelText: "Description",
            //                     contentPadding: EdgeInsets.all(10),
            //                     labelStyle: TextStyle(
            //                         fontSize: 13, color: CustomColors.black),
            //                     fillColor: CustomColors.white,
            //                     filled: true,
            //                   ),
            //                   onChanged: (val) {
            //                     _pd.description = val;
            //                   },
            //                 ),
            //               ),
            //               Align(
            //                 alignment: Alignment.bottomRight,
            //                 child: Padding(
            //                   padding: EdgeInsets.only(top: 10),
            //                   child: InkWell(
            //                     onTap: () {
            //                       setState(() {
            //                         _descs.removeAt(index);
            //                       });
            //                     },
            //                     child: Container(
            //                       alignment: Alignment.center,
            //                       width: 100,
            //                       height: 30,
            //                       decoration: BoxDecoration(
            //                         color: Colors.red,
            //                         borderRadius: BorderRadius.circular(5),
            //                       ),
            //                       child: Text("Remove"),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
            //   child: Align(
            //     alignment: Alignment.centerRight,
            //     child: Container(
            //       width: 160,
            //       child: FlatButton.icon(
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(5.0),
            //         ),
            //         color: Colors.green,
            //         onPressed: () async {
            //           if (_descs.isNotEmpty &&
            //               _descs.last.title.trim().isEmpty) {
            //             Fluttertoast.showToast(
            //                 msg: "Please fill the last Detail");
            //             return;
            //           } else {
            //             setState(() {
            //               _descs.add(
            //                 ProductDescription.fromJson(
            //                   {},
            //                 ),
            //               );
            //             });
            //           }
            //         },
            //         icon: Icon(Icons.add),
            //         label: Text(
            //           "Add Details",
            //           textAlign: TextAlign.center,
            //           style: TextStyle(
            //             fontSize: 14,
            //             color: Colors.white,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
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
          _storeMap[b.uuid] = b;
        },
      );

      setState(
        () {
          _stores = _stores..addAll(storeList);
        },
      );
    }

    await loadProductTypes();
    await onTypesDropdownItem(widget.product.productType.uuid);

    if (widget.product.productCategory != null) {
      await onCategoryDropdownItem(widget.product.productCategory.uuid);
      if (widget.product.productSubCategory != null)
        _selectedSubCategory = widget.product.productSubCategory.uuid;
    }
  }

  loadProductTypes() async {
    _selectedType = '0';
    _types = {"0": "Choose Product Type"};

    if (_storeMap.containsKey(widget.product.storeID)) {
      List<ProductCategoriesMap> types =
          _storeMap[widget.product.storeID].availProducts;
      Map<String, String> ptypes = Map();
      if (types.length > 0) {
        type.clear();
        types.forEach(
          (b) {
            ptypes[b.uuid] = b.name;
            type[b.uuid] = b;
          },
        );

        setState(
          () {
            _types = _types..addAll(ptypes);
          },
        );
      } else {
        setState(
          () {
            _selectedType = '0';
          },
        );
      }
    }
  }

  onTypesDropdownItem(String uuid) async {
    // Do nothing for no change
    if (_selectedType == uuid) {
      return;
    }

    _selectedSubCategory = '0';
    _selectedCategory = '0';
    _categories = {"0": "Choose Product Category"};
    _subcategories = {"0": "Choose Product SubCategory"};

    if (uuid == null || uuid == "0") {
      setState(
        () {
          _selectedType = '0';
        },
      );
      return;
    }

    if (_storeMap.containsKey(widget.product.storeID)) {
      List<ProductCategoriesMap> _cat =
          _storeMap[widget.product.storeID].availProductCategories;

      List<ProductCategories> categories = await ProductCategories()
          .getCategoriesForStoreID(_cat.map((e) => e.uuid).toList(), uuid);
      Map<String, String> cList = Map();
      if (categories.length > 0) {
        category.clear();
        categories.forEach(
          (b) {
            cList[b.uuid] = b.name;
            category[b.uuid] =
                ProductCategoriesMap.fromJson({'uuid': b.uuid, 'name': b.name});
          },
        );

        setState(
          () {
            _selectedType = uuid;
            _categories = _categories..addAll(cList);
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
  }

  onCategoryDropdownItem(String uuid) async {
    // Do nothing for no change
    if (_selectedCategory == uuid) {
      return;
    }

    _selectedSubCategory = '0';
    _subcategories = {"0": "Choose Product SubCategory"};

    if (uuid == null || uuid == "0") {
      setState(
        () {
          _selectedCategory = '0';
        },
      );
      return;
    }

    if (_storeMap.containsKey(widget.product.storeID)) {
      List<ProductCategoriesMap> _subCat =
          _storeMap[widget.product.storeID].availProductSubCategories;

      List<ProductSubCategories> subCategories = await ProductSubCategories()
          .getSubCategoriesForIDs(uuid, _subCat.map((e) => e.uuid).toList());
      Map<String, String> scList = Map();
      if (subCategories.length > 0) {
        subcategory.clear();
        subCategories.forEach(
          (b) {
            scList[b.uuid] = b.name;
            subcategory[b.uuid] =
                ProductCategoriesMap.fromJson({'uuid': b.uuid, 'name': b.name});
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

  _pickFromTime(fromTime, _pv, index) async {
    TimeOfDay t = await showTimePicker(
        context: context,
        initialTime: fromTime);
    if (t != null)
      setState(() {
        _pv.availableTimes[index].activeFrom =
            '${t.hour}:${t.minute}';
      });
  }

  _pickTillTime(tillTime, _pv, index) async {
    TimeOfDay t = await showTimePicker(
        context: context,
        initialTime: tillTime);
    if (t != null)
      setState(() {
        _pv.availableTimes[index].activeTill = '${t.hour}:${t.minute}';
      });
  }
}
