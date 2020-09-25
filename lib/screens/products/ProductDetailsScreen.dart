import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Products product;

  ProductDetailsScreen(this.product);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Detail"),
      ),
      body: getProductDetailView(),
    );
  }

  Widget getProductDetailView() {
    return Center(
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: widget.product.getProductImage(),
            imageBuilder: (context, imageProvider) => Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * .75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                shape: BoxShape.rectangle,
                image:
                    DecorationImage(fit: BoxFit.fill, image: imageProvider),
              ),
            ),
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
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
                    widget.product.name,
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
                    "${widget.product.weight} ${widget.product.getUnit()} - Rs. ${widget.product.originalPrice.toString()}",
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
    );
  }
}
