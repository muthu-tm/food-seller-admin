import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/db/models/user_activity_tracker.dart';
import 'package:chipchop_seller/screens/products/ProductDetailsScreen.dart';
import 'package:chipchop_seller/screens/store/ProductListWidget.dart';
import 'package:chipchop_seller/screens/store/StoreProductsCard.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SubCategoriesProductsWidget extends StatefulWidget {
  SubCategoriesProductsWidget(
      this.storeID, this.storeName, this.categoryID, this.subCategoryID,
      [this.isListView = false]);

  final String storeID;
  final String storeName;
  final String categoryID;
  final String subCategoryID;
  final bool isListView;

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

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data.isNotEmpty) {
            children = widget.isListView
                ? ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(
                          color: Colors.white,
                        ),
                    padding: EdgeInsets.all(0),
                    primary: false,
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      Products product = snapshot.data[index];
                      return InkWell(
                        onTap: () {
                          UserActivityTracker _activity = UserActivityTracker();
                          _activity.keywords = "";
                          _activity.storeID = product.storeID;
                          _activity.productID = product.uuid;
                          _activity.productName = product.name;
                          _activity.refImage = product.getProductImage();
                          _activity.type = 2;
                          _activity.create();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsScreen(product),
                              settings: RouteSettings(name: '/store/products'),
                            ),
                          );
                        },
                        child: ProductListWidget(product),
                      );
                    })
                : StaggeredGridView.countBuilder(
                    padding: EdgeInsets.all(0),
                    crossAxisCount: 2,
                    primary: false,
                    crossAxisSpacing: 0,
                    shrinkWrap: true,
                    mainAxisSpacing: 10,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      Products product = snapshot.data[index];

                      return InkWell(
                        onTap: () {
                          UserActivityTracker _activity = UserActivityTracker();
                          _activity.keywords = "";
                          _activity.storeID = product.storeID;
                          _activity.productID = product.uuid;
                          _activity.productName = product.name;
                          _activity.refImage = product.getProductImage();
                          _activity.type = 2;
                          _activity.create();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsScreen(product),
                              settings: RouteSettings(name: '/store/products'),
                            ),
                          );
                        },
                        child: StoreProductsCard(product),
                      );
                    },
                    staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                  );
          } else {
            children = Container(
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
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
