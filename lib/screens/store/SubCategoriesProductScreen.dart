import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/screens/store/StoreProductsCard.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class SubCategoriesProductsWidget extends StatefulWidget {
  SubCategoriesProductsWidget(
      this.storeID, this.storeName, this.categoryID, this.subCategoryID);

  final String storeID;
  final String storeName;
  final String categoryID;
  final String subCategoryID;
  @override
  _SubCategoriesProductsWidgetState createState() =>
      _SubCategoriesProductsWidgetState();
}

class _SubCategoriesProductsWidgetState
    extends State<SubCategoriesProductsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Products>>(
      future: Products().getProductsForSubCategories(
          widget.storeID, widget.categoryID, widget.subCategoryID),
      builder: (BuildContext context, AsyncSnapshot<List<Products>> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            children = Container(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                mainAxisSpacing: 10,
                children: List.generate(
                  snapshot.data.length,
                  (index) {
                    return StoreProductsCard(snapshot.data[index]);
                  },
                ),
              ),
            );
          } else {
            children = Container(
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.9,
              alignment: Alignment.center,
              child: Text(
                "No Products added By Store !!",
                style: TextStyle(
                  color: CustomColors.alertRed,
                  fontSize: 16.0,
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
