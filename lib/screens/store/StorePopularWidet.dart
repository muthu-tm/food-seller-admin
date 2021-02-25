import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/screens/store/StoreProductsCard.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class StorePopulartWidget extends StatefulWidget {
  StorePopulartWidget(this.storeID, this.storeName);

  final String storeID;
  final String storeName;
  @override
  _StorePopulartWidgetState createState() => _StorePopulartWidgetState();
}

class _StorePopulartWidgetState extends State<StorePopulartWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Products().streamPopularProducts(widget.storeID),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.docs.isNotEmpty) {
            children = SliverStickyHeader(
              header: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Popular Products",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                color: Colors.white,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  Products _p =
                      Products.fromJson(snapshot.data.docs[index].data());
                  return StoreProductsCard(_p);
                }, childCount: snapshot.data.docs.length),
              ),
            );
          } else {
            children = SliverStickyHeader(
              header: Container(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  "Popular Products",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                color: Colors.white,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "No Popular Products added By Store",
                          style: TextStyle(
                            color: CustomColors.alertRed,
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  childCount: 1,
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          children = SliverToBoxAdapter(
            child: Center(
              child: Column(
                children: AsyncWidgets.asyncError(),
              ),
            ),
          );
        } else {
          children = SliverToBoxAdapter(
            child: Center(
              child: Column(
                children: AsyncWidgets.asyncWaiting(),
              ),
            ),
          );
        }

        return children;
      },
    );
  }
}
