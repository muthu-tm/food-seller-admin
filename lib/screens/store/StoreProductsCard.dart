import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/db/models/user_activity_tracker.dart';
import 'package:chipchop_seller/screens/products/EditProducts.dart';
import 'package:chipchop_seller/screens/products/ProductDetailsScreen.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StoreProductsCard extends StatefulWidget {
  StoreProductsCard(this.product);

  final Products product;

  @override
  _StoreProductsCardState createState() => _StoreProductsCardState();
}

class _StoreProductsCardState extends State<StoreProductsCard> {
  String _variant = "0";

  String getVarientID(String id) {
    return id.split("_")[1];
  }

  String getCartID() {
    return '${widget.product.uuid}_$_variant';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        UserActivityTracker _activity = UserActivityTracker();
        _activity.keywords = "";
        _activity.storeID = widget.product.storeID;
        _activity.productID = widget.product.uuid;
        _activity.productName = widget.product.name;
        _activity.refImage = widget.product.getProductImage();
        _activity.type = 2;
        _activity.create();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(widget.product),
            settings: RouteSettings(name: '/store/products'),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(3),
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
                CachedNetworkImage(
                  imageUrl: widget.product.getProductImage(),
                  imageBuilder: (context, imageProvider) => Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          fit: BoxFit.fill, image: imageProvider),
                    ),
                  ),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    size: 35,
                  ),
                  fadeOutDuration: Duration(seconds: 1),
                  fadeInDuration: Duration(seconds: 2),
                ),
                Flexible(
                  child: Column(
                    children: [
                      widget.product.variants.length > 1
                          ? Container(
                              height: 25,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              // dropdown below..
                              child: DropdownButton<String>(
                                value: _variant,
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: CustomColors.primary,
                                ),
                                iconSize: 30,
                                underline: SizedBox(),
                                onChanged: (String newValue) {
                                  setState(() {
                                    _variant = newValue;
                                  });
                                },
                                items: List.generate(
                                    widget.product.variants.length,
                                    (int index) {
                                  return DropdownMenuItem(
                                    value: widget.product.variants[index].id,
                                    child: Container(
                                      child: Text(
                                        "${widget.product.variants[index].weight} ${widget.product.variants[index].getUnit()}",
                                        style: TextStyle(
                                          color: CustomColors.black,
                                          fontSize: 13.0,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            )
                          : Container(
                              height: 25,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                "${widget.product.variants[0].weight} ${widget.product.variants[0].getUnit()}",
                                style: TextStyle(
                                  color: CustomColors.black,
                                  fontSize: 13.0,
                                ),
                              ),
                            ),
                      SizedBox(width: 10),
                      Text(
                        " ₹ ${widget.product.variants[int.parse(_variant)].currentPrice.toString()}",
                        style: TextStyle(
                          color: CustomColors.black,
                          fontSize: 12.0,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            widget.product.brandName != null &&
                    widget.product.brandName.isNotEmpty
                ? Row(
                    children: [
                      SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          widget.product.brandName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: CustomColors.black,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
            Flexible(
              child: Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CustomColors.blue,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              InkWell(
                child: Container(
                  width: 35,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.orange[300],
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.edit,
                    color: CustomColors.black,
                    size: 20.0,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProducts(widget.product),
                      settings: RouteSettings(name: '/products/edit'),
                    ),
                  );
                },
              ),
              InkWell(
                child: Container(
                  width: 35,
                  height: 30,
                  decoration: BoxDecoration(
                    color: CustomColors.alertRed,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_forever,
                    color: CustomColors.white,
                    size: 22.0,
                  ),
                ),
                onTap: () async {
                  CustomDialogs.confirm(context, 'Confirm !',
                      "Are You Sure to Remove this Product ?", () async {
                    bool res = await Products().removeByID(widget.product.uuid);
                    Navigator.pop(context);

                    if (res) {
                      Fluttertoast.showToast(
                          msg: 'Removed Successfully',
                          backgroundColor: CustomColors.primary,
                          textColor: CustomColors.black);
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Error, Unable to Remove now !',
                          backgroundColor: CustomColors.alertRed,
                          textColor: CustomColors.white);
                    }
                  }, () {
                    Navigator.pop(context);
                  });
                },
              ),
              InkWell(
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color:
                        widget.product.variants[int.parse(_variant)].isAvailable
                            ? Colors.green
                            : Colors.red[300],
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                  padding: EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.solidHandPointUp,
                        color: CustomColors.white,
                        size: 15,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Stock",
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () async {
                  await widget.product.updateProductStatus(
                      widget.product.uuid,
                      _variant,
                      !widget
                          .product.variants[int.parse(_variant)].isAvailable);
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
