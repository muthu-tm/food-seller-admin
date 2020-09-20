import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/app/appBar.dart';
import 'package:chipchop_seller/screens/app/sideDrawer.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ActiveProductsScreen extends StatefulWidget {
  @override
  _ActiveProductsScreenState createState() => _ActiveProductsScreenState();
}

class _ActiveProductsScreenState extends State<ActiveProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.sellerLightGrey,
      appBar: appBar(context),
      drawer: sideDrawer(context),
      body: SingleChildScrollView(
        child: getStores(context),
      ),
    );
  }

  Widget getStores(BuildContext context) {
    return FutureBuilder<List<Store>>(
      future: Store().getStoresWithLocation(),
      builder: (BuildContext context, AsyncSnapshot<List<Store>> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            children = ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Store store = snapshot.data[index];
                return Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    color: CustomColors.sellerWhite,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Text(
                          store.storeName,
                          style: TextStyle(
                            fontFamily: "Georgia",
                            fontWeight: FontWeight.bold,
                            color: CustomColors.sellerGreen,
                            fontSize: 17.0,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: "Generate Products Report",
                          icon: Icon(
                            Icons.print,
                            size: 30,
                            color: CustomColors.sellerBlue,
                          ),
                          onPressed: () async {},
                        ),
                      ),
                      Divider(color: CustomColors.sellerBlue),
                      Center(
                        child: getProductsByStoreLocation(context, store),
                      )
                    ],
                  ),
                );
              },
            );
          } else {
            children = Container(
              color: CustomColors.sellerWhite,
              height: 90,
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    "No Store Available",
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
                    "Add your Store Now!",
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

  Widget getProductsByStoreLocation(BuildContext context, Store store) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          Products().streamAvailableProducts(store.uuid, store.location.uuid),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.documents.isNotEmpty) {
            children = ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                Products product =
                    Products.fromJson(snapshot.data.documents[index].data);
                return InkWell(
                  onTap: () {
                    print("Products Open");
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: CustomColors.sellerWhite,
                    height: 120,
                    width: MediaQuery.of(context).size.width * 0.9,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: product.getProductImage(),
                          imageBuilder: (context, imageProvider) => Container(
                            width: MediaQuery.of(context).size.width * 0.40,
                            height: 100,
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
                        Column(
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                color: CustomColors.sellerBlue,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
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
