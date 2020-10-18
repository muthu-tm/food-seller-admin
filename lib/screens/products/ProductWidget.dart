import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/screens/products/EditProducts.dart';
import 'package:chipchop_seller/screens/products/ProductDetailsScreen.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProductWidget extends StatefulWidget {
  ProductWidget(this.product);

  final Products product;

  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  bool isSwitched;

  @override
  void initState() {
    super.initState();
    isSwitched = true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          color: CustomColors.white,
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(widget.product),
                settings: RouteSettings(name: '/settings/products/view'),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.product.getProductImage(),
                    imageBuilder: (context, imageProvider) => Container(
                      width: 60,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
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
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      color: CustomColors.blue,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${widget.product.weight} ${widget.product.getUnit()} - Rs. ${widget.product.originalPrice.toString()}",
                    style: TextStyle(
                      color: CustomColors.blue,
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      FontAwesomeIcons.solidEdit,
                      color: CustomColors.alertRed,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProducts(widget.product),
                          settings:
                              RouteSettings(name: '/settings/products/edit'),
                        ),
                      );
                    },
                  ),
                  Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        isSwitched = value;
                      });
                    },
                    inactiveTrackColor: Colors.red,
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
