import 'package:chipchop_seller/screens/orders/OrderWidget.dart';
import 'package:chipchop_seller/screens/orders/OrdersSearchBar.dart';
import 'package:chipchop_seller/screens/utils/NoStoresWidget.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/models/order.dart';
import '../utils/AsyncWidgets.dart';
import '../utils/CustomColors.dart';

class OrdersHomeScreen extends StatefulWidget {
  @override
  _OrdersHomeScreenState createState() => _OrdersHomeScreenState();
}

class _OrdersHomeScreenState extends State<OrdersHomeScreen> {
  String filterBy = "0";

  Map<String, String> _selectedFilter = {
    "0": "All",
    "1": "Ordered",
    "2": "Confirmed",
    "3": "Cancelled BY User",
    "4": "Cancelled BY Store",
    "5": "DisPatched",
    "6": "Delivered",
    "7": "Returned"
  };

  @override
  Widget build(BuildContext context) {
    return cachedLocalUser.stores == null || cachedLocalUser.stores.isEmpty
        ? Center(
            child: NoStoresWidget(),
          )
        : Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 10, 10, 5),
                child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrdersSearchBar(),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: CustomColors.grey,
                              blurRadius: 5.0,
                              spreadRadius: 0.5,
                            )
                          ],
                          color: CustomColors.white),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: CustomColors.primary,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              "Search with Order ID",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Georgia",
                                  color: CustomColors.black),
                            ),
                          )
                        ],
                      ),
                    )),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    width: 210,
                    height: 40,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: "Filter",
                        labelStyle: TextStyle(
                          color: CustomColors.blue,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        fillColor: CustomColors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.white),
                        ),
                      ),
                      items: _selectedFilter.entries.map(
                        (f) {
                          return DropdownMenuItem<String>(
                            value: f.key,
                            child: Text(f.value),
                          );
                        },
                      ).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          filterBy = newVal;
                        });
                      },
                      value: filterBy,
                    ),
                  ),
                ),
              ),
              getBody(context)
            ],
          );
  }

  Widget getBody(BuildContext context) {
    return StreamBuilder(
      stream: Order().streamOrdersByStatus(cachedLocalUser.stores,
          filterBy == "0" ? null : (int.parse(filterBy) - 1)),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.documents.length == 0) {
            child = Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sentiment_neutral,
                      size: 40,
                      color: CustomColors.purple,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "No Orders Found!",
                      style: TextStyle(
                        color: CustomColors.blueGreen,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "We are Live & Waiting for your ORDER...",
                      style: TextStyle(
                        color: CustomColors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            child = Container(
              child: ListView.separated(
                shrinkWrap: true,
                primary: false,
                itemCount: snapshot.data.documents.length,
                separatorBuilder: (BuildContext context, int index) => Divider(
                  color: CustomColors.black,
                ),
                itemBuilder: (BuildContext context, int index) {
                  Order order =
                      Order.fromJson(snapshot.data.documents[index].data);

                  return OrderWidget(order);
                },
              ),
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
}
