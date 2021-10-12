import 'package:chipchop_seller/db/models/address.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class AddressWidget extends StatefulWidget {
  AddressWidget(this.addreesTitle, this.address, this.updatedAddress);

  final String addreesTitle;
  final Address address;
  final Address updatedAddress;

  @override
  _AddressWidgetState createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustomColors.lightGrey,
      elevation: 5.0,
      margin: EdgeInsets.all(5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 40,
            alignment: Alignment.center,
            child: Text(
              widget.addreesTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                
                fontWeight: FontWeight.bold,
                color: CustomColors.blue,
              ),
            ),
          ),
          Divider(
            color: CustomColors.blue,
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextFormField(
                    initialValue: widget.address.street,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Building no. & street",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        fontSize: 10.0,
                        color: CustomColors.blue,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.lightGreen)),
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                    validator: (street) {
                      if (street.trim() != "") {
                        widget.updatedAddress.street = street.trim();
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextFormField(
                    initialValue: widget.address.landmark,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      labelText: "Landmark",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        fontSize: 10.0,
                        color: CustomColors.blue,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.lightGreen)),
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                    validator: (landmark) {
                      if (landmark.trim() != "") {
                        widget.updatedAddress.landmark = landmark.trim();
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextFormField(
                    initialValue: widget.address.city,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      labelText: "City",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        fontSize: 10.0,
                        color: CustomColors.blue,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.lightGreen)),
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                    validator: (city) {
                      if (city.trim() != "") {
                        widget.updatedAddress.city = city.trim();
                      }
                      return null;
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.only(left: 5)),
                Flexible(
                  child: TextFormField(
                    initialValue: widget.address.state,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      labelText:
                          "State",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        fontSize: 10.0,
                        color: CustomColors.blue,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.lightGreen)),
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                    validator: (state) {
                      if (state.trim() != "") {
                        widget.updatedAddress.state = state.trim();
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: TextFormField(
                    initialValue: widget.address.pincode,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      labelText:
                          "Pincode",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        fontSize: 10.0,
                        color: CustomColors.blue,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.lightGreen)),
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                    validator: (pinCode) {
                      if (pinCode.trim() != "") {
                        widget.updatedAddress.pincode = pinCode.trim();
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
