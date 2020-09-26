import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:chipchop_seller/screens/store/StoreCategoryWidget.dart';
import 'package:chipchop_seller/screens/store/StoreSearchBar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../db/models/store.dart';
import '../utils/CustomColors.dart';

class ViewStoreScreen extends StatelessWidget {
  ViewStoreScreen(this.store);

  final Store store;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.sellerLightGrey,
      appBar: AppBar(
        backgroundColor: CustomColors.sellerGreen,
        title: Text(store.name),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Container(
                height: 150.0,
                width: double.infinity,
                child: Carousel(
                  images: getImages(),
                  dotSize: 5.0,
                  dotSpacing: 20.0,
                  dotColor: CustomColors.sellerBlue,
                  indicatorBgPadding: 5.0,
                  dotBgColor: CustomColors.sellerBlack.withOpacity(0.2),
                  borderRadius: true,
                  radius: Radius.circular(20),
                  noRadiusForIndicator: true,
                ),
              ),
            ),
            StoreSearchBar(),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: CustomColors.sellerWhite),
                        child: RawMaterialButton(
                          onPressed: () {},
                          shape: CircleBorder(),
                          child: Icon(
                            Icons.category,
                            color: Color(0xFFAB436B),
                          ),
                        ),
                      ),
                      Text(
                        "Categories",
                        style: TextStyle(
                            color: CustomColors.sellerGrey, fontFamily: 'Georgia'),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: CustomColors.sellerWhite),
                        child: RawMaterialButton(
                          onPressed: () {},
                          shape: CircleBorder(),
                          child: Icon(
                            FontAwesomeIcons.angellist,
                            color: Color(0xFF5EB699),
                          ),
                        ),
                      ),
                      Text(
                        "Popular",
                        style: TextStyle(
                            color: CustomColors.sellerGrey, fontFamily: 'Georgia'),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: CustomColors.sellerWhite),
                        child: RawMaterialButton(
                          onPressed: () {},
                          shape: CircleBorder(),
                          child: Icon(
                            FontAwesomeIcons.clock,
                            color: Color(0xFFC1A17C),
                          ),
                        ),
                      ),
                      Text(
                        "Flash Sale",
                        style: TextStyle(
                            color: CustomColors.sellerGrey, fontFamily: 'Georgia'),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: CustomColors.sellerWhite),
                        child: RawMaterialButton(
                          onPressed: () {},
                          shape: CircleBorder(),
                          child: Icon(
                            FontAwesomeIcons.gift,
                            color: Color(0xFF4D9DA7),
                          ),
                        ),
                      ),
                      Text(
                        "Offers",
                        style: TextStyle(
                            color: CustomColors.sellerGrey, fontFamily: 'Georgia'),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
              child: Container(
                color: CustomColors.sellerLightGrey,
              ),
            ),
            Expanded(
              child: Container(
                child: StoreCategoryWidget(store),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getImages() {
    List<Widget> images = [];

    for (var item in store.getStoreImages()) {
      images.add(
        CachedNetworkImage(
          imageUrl: item,
          imageBuilder: (context, imageProvider) => Image(
            height: 150,
            width: double.infinity,
            fit: BoxFit.contain,
            image: imageProvider,
          ),
          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
            child: SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(
                  value: downloadProgress.progress,
                  valueColor: AlwaysStoppedAnimation(CustomColors.sellerBlue),
                  strokeWidth: 2.0),
            ),
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.error,
            size: 35,
          ),
          fadeOutDuration: Duration(seconds: 1),
          fadeInDuration: Duration(seconds: 2),
        ),
      );
    }

    return images;
  }
}
