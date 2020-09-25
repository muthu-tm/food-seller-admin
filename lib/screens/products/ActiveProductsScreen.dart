import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ActiveProductsScreen extends StatefulWidget {
  ActiveProductsScreen(this.store);

  final Store store;
  @override
  _ActiveProductsScreenState createState() => _ActiveProductsScreenState();
}

class _ActiveProductsScreenState extends State<ActiveProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.sellerLightGrey,
      appBar: AppBar(
        backgroundColor: CustomColors.sellerGreen,
        title: Text("Active Products"),
      ),
      body: getProductsByStoreLocation(context),
    );
  }

  Widget getProductsByStoreLocation(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Products().streamAvailableProducts(
          widget.store.uuid, widget.store.location.uuid),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.documents.isNotEmpty) {
            children = GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              children: List.generate(snapshot.data.documents.length, (index) {
                Products product =
                    Products.fromJson(snapshot.data.documents[index].data);

                return InkWell(
                  onTap: () {
                    print("Products Open");
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 20),
                    color: CustomColors.sellerWhite,
                    height: 100,
                    alignment: Alignment.centerLeft,
                    child: Center(
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: product.getProductImage(),
                            imageBuilder: (context, imageProvider) => Container(
                              width: 125,
                              height: 105,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                    fit: BoxFit.fill, image: imageProvider),
                              ),
                            ),
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) => Icon(
                              Icons.error,
                              size: 35,
                            ),
                            fadeOutDuration: Duration(seconds: 1),
                            fadeInDuration: Duration(seconds: 2),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      color: CustomColors.sellerBlue,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    "${product.weight} ${product.getUnit()} - Rs. ${product.originalPrice.toString()}",
                                    style: TextStyle(
                                      color: CustomColors.sellerBlue,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          } else {
            children = Container(
              height: 90,
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    "No Product Available",
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
