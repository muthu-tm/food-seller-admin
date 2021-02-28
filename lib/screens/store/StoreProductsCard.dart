import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/screens/products/EditProducts.dart';
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

  String getVariantID(String id) {
    return id.split("_")[1];
  }

  String getCartID() {
    return '${widget.product.uuid}_$_variant';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 215,
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          height: 90,
                          width: 110,
                          fit: BoxFit.fill,
                          imageUrl: widget.product.getProductImage(),
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Container(
                            width: 110,
                            height: 90,
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 110,
                            height: 90,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.error,
                              size: 35,
                            ),
                          ),
                          fadeOutDuration: Duration(seconds: 1),
                          fadeInDuration: Duration(seconds: 2),
                        ),
                      ),
                    ),
                    widget.product.variants.length > 1
                        ? InkWell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "${widget.product.variants[int.parse(_variant)].weight} ${widget.product.variants[int.parse(_variant)].getUnit()}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13.0,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.green[400],
                                )
                              ],
                            ),
                            onTap: () async {
                              showModalBottomSheet(
                                context: context,
                                builder: (builder) {
                                  return Container(
                                    height: 250,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      height: 60,
                                                      width: 60,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: widget
                                                              .product
                                                              .getSmallProductImage(),
                                                          imageBuilder: (context,
                                                                  imageProvider) =>
                                                              Image(
                                                            fit: BoxFit.fill,
                                                            image:
                                                                imageProvider,
                                                          ),
                                                          progressIndicatorBuilder:
                                                              (context, url,
                                                                      downloadProgress) =>
                                                                  Center(
                                                            child: SizedBox(
                                                              height: 50.0,
                                                              width: 50.0,
                                                              child: CircularProgressIndicator(
                                                                  value: downloadProgress
                                                                      .progress,
                                                                  valueColor: AlwaysStoppedAnimation(
                                                                      CustomColors
                                                                          .blue),
                                                                  strokeWidth:
                                                                      2.0),
                                                            ),
                                                          ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Icon(
                                                            Icons.error,
                                                            size: 35,
                                                          ),
                                                          fadeOutDuration:
                                                              Duration(
                                                                  seconds: 1),
                                                          fadeInDuration:
                                                              Duration(
                                                                  seconds: 2),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Flexible(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Flexible(
                                                            child: Text(
                                                              widget
                                                                  .product.name,
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  color:
                                                                      CustomColors
                                                                          .black,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          widget.product.brandName !=
                                                                      null &&
                                                                  widget
                                                                      .product
                                                                      .brandName
                                                                      .isNotEmpty
                                                              ? Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10.0),
                                                                  child: Text(
                                                                    widget
                                                                        .product
                                                                        .brandName,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black54,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              "Choose Variant",
                                              style: TextStyle(
                                                  color: CustomColors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            ...widget.product.variants.map(
                                              (data) => RadioListTile(
                                                title: Text(
                                                    "${data.weight} ${data.getUnit()}"),
                                                secondary: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '₹ ${data.currentPrice.toString()}',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    data.offer > 0
                                                        ? Text(
                                                            '₹ ${data.originalPrice.toString()}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 14,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                                value: data.id,
                                                groupValue: _variant,
                                                onChanged: (newValue) {
                                                  setState(
                                                    () {
                                                      _variant = newValue;
                                                    },
                                                  );
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(0.0, 0, 0, 0),
                            child: Text(
                              "${widget.product.variants[int.parse(_variant)].weight} ${widget.product.variants[int.parse(_variant)].getUnit()}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          widget.product.variants[int.parse(_variant)].offer > 0
                              ? Row(
                                  children: [
                                    Text(
                                      '₹ ${widget.product.variants[int.parse(_variant)].originalPrice.toString()}',
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                  ],
                                )
                              : Container(),
                          Text(
                            '₹ ${widget.product.variants[int.parse(_variant)].currentPrice.toString()}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                    builder: (context) =>
                                        EditProducts(widget.product),
                                    settings:
                                        RouteSettings(name: '/products/edit'),
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
                                    "Are You Sure to Remove this Product ?",
                                    () async {
                                  bool res = await Products()
                                      .removeByID(widget.product.uuid);
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
                                  color: widget
                                          .product
                                          .variants[int.parse(_variant)]
                                          .isAvailable
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
                                        .product
                                        .variants[int.parse(_variant)]
                                        .isAvailable);
                              },
                            ),
                          ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            "${widget.product.name}",
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}
