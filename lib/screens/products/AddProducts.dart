import 'package:chipchop_seller/db/models/chipchop_products.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:chipchop_seller/screens/utils/CustomSnackBar.dart';
import 'package:flutter/material.dart';

import '../../db/models/product_categories.dart';
import '../../db/models/product_sub_categories.dart';
import '../../db/models/product_types.dart';
import '../../db/models/store.dart';
import '../../db/models/store_locations.dart';

class AddProduct extends StatefulWidget {
  AddProduct(this.product);

  final ChipChopProducts product;
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController priceController = TextEditingController();

  Map<String, String> _stores = {"0": "Choose your Store"};
  Map<String, String> _locations = {"0": "Choose your Branch"};
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
  String _selectedLocation = "0";
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
  String storeUUID = "";
  String locUUID = "";
  double weight = 0.00;
  int unit = 0;
  double originalPrice = 0.00;
  double offer = 0.00;
  double currentPrice = 0.00;
  bool isAvailable = true;
  bool isDeliverable = true;
  List<String> keywords = [];

  @override
  void initState() {
    super.initState();

    loadStores();
    loadProductTypes();

    if (widget.product != null) {
      this.pImages = widget.product.productImages;
      this.pName = widget.product.name;
      this.shortDetails = widget.product.shortDetails;
      this.productType = widget.product.productType;
      this.productCategory = widget.product.productType;
      this.productSubCategory = widget.product.productSubCategory;
      this.weight = widget.product.weight;
      this.unit = widget.product.unit;
      this.originalPrice = widget.product.originalPrice;
      this.keywords = widget.product.keywords;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColors.sellerLightGrey,
      appBar: AppBar(
        backgroundColor: CustomColors.sellerGreen,
        title: Text("Add Products"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.sellerBlue,
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

      if (_selectedStore == "0") {
        _scaffoldKey.currentState.showSnackBar(
          CustomSnackBar.errorSnackBar("Please select your store!", 2),
        );
        return;
      }

      final FormState form = _formKey.currentState;

      if (form.validate()) {
        Products _p = Products();
        _p.name = pName;
        _p.shortDetails = shortDetails;
        _p.productImages = [""];
        _p.currentPrice = originalPrice - offer;
        _p.originalPrice = originalPrice;
        _p.offer = offer;
        _p.isAvailable = true;
        _p.isDeliverable = true;
        _p.locUUID = _selectedLocation == "0" ? "" : _selectedLocation;
        _p.storeUUID = _selectedStore;
        _p.weight = weight;
        _p.unit = int.parse(_selectedUnit);
        _p.productType = _selectedType == "0" ? "" : _selectedType;
        _p.productCategory = _selectedCategory == "0" ? "" : _selectedCategory;
        _p.productSubCategory =
            _selectedSubCategory == "0" ? "" : _selectedSubCategory;
        CustomDialogs.actionWaiting(context);
        await _p.create();
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
        color: CustomColors.sellerWhite,
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.store,
                size: 35,
                color: CustomColors.sellerBlue,
              ),
              title: Text(
                "Store",
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Georgia',
                  color: CustomColors.sellerBlack,
                ),
              ),
            ),
            ListTile(
              leading: Text(""),
              title: DropdownButton<String>(
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
            ListTile(
              leading: Icon(
                Icons.branding_watermark,
                size: 35,
                color: CustomColors.sellerBlue,
              ),
              title: Text(
                "Branch",
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Georgia',
                  color: CustomColors.sellerBlack,
                ),
              ),
            ),
            ListTile(
              leading: Text(""),
              title: DropdownButton<String>(
                isExpanded: true,
                items: _locations.entries.map(
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
                      _selectedLocation = uuid;
                    },
                  );
                },
                value: _selectedLocation,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.image,
                size: 35,
                color: CustomColors.sellerBlue,
              ),
              title: Text(
                "Add Images",
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Georgia',
                  color: CustomColors.sellerBlack,
                ),
              ),
            ),
            Container(
              height: 130,
              child: SingleChildScrollView(
                primary: true,
                scrollDirection: Axis.vertical,
                reverse: true,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              alignment: Alignment.center,
                              height: 125,
                              width: 125,
                              child: Text(
                                "Add Image",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: CustomColors.sellerWhite,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: CustomColors.sellerGrey,
                                border: Border.all(
                                    width: 1,
                                    style: BorderStyle.solid,
                                    color: CustomColors.sellerBlue),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              alignment: Alignment.center,
                              height: 125,
                              width: 125,
                              child: Text(
                                "Add Image",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: CustomColors.sellerWhite,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: CustomColors.sellerGrey,
                                border: Border.all(
                                  width: 1,
                                  style: BorderStyle.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              alignment: Alignment.center,
                              height: 125,
                              width: 125,
                              child: Text(
                                "Add Image",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: CustomColors.sellerWhite,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: CustomColors.sellerGrey,
                                border: Border.all(
                                    width: 1, style: BorderStyle.none),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              alignment: Alignment.center,
                              height: 125,
                              width: 125,
                              child: Text(
                                "Add Image",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: CustomColors.sellerWhite,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: CustomColors.sellerGrey,
                                border: Border.all(
                                    width: 1, style: BorderStyle.none),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.format_shapes,
                size: 35,
                color: CustomColors.sellerBlue,
              ),
              title: Text(
                "Product Name",
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Georgia',
                  color: CustomColors.sellerBlack,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 60.0),
              child: TextFormField(
                initialValue: pName,
                textAlign: TextAlign.start,
                autofocus: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "Ex, Rice",
                  fillColor: CustomColors.sellerWhite,
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
                color: CustomColors.sellerBlue,
              ),
              title: Text(
                "Product Details",
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Georgia',
                  color: CustomColors.sellerBlack,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 60.0),
              child: TextFormField(
                initialValue: shortDetails,
                textAlign: TextAlign.start,
                autofocus: false,
                keyboardType: TextInputType.text,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: "Ex, Rice",
                  fillColor: CustomColors.sellerWhite,
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
                color: CustomColors.sellerBlue,
              ),
              title: Text(
                "Product Type",
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Georgia',
                  color: CustomColors.sellerBlack,
                ),
              ),
            ),
            ListTile(
              leading: Text(""),
              title: DropdownButton<String>(
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
            ListTile(
              leading: Icon(
                Icons.menu,
                size: 35,
                color: CustomColors.sellerBlue,
              ),
              title: Text(
                "Product Category",
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Georgia',
                  color: CustomColors.sellerBlack,
                ),
              ),
            ),
            ListTile(
              leading: Text(""),
              title: DropdownButton<String>(
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
            ListTile(
              leading: Icon(
                Icons.apps,
                size: 35,
                color: CustomColors.sellerBlue,
              ),
              title: Text(
                "Product SubCategory",
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Georgia',
                  color: CustomColors.sellerBlack,
                ),
              ),
            ),
            ListTile(
              leading: Text(""),
              title: DropdownButton<String>(
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
            Padding(padding: EdgeInsets.all(5)),
            Row(children: [
              Expanded(
                child: TextFormField(
                  initialValue: weight.toString(),
                  textAlign: TextAlign.start,
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Weight",
                    labelText: "Weight",
                    fillColor: CustomColors.sellerWhite,
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
              Flexible(
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
            ]),
            Row(children: [
              Expanded(
                child: TextFormField(
                  initialValue: originalPrice.toString(),
                  textAlign: TextAlign.start,
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Price",
                    labelText: "Price",
                    fillColor: CustomColors.sellerWhite,
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
              Flexible(
                child: TextFormField(
                  initialValue: offer.toString(),
                  textAlign: TextAlign.start,
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Offer",
                    labelText: "Offer",
                    fillColor: CustomColors.sellerWhite,
                    filled: true,
                  ),
                  onChanged: (val) {
                    if (originalPrice <= 0) {
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
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Text(
                    "Current Price",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Georgia',
                      color: CustomColors.sellerBlack,
                    ),
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: priceController,
                      textAlign: TextAlign.end,
                      readOnly: true,
                      decoration: InputDecoration(
                        fillColor: CustomColors.sellerWhite,
                        filled: true,
                      ),
                    ),
                  ),
                ],
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
          storeList[b.uuid] = b.storeName;
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
  }

  onStoreDropdownItem(String uuid) async {
    if (uuid == "0") {
      setState(
        () {
          _selectedStore = uuid;
        },
      );
      return;
    }

    List<StoreLocations> branches = await Store().getLocations(uuid);
    Map<String, String> branchList = Map();
    if (branches.length > 0) {
      branches.forEach(
        (b) {
          branchList[b.uuid] = b.locationName;
        },
      );

      setState(
        () {
          _selectedStore = uuid;
          _locations = _locations..addAll(branchList);
        },
      );
    } else {
      setState(
        () {
          _selectedStore = uuid;
        },
      );
    }
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
        await ProductTypes().getCategories(uuid);
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
        await ProductCategories().getSubCategories(_selectedType, uuid);
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
  }
}

class Search extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  ChipChopProducts selectedResult;

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          print("Product clicked");
        },
        child: Text(selectedResult != null ? selectedResult.name : ""),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<ChipChopProducts>>(
      future: ChipChopProducts().searchByKeyword(query),
      builder: (BuildContext context,
          AsyncSnapshot<List<ChipChopProducts>> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            children = ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    snapshot.data[index].name,
                  ),
                  leading: query.isEmpty ? Icon(Icons.access_time) : SizedBox(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProduct(snapshot.data[index]),
                        settings: RouteSettings(name: '/settings/products/add'),
                      ),
                    );

                    // print("Product onclick event");
                    // selectedResult = snapshot.data[index];
                    // showResults(context);
                  },
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
                    "No Products Found",
                    style: TextStyle(
                      color: CustomColors.sellerAlertRed,
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
                      color: CustomColors.sellerBlue,
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
}
