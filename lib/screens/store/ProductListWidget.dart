import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/screens/products/EditProducts.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProductListWidget extends StatefulWidget {
  ProductListWidget(this.product);

  final Products product;

  @override
  _ProductListWidgetState createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  String _variant = "0";

  String getVariantID(String id) {
    return id.split("_")[1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 115,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 5),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CachedNetworkImage(
                  height: 100,
                  width: 100,
                  fit: BoxFit.fill,
                  imageUrl: widget.product.getProductImage(),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                          value: downloadProgress.progress),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    height: 100,
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
          ),
          SizedBox(width: 5),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        "${widget.product.name.trim()}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 75)
                  ],
                ),
                SizedBox(height: 5),
                widget.product.shortDetails.trim().isNotEmpty
                    ? Row(
                        children: [
                          Flexible(
                            child: Text(
                              "${widget.product.shortDetails.trim()}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10.0,
                              ),
                            ),
                          ),
                          SizedBox(width: 75)
                        ],
                      )
                    : Container(),
                SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.product.variants.length > 1
                        ? InkWell(
                            child: Row(
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
                                  color: Colors.redAccent,
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
                                                      '₹ ${data.currentPrice.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    SizedBox(
                                                      width: 4,
                                                    ),
                                                    data.offer > 0
                                                        ? Text(
                                                            '₹ ${data.originalPrice.toStringAsFixed(2)}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black54,
                                                                fontSize: 12,
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
                        : Text(
                            "${widget.product.variants[int.parse(_variant)].weight} ${widget.product.variants[int.parse(_variant)].getUnit()}",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13.0,
                            ),
                          ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.product.variants[int.parse(_variant)].offer > 0
                              ? Row(
                                  children: [
                                    Text(
                                      "₹ ${widget.product.variants[int.parse(_variant)].originalPrice.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.black,
                                        fontSize: 10.0,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                  ],
                                )
                              : Container(),
                          Flexible(
                            child: Text(
                              "₹ ${widget.product.variants[int.parse(_variant)].currentPrice.toStringAsFixed(2)}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    widget.product.variants[int.parse(_variant)].offer > 0
                        ? Flexible(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(1.0, 0, 5, 0),
                              child: Text(
                                "You save ₹ ${widget.product.variants[int.parse(_variant)].offer} of total price ",
                                maxLines: 2,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 8.0,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    child: Container(
                      width: 70,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.orange[300],
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            color: CustomColors.white,
                            size: 15,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Edit",
                            style: TextStyle(
                                fontSize: 10.0, fontWeight: FontWeight.bold),
                          )
                        ],
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
                      width: 70,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_forever,
                            color: CustomColors.white,
                            size: 15,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Remove",
                            style: TextStyle(
                                fontSize: 10.0, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    onTap: () async {
                      CustomDialogs.confirm(context, 'Confirm !',
                          "Are You Sure to Remove this Product ?", () async {
                        bool res =
                            await Products().removeByID(widget.product.uuid);
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
                      height: 25,
                      width: 70,
                      decoration: BoxDecoration(
                        color: widget.product.variants[int.parse(_variant)]
                                .isAvailable
                            ? Colors.green
                            : Colors.red[300],
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                      padding: EdgeInsets.all(4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                fontSize: 10.0, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    onTap: () async {
                      await widget.product.updateProductStatus(
                          widget.product.uuid,
                          _variant,
                          !widget.product.variants[int.parse(_variant)]
                              .isAvailable);
                    },
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
