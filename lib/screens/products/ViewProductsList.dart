import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/products/ProductWidget.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewProductsListScreen extends StatefulWidget {
  ViewProductsListScreen(this.store);

  final Store store;
  @override
  _ViewProductsListScreenState createState() => _ViewProductsListScreenState();
}

class _ViewProductsListScreenState extends State<ViewProductsListScreen> {
  String filterBy = "0";

  Map<String, String> _selectedFilter = {
    "0": "All",
    "1": "Active",
    "2": "InActive",
    "3": "Popular",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColors.lightGrey,
        appBar: AppBar(
          title: Text(
            "All Products",
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
        body: Container(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    width: 150,
                    height: 40,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Filter",
                        labelStyle: TextStyle(
                          color: CustomColors.blue,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        fillColor: CustomColors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.white),
                        ),
                      ),
                      items: _selectedFilter.entries.map(
                        (f) {
                          return DropdownMenuItem<String>(
                            value: f.key,
                            child: Text(f.value),
                          );
                        },
                      ).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          filterBy = newVal;
                        });
                      },
                      value: filterBy,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: getProducts(context),
              ),
            ],
          ),
        ));
  }

  Widget getProducts(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: filterBy == '0'
          ? Products().streamProducts(widget.store.uuid)
          : filterBy == '1'
              ? Products().streamAvailableProducts(widget.store.uuid)
              : filterBy == '2'
                  ? Products().streamUnAvailableProducts(widget.store.uuid)
                  : Products().streamPopularProducts(widget.store.uuid),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.documents.isNotEmpty) {
            children = ListView.builder(
                scrollDirection: Axis.vertical,
                primary: true,
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  Products product =
                      Products.fromJson(snapshot.data.documents[index].data);
                  return ProductWidget(product);
                });
          } else {
            children = Center(
              child: Container(
                height: 90,
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    Text(
                      "No Product Available",
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
