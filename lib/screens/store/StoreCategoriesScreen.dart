import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/store/CategoriesProductsScreen.dart';
import 'package:chipchop_seller/screens/store/SubCategoriesTab.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class StoreCategoriesScreen extends StatefulWidget {
  StoreCategoriesScreen(this.store, this.categoryID, this.categoryName);

  final Store store;
  final String categoryID;
  final String categoryName;
  @override
  _StoreCategoriesScreenState createState() => _StoreCategoriesScreenState();
}

class _StoreCategoriesScreenState extends State<StoreCategoriesScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
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
        bottom: TabBar(
          controller: _controller,
          labelColor: CustomColors.white,
          indicatorWeight: 0,
          indicator: BoxDecoration(
            color: CustomColors.alertRed,
            borderRadius: BorderRadius.circular(5),
          ),
          tabs: [
            Tab(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Sub Categories",
                ),
              ),
            ),
            Tab(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Products",
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          SingleChildScrollView(
            child: SubCategoriesTab(widget.categoryID, widget.store),
          ),
          CategoriesProductsScreen(widget.store.uuid,
              widget.store.name, widget.categoryID),
        ],
      ),
    );
  }
}
