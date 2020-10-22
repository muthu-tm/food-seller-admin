import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/screens/products/ProductDetailsScreen.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SubCategoriesProductsScreen extends StatefulWidget {
  SubCategoriesProductsScreen(
      this.storeID, this.storeName, this.categoryID, this.subCategoryID, this.subCategoryName);

  final String storeID;
  final String storeName;
  final String categoryID;
  final String subCategoryID;
  final String subCategoryName;
  @override
  _SubCategoriesProductsScreenState createState() =>
      _SubCategoriesProductsScreenState();
}

class _SubCategoriesProductsScreenState
    extends State<SubCategoriesProductsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.subCategoryName,
            textAlign: TextAlign.start,
            style: TextStyle(color: CustomColors.black, fontSize: 16),
          ),
          backgroundColor: CustomColors.green,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: CustomColors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: Products().streamProductsForSubCategory(
              widget.storeID, widget.categoryID, widget.subCategoryID),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            Widget children;

            if (snapshot.hasData) {
              if (snapshot.data.documents.isNotEmpty) {
                children = Container(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                    shrinkWrap: true,
                    mainAxisSpacing: 10,
                    children: List.generate(
                      snapshot.data.documents.length,
                      (index) {
                        Products product = Products.fromJson(
                            snapshot.data.documents[index].data);

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsScreen(product),
                                settings:
                                    RouteSettings(name: '/products'),
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              color: CustomColors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Hero(
                                      tag: "${product.uuid}",
                                      child: CachedNetworkImage(
                                        imageUrl: product.getProductImage(),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          width: 100,
                                          height: 75,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                            shape: BoxShape.rectangle,
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: imageProvider),
                                          ),
                                        ),
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                          Icons.error,
                                          size: 35,
                                        ),
                                        fadeOutDuration: Duration(seconds: 1),
                                        fadeInDuration: Duration(seconds: 2),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${product.weight} ${product.getUnit()}",
                                          style: TextStyle(
                                            color: CustomColors.black,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Rs. ${product.currentPrice.toString()}",
                                          style: TextStyle(
                                            color: CustomColors.black,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    color: CustomColors.blue,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                children = Container(
                  padding: EdgeInsets.all(10),
                  color: CustomColors.white,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    children: [
                      Text(
                        "No Products added By Store",
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: CustomColors.alertRed,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "No Worries!",
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: CustomColors.grey,
                          fontSize: 14.0,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "You could still place Written/Captured ORDER here.",
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          color: CustomColors.blue,
                          fontSize: 16.0,
                        ),
                      )
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
        ));
  }
}
