import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/product_categories.dart';
import 'package:chipchop_seller/db/models/product_sub_categories.dart';
import 'package:chipchop_seller/db/models/product_types.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:chipchop_seller/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_seller/screens/utils/ImageView.dart';
import 'package:chipchop_seller/services/storage/image_uploader.dart';
import 'package:chipchop_seller/services/storage/storage_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

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

  TextEditingController priceController = TextEditingController();

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
  String _selectedUnit = "0";

  List<String> pImages = [];
  String pName = "";
  String shortDetails = "";
  String productType = "";
  String productCategory = "";
  String productSubCategory = "";
  String storeID = "";
  double weight = 0.00;
  int unit = 0;
  double originalPrice = 0.00;
  double offer = 0.00;
  double currentPrice = 0.00;
  bool isAvailable = true;
  bool isDeliverable = true;
  bool isPopular = false;
  bool isReturnable = true;
  List<String> keywords = [];

  @override
  void initState() {
    super.initState();

    loadStores();
    loadProductTypes();
    onTypesDropdownItem(widget.product.productType);
    if (widget.product.productCategory != "")
      onCategoryDropdownItem(widget.product.productCategory);

    _selectedUnit = (widget.product.unit).toString();

    this.imagePaths = widget.product.productImages;
    this.pImages = widget.product.productImages;
    this.pName = widget.product.name;
    this.shortDetails = widget.product.shortDetails;
    this.productType = widget.product.productType;
    this.productCategory = widget.product.productType;
    this.productSubCategory = widget.product.productSubCategory;
    this.weight = widget.product.weight;
    this.unit = widget.product.unit;
    this.originalPrice = widget.product.originalPrice;
    this.offer = widget.product.offer;
    this.currentPrice = widget.product.currentPrice;
    priceController.text = this.currentPrice.toString();
    this.keywords = widget.product.keywords;
    this.isAvailable = widget.product.isAvailable;
    this.isDeliverable = widget.product.isDeliverable;
    this.isPopular = widget.product.isPopular;
    this.isReturnable = widget.product.isReturnable;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColors.lightGrey,
      appBar: AppBar(
        backgroundColor: CustomColors.green,
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
        backgroundColor: CustomColors.alertRed,
        onPressed: () async {
          await _submit();
        },
        icon: Icon(
          Icons.done_all,
          size: 35,
        ),
        label: Text("Save"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: getBody(context),
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

      if (storeID == "0") {
        _scaffoldKey.currentState.showSnackBar(
          CustomSnackBar.errorSnackBar("Please select your store!", 2),
        );
        return;
      }

      final FormState form = _formKey.currentState;

      if (form.validate()) {
        Products _p = widget.product;
        _p.name = pName;
        _p.shortDetails = shortDetails;
        _p.productImages = imagePaths;
        _p.currentPrice = double.parse(priceController.text.trim());
        _p.originalPrice = originalPrice;
        _p.offer = offer;
        _p.isAvailable = isAvailable;
        _p.isDeliverable = isDeliverable;
        _p.isPopular = isPopular;
        _p.isReturnable = isReturnable;
        _p.storeID = _selectedStore;
        _p.weight = weight;
        _p.unit = int.parse(_selectedUnit);
        _p.productType = _selectedType == "0" ? "" : _selectedType;
        _p.productCategory = _selectedCategory == "0" ? "" : _selectedCategory;
        _p.productSubCategory =
            _selectedSubCategory == "0" ? "" : _selectedSubCategory;
        CustomDialogs.actionWaiting(context);
        await _p.updateByID(_p.toJson(), _p.uuid);
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        _scaffoldKey.currentState.showSnackBar(
            CustomSnackBar.errorSnackBar("Fill Required fields", 2));
      }
    } catch (err) {
      Navigator.pop(context);
      _scaffoldKey.currentState.showSnackBar(
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
            ListTile(
              leading: Icon(
                Icons.store,
                size: 35,
                color: CustomColors.blue,
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
              leading: Text(""),
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
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: ListTile(
                leading: Icon(
                  Icons.image,
                  size: 35,
                  color: CustomColors.blue,
                ),
                title: Text(
                  "Product Images",
                  style: TextStyle(color: CustomColors.black, fontSize: 16),
                ),
                trailing: Container(
                  width: 155,
                  child: FlatButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: CustomColors.alertRed,
                    onPressed: () async {
                      if (_selectedStore == "0") {
                        Fluttertoast.showToast(
                            msg: 'Please Select a Store First');
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
                        "Pick Image!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color: CustomColors.white,
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
                    shrinkWrap: true,
                    primary: false,
                    mainAxisSpacing: 10,
                    children: List.generate(
                      imagePaths.length,
                      (index) {
                        return Stack(
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 10, right: 10, top: 5),
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
                                      imageBuilder: (context, imageProvider) =>
                                          Image(
                                        fit: BoxFit.fill,
                                        image: imageProvider,
                                      ),
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              Center(
                                        child: SizedBox(
                                          height: 50.0,
                                          width: 50.0,
                                          child: CircularProgressIndicator(
                                              value: downloadProgress.progress,
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
                                        imagePaths.remove(imagePaths[index]);
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
            ListTile(
              leading: Icon(
                Icons.format_shapes,
                size: 35,
                color: CustomColors.blue,
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
              padding: EdgeInsets.only(left: 60.0, right: 10),
              child: TextFormField(
                initialValue: widget.product.name,
                textAlign: TextAlign.start,
                autofocus: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
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
                Icons.description,
                size: 35,
                color: CustomColors.blue,
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
              padding: EdgeInsets.fromLTRB(60.0, 0, 10, 0),
              child: TextFormField(
                initialValue: widget.product.shortDetails,
                textAlign: TextAlign.start,
                autofocus: false,
                keyboardType: TextInputType.text,
                maxLines: 8,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: CustomColors.lightGreen)),
                  hintText: "Ex, Rice",
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
            ListTile(
              leading: Icon(
                Icons.view_stream,
                size: 35,
                color: CustomColors.blue,
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
              leading: Text(""),
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
                color: CustomColors.blue,
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
              leading: Text(""),
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
                color: CustomColors.blue,
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
              leading: Text(""),
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
            Padding(padding: EdgeInsets.all(5)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Flexible(
                  child: TextFormField(
                    initialValue: widget.product.weight.toString(),
                    textAlign: TextAlign.start,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.lightGreen)),
                      hintText: "Weight",
                      labelText: "Weight",
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                    validator: (weight) {
                      if (weight.isEmpty) {
                        return "Must not be empty";
                      } else {
                        this.weight = double.parse(weight);
                        return null;
                      }
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 15)),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text("Unit"),
                        items: _units.entries.map((f) {
                          return DropdownMenuItem<String>(
                            value: f.key,
                            child: Text(f.value),
                          );
                        }).toList(),
                        onChanged: (unit) {
                          setState(
                            () {
                              _selectedUnit = unit;
                              this.unit = int.parse(unit);
                            },
                          );
                        },
                        value: _selectedUnit,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.product.originalPrice.toString(),
                    textAlign: TextAlign.start,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.lightGreen)),
                      hintText: "Price",
                      labelText: "Price",
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                    onChanged: (val) {
                      if (offer > 0) {
                        priceController.text =
                            (double.parse(val) - offer).toString();
                      } else {
                        priceController.text = val;
                      }

                      this.originalPrice = double.parse(val);
                    },
                    validator: (price) {
                      if (price.isEmpty) {
                        return "Must not be empty";
                      } else {
                        this.originalPrice = double.parse(price);
                        return null;
                      }
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 5)),
                Flexible(
                  child: TextFormField(
                    initialValue: widget.product.offer.toString(),
                    textAlign: TextAlign.start,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.lightGreen)),
                      hintText: "Offer",
                      labelText: "Offer",
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                    onChanged: (val) {
                      if (originalPrice >= 0) {
                        priceController.text =
                            (originalPrice - double.parse(val)).toString();
                      } else {
                        priceController.text = "0.00";
                      }
                    },
                    validator: (offer) {
                      if (offer.isEmpty) {
                        return "Must not be empty";
                      } else {
                        this.offer = double.parse(offer);
                        return null;
                      }
                    },
                  ),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Text(
                    "Current Price",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: CustomColors.black,
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 5)),
                  Flexible(
                    child: TextFormField(
                      controller: priceController,
                      textAlign: TextAlign.end,
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: CustomColors.lightGreen)),
                        fillColor: CustomColors.white,
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.adjust,
                size: 35,
                color: CustomColors.blue,
              ),
              title: Text(
                "Available",
                style: TextStyle(
                  fontSize: 16.0,
                  color: CustomColors.black,
                ),
              ),
              trailing: Switch(
                value: isAvailable,
                onChanged: (value) {
                  setState(() {
                    isAvailable = value;
                  });
                },
                inactiveTrackColor: CustomColors.alertRed,
                activeTrackColor: CustomColors.green,
                activeColor: Colors.green,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.local_shipping,
                size: 35,
                color: CustomColors.blue,
              ),
              title: Text(
                "Deliverable",
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
                activeTrackColor: CustomColors.green,
                activeColor: Colors.green,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.favorite_border,
                size: 35,
                color: CustomColors.blue,
              ),
              title: Text(
                "Popular Item",
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
                activeTrackColor: CustomColors.green,
                activeColor: Colors.green,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.av_timer,
                size: 35,
                color: CustomColors.blue,
              ),
              title: Text(
                "Returnable",
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
                activeTrackColor: CustomColors.green,
                activeColor: Colors.green,
              ),
            ),
            Padding(padding: EdgeInsets.all(35))
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

    _selectedStore = widget.product.storeID;
  }

  loadProductTypes() async {
    List<ProductTypes> types = await ProductTypes().getProductTypes();
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

    _selectedType = widget.product.productType;
  }

  onStoreDropdownItem(String uuid) async {
    setState(
      () {
        _selectedStore = uuid;
      },
    );
  }

  onTypesDropdownItem(String uuid) async {
    if (uuid == "0") {
      setState(
        () {
          _selectedType = uuid;
        },
      );
      return;
    }

    List<ProductCategories> categories =
        await ProductCategories().getCategoriesForTypes([uuid]);
    Map<String, String> cList = Map();
    if (categories.length > 0) {
      categories.forEach(
        (b) {
          cList[b.uuid] = b.name;
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

    if (widget.product.productCategory != "")
      _selectedCategory = widget.product.productCategory;
  }

  onCategoryDropdownItem(String uuid) async {
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

      setState(
        () {
          _selectedCategory = uuid;
          _subcategories = _subcategories..addAll(scList);
        },
      );
    } else {
      setState(
        () {
          _selectedCategory = uuid;
        },
      );
    }
    if (widget.product.productSubCategory != "")
      _selectedSubCategory = widget.product.productSubCategory;
  }
}
