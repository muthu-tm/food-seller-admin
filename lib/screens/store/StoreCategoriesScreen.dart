import 'package:chipchop_seller/db/models/product_sub_categories.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/store/CategoriesProductsWidget.dart';
import 'package:chipchop_seller/screens/store/SubCategoriesProductScreen.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class StoreCategoriesScreen extends StatefulWidget {
  StoreCategoriesScreen(
      this.subCategories, this.store, this.categoryID, this.categoryName);

  final List<ProductSubCategories> subCategories;
  final Store store;
  final String categoryID;
  final String categoryName;
  @override
  _StoreCategoriesScreenState createState() => _StoreCategoriesScreenState();
}

class _StoreCategoriesScreenState extends State<StoreCategoriesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _subCategoryID = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.categoryName,
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        backgroundColor: CustomColors.primary,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: CustomColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.all(5.0),
              child: ListView.builder(
                primary: true,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: widget.subCategories.length,
                padding: EdgeInsets.all(5),
                itemBuilder: (BuildContext context, int index) {
                  ProductSubCategories _sc = widget.subCategories[index];
                  return Padding(
                    padding: EdgeInsets.only(left: 5.0, right: 5),
                    child: ActionChip(
                      elevation: 6.0,
                      backgroundColor: _subCategoryID == _sc.uuid
                          ? CustomColors.primary
                          : Colors.white,
                      onPressed: () {
                        setState(() {
                          _subCategoryID = _sc.uuid;
                        });
                      },
                      label: Text(
                        _sc.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: _subCategoryID == _sc.uuid
                                ? Colors.black54
                                : CustomColors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            _subCategoryID.isEmpty
                ? CategoriesProductsWidget(
                    widget.store.uuid, widget.store.name, widget.categoryID)
                : SubCategoriesProductsWidget(widget.store.uuid,
                    widget.store.name, widget.categoryID, _subCategoryID)
          ],
        ),
      ),
    );
  }
}
