import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/screens/utils/ImageView.dart';
import 'package:chipchop_seller/screens/orders/OrderAmountWidget.dart';
import 'package:chipchop_seller/screens/customers/OrderChatScreen.dart';
import 'package:chipchop_seller/screens/products/ProductDetailsScreen.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import '../../db/models/order.dart';
import '../../services/utils/DateUtils.dart';
import '../utils/AsyncWidgets.dart';
import '../utils/CustomColors.dart';

class OrderDetailsScreen extends StatefulWidget {
  OrderDetailsScreen(this.buyerID, this.storeID, this.order);

  final String buyerID;
  final String storeID;
  final Order order;
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  DateTime selectedDate;
  String dContact = cachedLocalUser.getID();

  final format = DateFormat("dd-MMM-yyyy HH:mm");

  Map<String, String> _orderStatus = {
    "0": "Ordered",
    "1": "Confirmed",
    "2": "Cancelled BY User",
    "3": "Cancelled BY Store",
    "4": "DisPatched",
    "5": "Delivered",
    "6": "Returned"
  };

  String _currentStatus = "0";

  TabController _controller;

  List<Widget> list = [
    Tab(
      icon: Icon(
        Icons.card_travel,
        size: 20,
      ),
      text: "Delivery",
    ),
    Tab(
      icon: Icon(
        FontAwesomeIcons.moneyBill,
        size: 20,
      ),
      text: "Amount",
    ),
    Tab(
      icon: Icon(
        Icons.local_shipping,
        size: 20,
      ),
      text: "Orders",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _controller = TabController(length: list.length, vsync: this);

    _currentStatus = widget.order.status.toString();
    if (widget.order.delivery.deliveryContact != null)
      dContact = widget.order.delivery.deliveryContact;
    selectedDate = widget.order.delivery.expectedAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(widget.order.delivery.expectedAt);
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
        backgroundColor: CustomColors.green,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.blueGreen,
        onPressed: () {
          return _scaffoldKey.currentState.showBottomSheet(
            (context) {
              return Builder(
                builder: (BuildContext childContext) {
                  return Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: CustomColors.lightGrey,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: OrderChatScreen(
                        buyerID: widget.buyerID,
                        orderUUID: widget.order.uuid,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        label: Text("Chat"),
        icon: Icon(Icons.chat),
      ),
      body: Container(
        child: getBody(context),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    var size = MediaQuery.of(context).size;
        final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
        final double itemWidth = size.width / 2;
    return StreamBuilder(
      stream: Order()
          .streamOrderByID(widget.buyerID, widget.storeID, widget.order.uuid),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget child;

        if (snapshot.hasData) {
          if (snapshot.data.documents.length == 0) {
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
            Order order = Order.fromJson(snapshot.data.documents.first.data);

            child = Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.store,
                    color: CustomColors.blueGreen,
                  ),
                  title: Text("Store"),
                  trailing: Text(
                    order.storeName,
                    style: TextStyle(
                        color: CustomColors.black,
                        fontSize: 14,
                        ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.access_time,
                    color: CustomColors.blueGreen,
                  ),
                  title: Text("Ordered At"),
                  trailing: Text(
                    DateUtils.formatDateTime(order.createdAt),
                    style: TextStyle(
                        color: CustomColors.black,
                        fontSize: 14,
                        ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: TabBar(
                      indicatorColor: CustomColors.alertRed,
                      labelColor: CustomColors.blueGreen,
                      unselectedLabelColor: CustomColors.black,
                      controller: _controller,
                      tabs: list),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _controller,
                    children: [
                      SingleChildScrollView(
                        child: Container(
                          color: CustomColors.grey,
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.shopping_basket,
                                  color: CustomColors.blueGreen,
                                ),
                                title: Text(
                                  "Status",
                                  style: TextStyle(
                                      color: CustomColors.black,
                                      fontSize: 17,
                                      ),
                                ),
                              ),
                              ListTile(
                                leading: Text(""),
                                title: Container(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all()),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      items: _orderStatus.entries.map((f) {
                                        return DropdownMenuItem<String>(
                                          value: f.key,
                                          child: Text(f.value),
                                        );
                                      }).toList(),
                                      onChanged: (unit) {
                                        setState(
                                          () {
                                            _currentStatus = unit;
                                          },
                                        );
                                      },
                                      value: _currentStatus,
                                    ),
                                  ),
                                ),
                              ),
                              order.delivery.deliveryType != 3
                                  ? ListTile(
                                      leading: Icon(
                                        Icons.local_shipping,
                                        size: 35,
                                        color: CustomColors.blueGreen,
                                      ),
                                      title: Text(
                                        "Delivery",
                                        style: TextStyle(
                                            color: CustomColors.black,
                                            fontSize: 16,
                                            ),
                                      ),
                                      trailing: Text(
                                        order.getDeliveryType(),
                                        style: TextStyle(
                                            color: CustomColors.black,
                                            fontSize: 16,
                                            ),
                                      ),
                                    )
                                  : ListTile(
                                      leading: Icon(
                                        Icons.local_shipping,
                                        size: 35,
                                        color: CustomColors.blueGreen,
                                      ),
                                      title: Text(
                                        "Delivery At",
                                        style: TextStyle(
                                            color: CustomColors.black,
                                            fontSize: 16,
                                            ),
                                      ),
                                      trailing: Text(
                                        order.delivery.scheduledDate != null
                                            ? DateUtils.formatDateTime(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        order.delivery
                                                            .scheduledDate),
                                              )
                                            : '',
                                      ),
                                    ),
                              ListTile(
                                leading: Text(""),
                                title: Text(
                                  "Address",
                                ),
                              ),
                              ListTile(
                                leading: Text(""),
                                title: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  padding: EdgeInsets.only(right: 10, left: 10),
                                  decoration: BoxDecoration(
                                    color: CustomColors.lightGrey,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5),
                                              ),
                                            ),
                                            child: Text(
                                              order.delivery.userLocation
                                                  .userName,
                                              style: TextStyle(
                                                  color: CustomColors.blue,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 8,
                                                right: 8,
                                                top: 4,
                                                bottom: 4),
                                            decoration: BoxDecoration(
                                              color: CustomColors.purple,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(5),
                                              ),
                                            ),
                                            child: Text(
                                              order.delivery.userLocation
                                                  .locationName,
                                              style: TextStyle(
                                                  color: CustomColors.white,
                                                  fontSize: 10),
                                            ),
                                          )
                                        ],
                                      ),
                                      createAddressText(
                                          order.delivery.userLocation.address
                                              .street,
                                          6),
                                      createAddressText(
                                          order.delivery.userLocation.address
                                              .city,
                                          6),
                                      createAddressText(
                                          order.delivery.userLocation.address
                                              .pincode,
                                          6),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "LandMark : ",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: CustomColors.blue),
                                            ),
                                            TextSpan(
                                              text: order.delivery.userLocation
                                                  .address.landmark,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
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
                                                  fontSize: 12,
                                                  color: CustomColors.blue),
                                            ),
                                            TextSpan(
                                              text: order.delivery.userLocation
                                                  .userNumber,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),
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
                                  FontAwesomeIcons.shippingFast,
                                  color: CustomColors.blueGreen,
                                ),
                                title: Text(
                                  "Expected Delivery Time",
                                ),
                              ),
                              ListTile(
                                leading: Text(""),
                                title: DateTimeField(
                                  decoration: InputDecoration(
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    suffixIcon: Icon(Icons.date_range,
                                        color: CustomColors.blue, size: 30),
                                    labelText: "DateTime",
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      color: CustomColors.blue,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 3.0, horizontal: 10.0),
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: CustomColors.white),
                                    ),
                                  ),
                                  format: format,
                                  initialValue:
                                      order.delivery.expectedAt != null
                                          ? DateTime.fromMillisecondsSinceEpoch(
                                              order.delivery.expectedAt)
                                          : null,
                                  onShowPicker: (context, currentValue) async {
                                    final date = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime.now(),
                                      initialDate:
                                          currentValue ?? DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        Duration(days: 30),
                                      ),
                                    );

                                    if (date != null) {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(
                                            currentValue ?? DateTime.now()),
                                      );
                                      selectedDate =
                                          DateTimeField.combine(date, time);
                                      return selectedDate;
                                    } else {
                                      return currentValue;
                                    }
                                  },
                                ),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.phone_android,
                                  size: 35,
                                  color: CustomColors.blueGreen,
                                ),
                                title: TextFormField(
                                  initialValue: dContact,
                                  textAlign: TextAlign.start,
                                  autofocus: false,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CustomColors.lightGreen),
                                    ),
                                    labelText: "Delivery - Contact Numer",
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      color: CustomColors.blue,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    dContact = val;
                                  },
                                ),
                              ),
                              RaisedButton.icon(
                                color: CustomColors.blueGreen,
                                onPressed: () async {
                                  try {
                                    await order.updateDeliveryDetails(
                                        order.userNumber,
                                        int.parse(_currentStatus),
                                        selectedDate,
                                        dContact);
                                    Fluttertoast.showToast(
                                        msg: 'Updated Delivery Details',
                                        backgroundColor: CustomColors.green,
                                        textColor: CustomColors.black);
                                  } catch (err) {
                                    print(err);
                                    Fluttertoast.showToast(
                                        msg: 'Error, Unable to Update Details',
                                        backgroundColor: CustomColors.alertRed,
                                        textColor: CustomColors.white);
                                  }
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: CustomColors.lightGrey,
                                ),
                                label: Text(
                                  "Update",
                                  style: TextStyle(
                                      color: CustomColors.lightGrey,
                                      fontSize: 14),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(child: OrderAmountWidget(order)),
                      SingleChildScrollView(
                        child: Container(
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  FontAwesomeIcons.shoppingBasket,
                                  color: CustomColors.blueGreen,
                                ),
                                title: Text("Products"),
                              ),
                              Container(
                                child: order.products.length > 0
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        primary: false,
                                        itemCount: order.products.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                              
                                          return FutureBuilder(
                                            future: Products().getByProductID(
                                                order
                                                    .products[index].productID),
                                            builder: (context,
                                                AsyncSnapshot<Products>
                                                    snapshot) {
                                              Widget child;
                                              if (snapshot.hasData) {
                                                Products _p = snapshot.data;
                                                child = Card(
                                                    child: Container(
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: <Widget>[
                                                          Container(
                                                            width: 125,
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  width: 125,
                                                                  height: 125,
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      imageUrl:
                                                                          _p.getProductImage(),
                                                                      imageBuilder:
                                                                          (context, imageProvider) =>
                                                                              Image(
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        image:
                                                                            imageProvider,
                                                                      ),
                                                                      progressIndicatorBuilder: (context,
                                                                              url,
                                                                              downloadProgress) =>
                                                                          Center(
                                                                        child:
                                                                            SizedBox(
                                                                          height:
                                                                              50.0,
                                                                          width:
                                                                              50.0,
                                                                          child: CircularProgressIndicator(
                                                                              value: downloadProgress.progress,
                                                                              valueColor: AlwaysStoppedAnimation(CustomColors.blue),
                                                                              strokeWidth: 2.0),
                                                                        ),
                                                                      ),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          Icon(
                                                                        Icons
                                                                            .error,
                                                                        size:
                                                                            35,
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
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                150,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                    '${_p.name}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 3,
                                                                    style: TextStyle(
                                                                        color: CustomColors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        'Weight: ',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            color:
                                                                                CustomColors.lightBlue,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      '${_p.weight}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        color: CustomColors
                                                                            .black,
                                                                        
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              5.0),
                                                                      child:
                                                                          Text(
                                                                        _p.getUnit(),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              CustomColors.black,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Text(
                                                                        'Price: ',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                            color:
                                                                                CustomColors.lightBlue,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.all(5.0),
                                                                        child:
                                                                            Text(
                                                                          'Rs. ${_p.currentPrice}',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                CustomColors.black,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5.0),
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomRight,
                                                                    child:
                                                                        FlatButton(
                                                                      child:
                                                                          Text(
                                                                        "Show Details",
                                                                        style: TextStyle(
                                                                            color:
                                                                                CustomColors.blue),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ProductDetailsScreen(_p),
                                                                            settings:
                                                                                RouteSettings(name: '/store/products'),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      ListTile(
                                                        leading: Text(
                                                          "Quantity: ",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  CustomColors
                                                                      .black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        title: Text(
                                                          '${order.products[index].quantity.round()}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  CustomColors
                                                                      .black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        trailing: Text(
                                                          'Rs. ${order.products[index].amount}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  CustomColors
                                                                      .black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ));
                                              } else if (snapshot.hasError) {
                                                child = Center(
                                                    child: Column(
                                                  children:
                                                      AsyncWidgets.asyncError(),
                                                ));
                                              } else {
                                                child = Center(
                                                    child: Column(
                                                  children: AsyncWidgets
                                                      .asyncWaiting(),
                                                ));
                                              }

                                              return child;
                                            },
                                          );
                                        },
                                      )
                                    : Text(
                                        "No Products added",
                                        style: TextStyle(
                                            
                                            fontSize: 16,
                                            color: CustomColors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                              ListTile(
                                leading: Icon(
                                  FontAwesomeIcons.images,
                                  color: CustomColors.blueGreen,
                                ),
                                title: Text("Images"),
                              ),
                              widget.order.orderImages.length > 0
                                  ? GridView.count(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      childAspectRatio: (itemWidth/itemHeight),
                                      shrinkWrap: true,
                                      primary: false,
                                      mainAxisSpacing: 10,
                                      children: List.generate(
                                        widget.order.orderImages.length,
                                        (index) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 10, top: 5),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ImageView(
                                                      url: widget.order
                                                          .orderImages[index],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: CachedNetworkImage(
                                                    imageUrl: widget.order
                                                        .orderImages[index],
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Image(
                                                      fit: BoxFit.fill,
                                                      image: imageProvider,
                                                    ),
                                                    progressIndicatorBuilder:
                                                        (context, url,
                                                                downloadProgress) =>
                                                            Center(
                                                      child: SizedBox(
                                                        height: 50.0,
                                                        width: 50.0,
                                                        child: CircularProgressIndicator(
                                                            value:
                                                                downloadProgress
                                                                    .progress,
                                                            valueColor:
                                                                AlwaysStoppedAnimation(
                                                                    CustomColors
                                                                        .blue),
                                                            strokeWidth: 2.0),
                                                      ),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(
                                                      Icons.error,
                                                      size: 35,
                                                    ),
                                                    fadeOutDuration:
                                                        Duration(seconds: 1),
                                                    fadeInDuration:
                                                        Duration(seconds: 2),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(
                                      child: Text(
                                        "No Images added",
                                        style: TextStyle(
                                            
                                            fontSize: 16,
                                            color: CustomColors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                              ListTile(
                                leading: Icon(
                                  FontAwesomeIcons.solidEdit,
                                  color: CustomColors.blueGreen,
                                ),
                                title: Text("Written Orders"),
                              ),
                              widget.order.writtenOrders.trim().isNotEmpty
                                  ? Container(
                                      child: ListTile(
                                        title: TextFormField(
                                          initialValue:
                                              widget.order.writtenOrders,
                                          maxLines: 10,
                                          keyboardType: TextInputType.multiline,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            fillColor: CustomColors.white,
                                            filled: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 3.0,
                                                    horizontal: 3.0),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: CustomColors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      child: Text(
                                        "No Orders Written",
                                        style: TextStyle(
                                            
                                            fontSize: 16,
                                            color: CustomColors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
}
