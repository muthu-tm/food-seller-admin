import 'package:chipchop_seller/db/models/order.dart';
import 'package:chipchop_seller/db/models/order_written_details.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WrittenOrderWidget extends StatefulWidget {
  WrittenOrderWidget(this.order);

  final Order order;
  @override
  _WrittenOrderWidgetState createState() => _WrittenOrderWidgetState();
}

class _WrittenOrderWidgetState extends State<WrittenOrderWidget> {
  bool editMode = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.order.writtenOrders.isNotEmpty
        ? Column(
            children: [
              ListTile(
                leading: Text("Ordered as Written List"),
                trailing: widget.order.status <= 1
                    ? Container(
                        padding: EdgeInsets.all(10),
                        width: 120,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          color: editMode ? Colors.red : Colors.green,
                          onPressed: () async {
                            if (editMode) {
                              try {
                                await widget.order.updateWrittenAmount(
                                    widget.order.writtenOrders);
                                Fluttertoast.showToast(
                                    msg: 'Amount Update Successfull !!',
                                    backgroundColor: Colors.green,
                                    textColor: CustomColors.white);
                                setState(() {
                                  editMode = false;
                                });
                              } catch (err) {
                                Fluttertoast.showToast(
                                    msg: 'Error, Unable to Update Now !!',
                                    backgroundColor: CustomColors.alertRed,
                                    textColor: CustomColors.white);
                              }
                            } else {
                              setState(() {
                                editMode = !editMode;
                              });
                            }
                          },
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "₹ ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  editMode ? "Update" : "Edit",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(width: 5, child: Text("")),
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
                    itemCount: widget.order.writtenOrders.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(
                      color: CustomColors.white,
                      thickness: 2,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      WrittenOrders _wr = widget.order.writtenOrders[index];

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
                              style: TextStyle(color: CustomColors.black),
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${_wr.weight}',
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: CustomColors.black,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        _wr.getUnit(),
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
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
                            title: Container(
                              height: 50,
                              child: TextFormField(
                                initialValue: '${_wr.price.toStringAsFixed(2)}',
                                textAlign: TextAlign.start,
                                autofocus: false,
                                readOnly: !editMode,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  prefix: Text('₹ '),
                                  fillColor: CustomColors.lightGrey,
                                  filled: true,
                                  labelStyle: TextStyle(
                                      fontSize: 12, color: CustomColors.blue),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: CustomColors.lightGreen),
                                  ),
                                ),
                                onChanged: (val) {
                                  _wr.price = double.parse(val);
                                },
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
        : Container();
  }
}
