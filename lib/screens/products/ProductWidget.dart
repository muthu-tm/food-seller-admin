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
  bool isSwitched = false;

  @override
  void initState() {
    super.initState();
    isSwitched = widget.product.isAvailable;
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
              CachedNetworkImage(
                imageUrl: widget.product.getProductImage(),
                imageBuilder: (context, imageProvider) => Container(
                  width: 70,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
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
                    onChanged: (value) async {
                      isSwitched = value;
                      await widget.product
                          .updateProductStatus(widget.product.uuid, value);
                    },
                    inactiveTrackColor: CustomColors.alertRed,
                    activeTrackColor: CustomColors.green,
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
