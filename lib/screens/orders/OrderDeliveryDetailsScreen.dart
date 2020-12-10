import 'package:chipchop_seller/db/models/order.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/services/utils/DateUtils.dart';
import 'package:flutter/material.dart';

class OrderDeliveryDetails extends StatelessWidget {
  OrderDeliveryDetails(this.order);

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order : ${order.orderID}",
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.primary,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: getBody(context),
        ),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    double wOrderAmount = 0.00;
    double cOrderAmount = 0.00;

    if (order.writtenOrders.length > 0 &&
        order.writtenOrders.first.name.trim().isNotEmpty) {
      order.writtenOrders.forEach((element) {
        wOrderAmount += element.price;
      });
    }

    if (order.capturedOrders != null && order.capturedOrders.isNotEmpty) {
      order.capturedOrders.forEach((element) {
        cOrderAmount += element.price;
      });
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Delivered - ${DateUtils.formatDateTime(DateTime.fromMillisecondsSinceEpoch(order.delivery.deliveredAt))}",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.w700),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Container(
              decoration: BoxDecoration(
                color: CustomColors.white,
                border: Border.all(color: CustomColors.grey),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Shipping Address",
                    ),
                  ),
                  ListTile(
                    title: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: EdgeInsets.only(right: 10, left: 10),
                      decoration: BoxDecoration(
                        color: CustomColors.lightGrey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 6,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  order.delivery.userLocation.userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: CustomColors.blue, fontSize: 14),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    left: 8, right: 8, top: 4, bottom: 4),
                                decoration: BoxDecoration(
                                  color: CustomColors.purple,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  order.delivery.userLocation.locationName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: CustomColors.white, fontSize: 10),
                                ),
                              )
                            ],
                          ),
                          createAddressText(
                              order.delivery.userLocation.address.street, 6),
                          createAddressText(
                              order.delivery.userLocation.address.city, 6),
                          createAddressText(
                              order.delivery.userLocation.address.pincode, 6),
                          SizedBox(
                            height: 6,
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "LandMark : ",
                                  style: TextStyle(
                                      fontSize: 12, color: CustomColors.blue),
                                ),
                                TextSpan(
                                  text: order
                                      .delivery.userLocation.address.landmark,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Mobile : ",
                                  style: TextStyle(
                                      fontSize: 12, color: CustomColors.blue),
                                ),
                                TextSpan(
                                  text: order.delivery.userLocation.userNumber,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Text("Received By : "),
            title: Text(
              order.delivery.deliveredTo != null
                  ? order.delivery.deliveredTo
                  : "",
              textAlign: TextAlign.end,
            ),
          ),
          ListTile(
            leading: Text("Delivered By : "),
            title: Text(
              order.delivery.deliveredBy != null
                  ? order.delivery.deliveredBy
                  : "",
              textAlign: TextAlign.end,
            ),
          ),
          ListTile(
            leading: Text("Delivery Contact : "),
            title: Text(
              order.delivery.deliveryContact != null
                  ? order.delivery.deliveryContact
                  : "",
              textAlign: TextAlign.end,
            ),
          ),
          order.delivery.notes != null && order.delivery.notes.isNotEmpty
              ? ListTile(
                  leading: Text("Delivery Notes : "),
                  title: Text(
                    order.delivery.notes,
                    textAlign: TextAlign.end,
                  ),
                )
              : Container(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Container(
              decoration: BoxDecoration(
                color: CustomColors.white,
                border: Border.all(color: CustomColors.grey),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Payment Details",
                    ),
                  ),
                  ListTile(
                    title: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      padding: EdgeInsets.only(right: 10, left: 10),
                      decoration: BoxDecoration(
                        color: CustomColors.lightGrey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          (order.capturedOrders != null &&
                                  order.capturedOrders.isNotEmpty)
                              ? ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text("Price for Captured List : "),
                                  trailing: Text('₹ $cOrderAmount'),
                                )
                              : Container(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text("Wallet Amount : "),
                            trailing: Text('₹ ${order.amount.walletAmount}'),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text("Delivery Charge : "),
                            trailing: Text('₹ ${order.amount.deliveryCharge}'),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "Total Billed Amount : ",
                              style: TextStyle(
                                  color: CustomColors.alertRed,
                                  fontWeight: FontWeight.w500),
                            ),
                            trailing: Text(
                                '₹ ${order.amount.orderAmount + wOrderAmount + cOrderAmount + order.amount.deliveryCharge - order.amount.walletAmount}',
                                style: TextStyle(
                                  color: CustomColors.alertRed,
                                )),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "Received Amount : ",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500),
                            ),
                            trailing: Text('₹ ${order.amount.receivedAmount}',
                                style: TextStyle(
                                  color: Colors.green,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
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
}
