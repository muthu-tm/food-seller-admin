import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/screens/store/StoreProductsCard.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class CategoriesProductsWidget extends StatefulWidget {
  CategoriesProductsWidget(this.storeID, this.storeName, this.categoryID);

  final String storeID;
  final String storeName;
  final String categoryID;
  @override
  _CategoriesProductsWidgetState createState() =>
      _CategoriesProductsWidgetState();
}

class _CategoriesProductsWidgetState extends State<CategoriesProductsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Products>>(
      future: Products()
          .getProductsForCategories(widget.storeID, widget.categoryID),
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
                    Products product = snapshot.data[index];

                    return StoreProductsCard(product);
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
