import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/order_written_details.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/screens/orders/OrderDeliveryDetailsScreen.dart';
import 'package:chipchop_seller/screens/orders/OrdersView.dart';
import 'package:chipchop_seller/screens/products/ProductDetailsScreen.dart';
import 'package:chipchop_seller/screens/utils/CustomSnackBar.dart';
import 'package:chipchop_seller/screens/customers/OrderChatScreen.dart';
import 'package:chipchop_seller/screens/utils/ImageView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../db/models/order.dart';
import '../../services/utils/DateUtils.dart';
import '../utils/AsyncWidgets.dart';
import '../utils/CustomColors.dart';

class OrderDetailsScreen extends StatefulWidget {
  OrderDetailsScreen(this.order);

  final Order order;
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  TextEditingController _pController = TextEditingController();

  double wOrderAmount = 0.00;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Order - ${widget.order.orderID}",
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: CustomColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.primary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.primary,
        onPressed: () {
          return _scaffoldKey.currentState.showBottomSheet(
            (context) {
              return Builder(
                builder: (BuildContext childContext) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: BoxDecoration(
                      color: CustomColors.lightGrey,
                      border: Border.symmetric(
                          horizontal: BorderSide(color: CustomColors.primary)),
                    ),
                    child: OrderChatScreen(
                      buyerID: widget.order.userNumber,
                      orderUUID: widget.order.uuid,
                    ),
                  );
                },
              );
            },
          );
        },
        label: Text(
          "Chat with Store",
          style: TextStyle(color: CustomColors.black),
        ),
        icon: Icon(Icons.chat_bubble, color: CustomColors.black),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Container(
            child: getBody(context),
          ),
        ),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    return StreamBuilder(
      stream:
          Order().streamOrderByID(widget.order.userNumber, widget.order.uuid),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (!snapshot.data.exists) {
            child = Container(
              child: Text(
                "No Elements Found",
                style: TextStyle(
                  color: CustomColors.purple,
                  fontSize: 14,
                ),
              ),
            );
          } else {
            Order order = Order.fromJson(snapshot.data.data);
            wOrderAmount = 0.00;

            if (order.writtenOrders.length > 0 &&
                order.writtenOrders.first.name.trim().isNotEmpty) {
              order.writtenOrders.forEach((element) {
                wOrderAmount += element.price;
              });
            }

            child = Column(
              children: [
                ListTile(
                  title: Text("Customer"),
                  trailing: Text(
                    order.userNumber,
                    style: TextStyle(
                      color: CustomColors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                ListTile(
                  leading: Text("Order ID"),
                  trailing: Text(
                    order.orderID,
                  ),
                ),
                ListTile(
                  leading: Text("Ordered At"),
                  trailing: Text(
                    DateUtils.formatDateTime(order.createdAt),
                    style: TextStyle(
                      color: CustomColors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                ListTile(
                  leading: Text(
                    "Delivery Mode",
                  ),
                  trailing: Text(
                    order.getDeliveryType(),
                  ),
                ),
                order.delivery.deliveryType == 3 && order.status != 5
                    ? ListTile(
                        leading: Text(
                          "Delivery At",
                        ),
                        trailing: Text(
                          order.delivery.scheduledDate != null
                              ? DateUtils.formatDateTime(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      order.delivery.scheduledDate),
                                )
                              : '',
                          style: TextStyle(
                            color: CustomColors.black,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
                  child: ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: order.statusDetails.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.stop_circle,
                                    color: order.statusDetails[index].status ==
                                                2 ||
                                            order.statusDetails[index].status ==
                                                3
                                        ? CustomColors.alertRed
                                        : CustomColors.primary,
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(order.getStatus(
                                            order.statusDetails[index].status)),
                                        Text(
                                          DateUtils.formatDateTime(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                order.statusDetails[index]
                                                            .status ==
                                                        5
                                                    ? order.delivery.deliveredAt
                                                    : order.statusDetails[index]
                                                        .createdAt),
                                          ),
                                          style: TextStyle(fontSize: 12),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            index != order.statusDetails.length - 1
                                ? Container(
                                    height: 40,
                                    width: 25,
                                    child: VerticalDivider(
                                      color: Colors.black,
                                      thickness: 1,
                                    ),
                                  )
                                : index == order.statusDetails.length - 1 &&
                                        (order.status == 0 ||
                                            order.status == 1 ||
                                            order.status == 4)
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 25,
                                            child: VerticalDivider(
                                              color: Colors.black,
                                              thickness: 1,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.stop_circle,
                                                  color: CustomColors.blue,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 0, 0, 0),
                                                  child: Text(order.status == 0
                                                      ? "Waiting for Order Confirmation"
                                                      : order.status == 1
                                                          ? "Preparing your Order"
                                                          : order.status == 4
                                                              ? "On the Way"
                                                              : ""),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    : Container(),
                          ],
                        );
                      }),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: CustomColors.grey,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text("Ordered as Products"),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: order.products.length,
                          itemBuilder: (BuildContext context, int index) {
                            return FutureBuilder(
                              future: Products().getByProductID(
                                  order.products[index].productID),
                              builder:
                                  (context, AsyncSnapshot<Products> snapshot) {
                                Widget child;
                                if (snapshot.hasData) {
                                  Products _p = snapshot.data;
                                  child = Card(
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(15, 5, 5, 0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '${_p.name}',
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: CustomColors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      '${_p.variants[int.parse(order.products[index].variantID)].weight}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color:
                                                            CustomColors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(5.0),
                                                    child: Text(
                                                      _p.variants[int.parse(
                                                              order
                                                                  .products[
                                                                      index]
                                                                  .variantID)]
                                                          .getUnit(),
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color:
                                                            CustomColors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'X ${order.products[index].quantity.round()}',
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: CustomColors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  '₹ ${order.products[index].amount}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: CustomColors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: FlatButton(
                                              onPressed: () async {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductDetailsScreen(
                                                            _p),
                                                    settings: RouteSettings(
                                                        name:
                                                            '/store/products'),
                                                  ),
                                                );
                                              },
                                              child: Text("Show Details",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      color: Colors
                                                          .indigo.shade700)),
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  child = Center(
                                    child: Column(
                                      children: AsyncWidgets.asyncError(),
                                    ),
                                  );
                                } else {
                                  child = Center(
                                    child: Column(
                                      children: AsyncWidgets.asyncWaiting(),
                                    ),
                                  );
                                }

                                return child;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                order.orderImages.length > 0
                    ? Column(
                        children: [
                          ListTile(
                            title: Text("Ordered as Captured List"),
                          ),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              primary: true,
                              shrinkWrap: true,
                              itemCount: order.orderImages.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 5),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ImageView(
                                            url: order.orderImages[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: CachedNetworkImage(
                                          imageUrl: order.orderImages[index],
                                          imageBuilder:
                                              (context, imageProvider) => Image(
                                            fit: BoxFit.fill,
                                            height: 150,
                                            width: 150,
                                            image: imageProvider,
                                          ),
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Center(
                                            child: SizedBox(
                                              height: 50.0,
                                              width: 50.0,
                                              child: CircularProgressIndicator(
                                                  value:
                                                      downloadProgress.progress,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                          CustomColors.blue),
                                                  strokeWidth: 2.0),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Icon(
                                            Icons.error,
                                            size: 35,
                                          ),
                                          fadeOutDuration: Duration(seconds: 1),
                                          fadeInDuration: Duration(seconds: 2),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : Container(),
                order.writtenOrders.isNotEmpty
                    ? Column(
                        children: [
                          ListTile(
                            title: Text("Ordered as Written List"),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: CustomColors.grey),
                              child: ListView.separated(
                                primary: false,
                                shrinkWrap: true,
                                itemCount: order.writtenOrders.length,
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        Divider(
                                  color: CustomColors.white,
                                  thickness: 2,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  WrittenOrders _wr =
                                      order.writtenOrders[index];

                                  return Container(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Text(
                                          "Name : ",
                                          style: TextStyle(
                                              color: CustomColors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        title: Text(
                                          '${_wr.name}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: CustomColors.black),
                                        ),
                                      ),
                                      ListTile(
                                        leading: Text(
                                          "Quantity : ",
                                          style: TextStyle(
                                              color: CustomColors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    '${_wr.weight}',
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: CustomColors.black,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5.0),
                                                  child: Text(
                                                    _wr.getUnit(),
                                                    textAlign: TextAlign.start,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: CustomColors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'X ${_wr.quantity.round()}',
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: CustomColors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ListTile(
                                        leading: Text(
                                          "Price : ",
                                          style: TextStyle(
                                              color: CustomColors.black,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        title: Text(
                                          '₹ ${_wr.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: CustomColors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ));
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
                Card(
                  elevation: 2,
                  child: Container(
                    color: CustomColors.lightGrey,
                    padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                    child: Column(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  "Order Amount",
                                  style: TextStyle(
                                      color: CustomColors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text("Ordered Amount : "),
                                trailing: Text('₹ ${order.amount.orderAmount}'),
                              ),
                              (order.writtenOrders.length > 0 &&
                                      order.writtenOrders.first.name
                                          .trim()
                                          .isNotEmpty)
                                  ? ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text("Price for Written List : "),
                                      trailing: Text('₹ $wOrderAmount'),
                                    )
                                  : Container(),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text("Wallet Amount : "),
                                trailing:
                                    Text('₹ ${order.amount.walletAmount}'),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text("Delivery Charge : "),
                                trailing:
                                    Text('₹ ${order.amount.deliveryCharge}'),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  "Total Billed Amount : ",
                                  style: TextStyle(
                                      color: CustomColors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                                trailing: Text(
                                    '₹ ${order.amount.orderAmount + order.amount.deliveryCharge - order.amount.walletAmount}'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: CustomColors.white,
                            border: Border.all(color: CustomColors.grey),
                          ),
                          padding: EdgeInsets.all(10),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => order.status == 5
                                      ? OrderDeliveryDetails(order)
                                      : OrderViewScreen(order),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("View Delivery Details"),
                                Icon(Icons.chevron_right)
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        order.status <= 1
                            ? Container(
                                decoration: BoxDecoration(
                                  color: CustomColors.white,
                                  border: Border.all(color: CustomColors.grey),
                                ),
                                padding: EdgeInsets.all(10),
                                child: InkWell(
                                  onTap: () async {
                                    await cancelOrder(false, order, context);
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Cancel the Order"),
                                      Icon(Icons.chevron_right)
                                    ],
                                  ),
                                ),
                              )
                            : order.status == 6
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: CustomColors.white,
                                      border:
                                          Border.all(color: CustomColors.grey),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: InkWell(
                                      onTap: () async {
                                        await cancelOrder(true, order, context);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Cancel Return Request"),
                                          Icon(Icons.chevron_right)
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 70,
                ),
              ],
            );
          }
        } else if (snapshot.hasError) {
          child = Center(
            child: Column(
              children: AsyncWidgets.asyncError(),
            ),
          );
        } else {
          child = Center(
            child: Column(
              children: AsyncWidgets.asyncWaiting(),
            ),
          );
        }
        return child;
      },
    );
  }

  createAddressText(String strAddress, double topMargin) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Text(
        strAddress,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
      ),
    );
  }

  Future cancelOrder(bool isReturn, Order order, BuildContext context) async {
    _pController.text = "";

    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CustomColors.lightGrey,
          title: Text(
            "Confirm!",
            style: TextStyle(
                color: CustomColors.alertRed,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
          content: Container(
            height: 125,
            child: Column(
              children: <Widget>[
                Text("Please help us with the Reason!"),
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.start,
                    maxLines: 3,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: false,
                    controller: _pController,
                    decoration: InputDecoration(
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
                color: CustomColors.primary,
                child: Text(
                  "NO",
                  style: TextStyle(
                      color: CustomColors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
                onPressed: () {
                  _pController.text = "";
                  Navigator.pop(context);
                }),
            FlatButton(
              color: CustomColors.alertRed,
              child: Text(
                "YES",
                style: TextStyle(
                    color: CustomColors.lightGrey,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
              onPressed: () async {
                if (_pController.text.trim().isEmpty) {
                  Navigator.pop(context);
                  _scaffoldKey.currentState.showSnackBar(
                    CustomSnackBar.errorSnackBar(
                      "Please provide the reason for cancellation!",
                      2,
                    ),
                  );
                } else {
                  try {
                    await order.cancelOrder(isReturn, _pController.text.trim());
                    Navigator.pop(context);
                  } catch (err) {
                    print(err);
                    _pController.text = "";
                    Navigator.pop(context);
                    _scaffoldKey.currentState.showSnackBar(
                      CustomSnackBar.errorSnackBar(
                        "Unable to cancel now !",
                        3,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
