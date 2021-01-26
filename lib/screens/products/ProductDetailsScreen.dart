import 'package:chipchop_seller/db/models/product_description.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/products/ProductFAQsWidget.dart';
import 'package:chipchop_seller/screens/products/ProductReviewWidget.dart';
import 'package:chipchop_seller/screens/store/StoreProfileWidget.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CarouselIndicatorSlider.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/ReadMoreText.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../db/models/products.dart';
import '../utils/CustomColors.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Products product;

  ProductDetailsScreen(this.product);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _variants = "0";
  TabController _controller;
  List<Widget> list = [
    Tab(
      text: "From Store",
    ),
    Tab(
      text: "Reviews",
    ),
    Tab(
      text: "FAQs",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: list.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.lightGrey,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: CustomColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: CustomColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(primary: true, child: getBody(context)),
    );
  }

  Widget getBody(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double abovePadding = MediaQuery.of(context).padding.top;
    double appBarHeight = AppBar().preferredSize.height;
    double remainingHeight = screenHeight - abovePadding - appBarHeight;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: CarouselIndicatorSlider(
                widget.product.getProductImages(), (remainingHeight) / 2),
          ),
          widget.product.brandName != null &&
                  widget.product.brandName.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    widget.product.brandName,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              child: Text(
                widget.product.name,
                style: TextStyle(
                    color: CustomColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          widget.product.shortDetails != null &&
                  widget.product.shortDetails.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: ReadMoreText(
                    widget.product.shortDetails,
                    trimLines: 3,
                    colorClickableText: Colors.redAccent,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: '... read more',
                    trimExpandedText: ' read less',
                  ),
                )
              : Container(),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                '₹ ${widget.product.variants[int.parse(_variants)].currentPrice.toString()}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: 6,
              ),
              widget.product.variants[int.parse(_variants)].offer > 0
                  ? Text(
                      '₹ ${widget.product.variants[int.parse(_variants)].originalPrice.toString()}',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough),
                    )
                  : Container(),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (widget.product.variants.length == 1)
                    ? Container(
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          "${widget.product.variants[0].weight} ${widget.product.variants[0].getUnit()}",
                          style: TextStyle(
                            color: CustomColors.black,
                            fontSize: 14.0,
                          ),
                        ),
                      )
                    : Container(
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        // dropdown below..
                        child: DropdownButton<String>(
                          value: _variants,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: CustomColors.primary,
                          ),
                          iconSize: 30,
                          underline: SizedBox(),
                          onChanged: (String newValue) {
                            setState(() {
                              _variants = newValue;
                            });
                          },
                          items: List.generate(widget.product.variants.length,
                              (int index) {
                            return DropdownMenuItem(
                              value: widget.product.variants[index].id,
                              child: Container(
                                child: Text(
                                  "${widget.product.variants[index].weight} ${widget.product.variants[index].getUnit()}",
                                  style: TextStyle(
                                    color: CustomColors.black,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          getHighlightedDetails(),
          SizedBox(
            height: 10,
          ),
          widget.product.productDescription != null &&
                  widget.product.productDescription.isNotEmpty
              ? Container(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Product Details",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Card(
                        elevation: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: CustomColors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          child: getProductDetails(),
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
          SizedBox(
            height: 10,
          ),
          Container(
            child: TabBar(
                indicator: BoxDecoration(color: Colors.blueAccent),
                labelColor: CustomColors.white,
                unselectedLabelColor: CustomColors.black,
                controller: _controller,
                tabs: list),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 150,
            child: TabBarView(
              controller: _controller,
              children: [
                Container(
                  child: getStoreDetails(context),
                ),
                SingleChildScrollView(
                  child: ProductReviewWidget(
                      widget.product.uuid, widget.product.name),
                ),
                SingleChildScrollView(
                    child: ProductFAQsWidget(widget.product.uuid)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getStoreDetails(BuildContext context) {
    return FutureBuilder(
      future: Store().getByID(widget.product.storeID),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            Store _s = Store.fromJson(snapshot.data);
            return SingleChildScrollView(
              child: Column(
                children: [
                  StoreProfileWidget(_s),
                  Container(
                    color: CustomColors.lightGrey,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Column(
                      children: [
                        _s.availablePayments.contains(0)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.moneyBill,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "Cash On Delivery",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.moneyBill,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "COD Not Available",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        widget.product.isDeliverable
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.pedal_bike,
                                    size: 20,
                                    color: CustomColors.blue,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "Minimum Delivery Charge\* :  ${_s.deliveryDetails.deliveryCharges02}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              )
                            : Container()
                      ],
                    ),
                  )
                ],
              ),
            );
          } else {
            return Container(
              padding: EdgeInsets.all(10),
              color: CustomColors.white,
              width: MediaQuery.of(context).size.width,
              child: Text(
                "Unable to load Store Details",
                style: TextStyle(
                  color: CustomColors.alertRed,
                  fontSize: 16.0,
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              children: AsyncWidgets.asyncError(),
            ),
          );
        } else {
          return Center(
            child: Column(
              children: AsyncWidgets.asyncWaiting(),
            ),
          );
        }
      },
    );
  }

  Widget getHighlightedDetails() {
    return Card(
      child: Column(
        children: [
          widget.product.variants[int.parse(_variants)].isAvailable
              ? ListTile(
                  leading: Icon(
                    FontAwesomeIcons.smile,
                    color: CustomColors.blueGreen,
                  ),
                  title: Text("Product In Stock"),
                )
              : ListTile(
                  leading: Icon(
                    Icons.face,
                    color: CustomColors.alertRed,
                  ),
                  title: Text("No Stock"),
                ),
          widget.product.isDeliverable
              ? ListTile(
                  leading: Icon(
                    Icons.pedal_bike,
                    color: CustomColors.blue,
                  ),
                  title: Text("Home Delivery Available"),
                )
              : ListTile(
                  leading: Icon(Icons.self_improvement),
                  title: Text("Only Self Pickup From Store"),
                ),
          widget.product.isReturnable
              ? ListTile(
                  leading: Icon(Icons.bike_scooter),
                  title: Text("Product Returnable"),
                )
              : Container(),
          widget.product.isReplaceable
              ? ListTile(
                  leading: Icon(Icons.repeat_one_on),
                  title: Text("Product Replaceable"),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget getProductDetails() {
    return ListView.separated(
      primary: false,
      shrinkWrap: true,
      itemCount: widget.product.productDescription.length,
      separatorBuilder: (BuildContext context, int index) => Divider(
        color: CustomColors.grey,
        height: 0,
      ),
      itemBuilder: (BuildContext context, int index) {
        ProductDescription desc = widget.product.productDescription[index];
        return Container(
          padding: EdgeInsets.fromLTRB(2, 10, 2, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              desc.images != null && desc.images.isNotEmpty
                  ? CarouselIndicatorSlider(desc.images)
                  : Container(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        desc.title,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        desc.description,
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
