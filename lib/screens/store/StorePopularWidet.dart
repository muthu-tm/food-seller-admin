import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/screens/store/ProductDetailsScreen.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StorePopulartWidget extends StatefulWidget {
  StorePopulartWidget(this.storeID);

  final String storeID;
  @override
  _StorePopulartWidgetState createState() => _StorePopulartWidgetState();
}

class _StorePopulartWidgetState extends State<StorePopulartWidget> {
  Map<String, double> _cartMap = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Products().streamPopularProducts(widget.storeID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.documents.isNotEmpty) {
            children = GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              children: List.generate(
                snapshot.data.documents.length,
                (index) {
                  Products product =
                      Products.fromJson(snapshot.data.documents[index].data);

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(product),
                          settings: RouteSettings(name: '/store/products'),
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Hero(
                                tag: "${product.uuid}",
                                child: CachedNetworkImage(
                                  imageUrl: product.getProductImage(),
                                  imageBuilder: (context, imageProvider) =>
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
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                    "Rs. ${product.originalPrice.toString()}",
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _cartMap.containsKey(product.uuid)
                                  ? Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          _cartMap[product.uuid] == 1.0
                                              ? SizedBox(
                                                  width: 35,
                                                  height: 35,
                                                  child: OutlineButton(
                                                    padding: EdgeInsets.zero,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    onPressed: () async {
                                                    },
                                                    child: Icon(
                                                      Icons.delete_forever,
                                                      size: 20,
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(
                                                  width: 35,
                                                  height: 35,
                                                  child: OutlineButton(
                                                    padding: EdgeInsets.zero,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    onPressed: () async {
                                                    },
                                                    child: Icon(Icons.remove),
                                                  ),
                                                ),
                                          Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              _cartMap[product.uuid]
                                                  .round()
                                                  .toString(),
                                              style: TextStyle(
                                                  fontFamily: 'Georgia',
                                                  color: CustomColors.blue,
                                                  fontSize: 17),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 35,
                                            height: 35,
                                            child: OutlineButton(
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              onPressed: () async {
                                              },
                                              child: Icon(Icons.add),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Card(
                                      elevation: 2.0,
                                      color: CustomColors.lightGreen,
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        child: IconButton(
                                          iconSize: 20,
                                          alignment: Alignment.center,
                                          icon: Icon(FontAwesomeIcons.cartPlus),
                                          onPressed: () async {
                                          },
                                        ),
                                      ),
                                    ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
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
                    "No Popular Products added By Store",
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
                    "You could still order your favourite item with Written/Capture ORDER option!",
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
    );
  }
}
