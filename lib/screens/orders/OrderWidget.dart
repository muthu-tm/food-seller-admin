import 'package:chipchop_seller/db/models/order.dart';
import 'package:chipchop_seller/screens/orders/OrderDetailsScreen.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class OrderWidget extends StatelessWidget {
  OrderWidget(this.order);

  final Order order;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailsScreen(order.userNumber, order.storeID, order),
              settings: RouteSettings(name: '/orders/details'),
            ),
          );
        },
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  order.getStatus(),
                  style: TextStyle(
                      color: CustomColors.purple,
                      fontSize: 18,
                      fontFamily: "Georgia"),
                ),
                trailing: Icon(Icons.chevron_right, size: 35),
              ),
              ListTile(
                leading: Icon(
                  Icons.confirmation_number,
                  size: 35,
                  color: CustomColors.blueGreen,
                ),
                title: Text(
                  "Order ID",
                  style: TextStyle(
                      color: CustomColors.blue,
                      fontSize: 14,
                      fontFamily: "Georgia"),
                ),
                trailing: Text(
                  order.orderID,
                  style: TextStyle(
                      color: CustomColors.black,
                      fontSize: 12,
                      fontFamily: "Georgia"),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.local_shipping,
                  size: 35,
                  color: CustomColors.blueGreen,
                ),
                title: Container(
                  width: MediaQuery.of(context).size.width - 100,
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
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            child: Text(
                              order.delivery.userLocation.userName,
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
                              text:
                                  order.delivery.userLocation.address.landmark,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
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
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
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
              ListTile(
                leading: Icon(
                  Icons.location_searching,
                  size: 35,
                  color: CustomColors.blueGreen,
                ),
                title: Text(
                  "Location",
                  style: TextStyle(
                      fontFamily: "Georgia",
                      color: CustomColors.black,
                      fontSize: 16),
                ),
                trailing: Container(
                  width: 155,
                  child: FlatButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: CustomColors.blueGreen,
                    onPressed: () async {},
                    label: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 5.0,
                      ),
                      child: Text(
                        "Map View",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Georgia",
                            fontSize: 16,
                            color: CustomColors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    icon: Icon(Icons.location_on),
                  ),
                ),
              ),
            ],
          ),
        ),
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
