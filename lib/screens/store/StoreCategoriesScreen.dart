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
  bool isListView;

  @override
  void initState() {
    isListView = true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.categoryName,
              textAlign: TextAlign.start,
              style: TextStyle(color: CustomColors.black, fontSize: 16),
            ),
            Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black),
              ),
              child: Row(children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      isListView = !isListView;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Icon(Icons.grid_view,
                        size: 20,
                        color: isListView ? Colors.black : Colors.white),
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Colors.black,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isListView = !isListView;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: Icon(Icons.list,
                        size: 25,
                        color: isListView ? Colors.white : Colors.black),
                  ),
                ),
              ]),
            )
          ],
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.subCategories.length > 0
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Row(
                        children: [
                          ActionChip(
                            elevation: 4.0,
                            backgroundColor: _subCategoryID == ""
                                ? CustomColors.primary
                                : Colors.white,
                            onPressed: () {
                              setState(() {
                                _subCategoryID = "";
                              });
                            },
                            label: Text(
                              "All",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: CustomColors.black),
                            ),
                          ),
                          Container(
                            height: 50,
                            padding: EdgeInsets.only(right: 5),
                            child: ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.subCategories.length,
                              padding: EdgeInsets.all(5),
                              itemBuilder: (BuildContext context, int index) {
                                ProductSubCategories _sc =
                                    widget.subCategories[index];
                                return Padding(
                                  padding: EdgeInsets.only(left: 5.0, right: 5),
                                  child: ActionChip(
                                    elevation: 4.0,
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
                        ],
                      ),
                    ),
                  )
                : Container(),
            _subCategoryID.isEmpty
                ? CategoriesProductsWidget(widget.store.uuid, widget.store.name,
                    widget.categoryID, isListView)
                : SubCategoriesProductsWidget(
                    widget.store.uuid,
                    widget.store.name,
                    widget.categoryID,
                    _subCategoryID,
                    isListView)
          ],
        ),
      ),
    );
  }
}
