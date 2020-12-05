import 'package:chipchop_seller/db/models/order.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:chipchop_seller/services/utils/DateUtils.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class OrderViewScreen extends StatefulWidget {
  OrderViewScreen(this.order);

  final Order order;

  @override
  _OrderViewScreenState createState() => _OrderViewScreenState();
}

class _OrderViewScreenState extends State<OrderViewScreen> {
  String _currentStatus = "0";
  String deliveryNotes = "";
  String deliverredTo = "";
  String deliverredBy = cachedLocalUser.getFullName();

  DateTime selectedDate;
  DateTime deliveryDate;
  String dContact = cachedLocalUser.getID();

  Map<String, String> _orderStatus = {
    "0": "Ordered",
    "1": "Confirmed",
    "2": "Cancelled BY User",
    "3": "Cancelled BY Store",
    "4": "DisPatched",
    "5": "Delivered",
    "6": "Returned"
  };

  final format = DateFormat('dd MMM, yyyy h:mm a');

  @override
  void initState() {
    super.initState();

    _currentStatus = widget.order.status.toString();
    if (widget.order.delivery.deliveryContact != null)
      dContact = widget.order.delivery.deliveryContact;
    selectedDate = widget.order.delivery.expectedAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(widget.order.delivery.expectedAt);
    deliveryDate = widget.order.delivery.expectedAt == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(widget.order.delivery.expectedAt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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

  createAddressText(String strAddress, double topMargin) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Text(
        strAddress,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Text(
            "Order Delivery Details",
            style: TextStyle(
                fontSize: 15,
                color: CustomColors.purple,
                fontWeight: FontWeight.w600),
          ),
        ),
        ListTile(
          leading: Container(
            width: 100,
            child: Text(
              "Delivery Mode",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          trailing: Text(
            widget.order.getDeliveryType(),
          ),
        ),
        widget.order.delivery.deliveryType == 3 && widget.order.status != 5
            ? ListTile(
                leading: Container(
                  width: 100,
                  child: Text(
                    "Delivery At",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                trailing: Text(
                  widget.order.delivery.scheduledDate != null
                      ? DateUtils.formatDateTime(
                          DateTime.fromMillisecondsSinceEpoch(
                              widget.order.delivery.scheduledDate),
                        )
                      : '',
                  style: TextStyle(
                    color: CustomColors.black,
                    fontSize: 14,
                  ),
                ),
              )
            : Container(),
        widget.order.delivery.deliveryType != 0
            ? ListTile(
                leading: Container(
                  width: 100,
                  child: Text(
                    "Delivery Address",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                title: Container(
                  padding: EdgeInsets.only(right: 5, left: 5),
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
                              widget.order.delivery.userLocation.userName,
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
                              widget.order.delivery.userLocation.locationName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: CustomColors.white, fontSize: 10),
                            ),
                          )
                        ],
                      ),
                      createAddressText(
                          widget.order.delivery.userLocation.address.street, 6),
                      createAddressText(
                          widget.order.delivery.userLocation.address.city, 6),
                      createAddressText(
                          widget.order.delivery.userLocation.address.pincode,
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
                                  fontSize: 12, color: CustomColors.blue),
                            ),
                            TextSpan(
                              text: widget
                                  .order.delivery.userLocation.address.landmark,
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
                              text:
                                  widget.order.delivery.userLocation.userNumber,
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
              )
            : Container(),
        SizedBox(
          height: 10,
        ),
        ListTile(
          leading: Container(
            width: 100,
            child: Text(
              "Current Status",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          title: Text(widget.order.getStatus(widget.order.status)),
        ),
        ListTile(
          leading: Container(
            width: 100,
            child: Text(
              "Update Status",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          title: Container(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            decoration: BoxDecoration(
                color: CustomColors.lightGrey,
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
        (widget.order.status.toString() != _currentStatus) &&
                _currentStatus == "5"
            ? Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 100,
                      child: Text(
                        "Deliverred At",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                    title: DateTimeField(
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        suffixIcon: Icon(Icons.date_range,
                            color: CustomColors.blue, size: 30),
                        labelText: "Date & Time",
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: CustomColors.blue,
                        ),
                        fillColor: CustomColors.lightGrey,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: CustomColors.white),
                        ),
                      ),
                      format: format,
                      initialValue: widget.order.delivery.expectedAt != null
                          ? DateTime.fromMillisecondsSinceEpoch(
                              widget.order.delivery.expectedAt)
                          : null,
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(
                            Duration(days: 10),
                          ),
                          initialDate: currentValue ?? DateTime.now(),
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
                          deliveryDate = DateTimeField.combine(date, time);
                          return deliveryDate;
                        } else {
                          return currentValue;
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading:
                        Container(width: 100, child: Text("Delivery Notes")),
                    title: Container(
                      child: TextFormField(
                        initialValue: deliveryNotes,
                        textAlign: TextAlign.start,
                        autofocus: false,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          fillColor: CustomColors.lightGrey,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: CustomColors.lightGreen),
                          ),
                        ),
                        onChanged: (val) {
                          this.deliveryNotes = val;
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    leading:
                        Container(width: 100, child: Text("Deliverred By")),
                    title: TextFormField(
                      initialValue: deliverredBy,
                      textAlign: TextAlign.start,
                      autofocus: false,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: CustomColors.lightGrey,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.lightGreen),
                        ),
                      ),
                      onChanged: (val) {
                        this.deliverredBy = val;
                      },
                    ),
                  ),
                  ListTile(
                    leading:
                        Container(width: 100, child: Text("Deliverred To")),
                    title: TextFormField(
                      initialValue: deliverredTo,
                      textAlign: TextAlign.start,
                      autofocus: false,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        fillColor: CustomColors.lightGrey,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.lightGreen),
                        ),
                      ),
                      onChanged: (val) {
                        this.deliverredTo = val;
                      },
                    ),
                  ),
                ],
              )
            : Container(),
        ListTile(
          leading: Container(
            width: 100,
            child: Text(
              "Expected Delivery Time",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          title: DateTimeField(
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon:
                  Icon(Icons.date_range, color: CustomColors.blue, size: 30),
              labelText: "Date & Time",
              labelStyle: TextStyle(
                fontSize: 12,
                color: CustomColors.blue,
              ),
              fillColor: CustomColors.lightGrey,
              filled: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: CustomColors.white),
              ),
            ),
            format: format,
            initialValue: widget.order.delivery.expectedAt != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    widget.order.delivery.expectedAt)
                : null,
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                initialDate: currentValue ?? DateTime.now(),
                lastDate: DateTime.now().add(
                  Duration(days: 30),
                ),
              );

              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                );
                selectedDate = DateTimeField.combine(date, time);
                return selectedDate;
              } else {
                return currentValue;
              }
            },
          ),
        ),
        ListTile(
          leading: Container(
            width: 100,
            child: Text(
              "Delivery Contact",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          title: TextFormField(
            initialValue: dContact,
            textAlign: TextAlign.start,
            autofocus: false,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              fillColor: CustomColors.lightGrey,
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: CustomColors.lightGreen),
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
          color: CustomColors.alertRed,
          onPressed: () async {
            try {
              if (_currentStatus == "0" ||
                  _currentStatus == "2" ||
                  _currentStatus == "3") {
                Fluttertoast.showToast(
                    msg: 'You have Selected Invalid Status',
                    backgroundColor: CustomColors.alertRed,
                    textColor: CustomColors.white);
                return;
              }

              if (widget.order.status.toString() != _currentStatus &&
                  _currentStatus == "5") {
                await widget.order.deliverOrder(widget.order.userNumber,
                    deliveryDate, deliveryNotes, deliverredTo, deliverredBy, dContact);
              } else {
                await widget.order.updateDeliveryDetails(
                    widget.order.userNumber,
                    int.parse(_currentStatus),
                    selectedDate,
                    dContact);
              }

              Fluttertoast.showToast(
                  msg: 'Updated Delivery Details',
                  backgroundColor: CustomColors.primary,
                  textColor: CustomColors.black);
            } catch (err) {
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
            style: TextStyle(color: CustomColors.lightGrey, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
