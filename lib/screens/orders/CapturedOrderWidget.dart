import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/order.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/ImageView.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CapturedOrderWidget extends StatefulWidget {
  CapturedOrderWidget(this.order);

  final Order order;
  @override
  _CapturedOrderWidgetState createState() => _CapturedOrderWidgetState();
}

class _CapturedOrderWidgetState extends State<CapturedOrderWidget> {
  bool editMode = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.order.capturedOrders.length > 0
        ? Column(
            children: [
              ListTile(
                leading: Text("Ordered as Captured List"),
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
                                await widget.order.updateCapturedAmount(
                                    widget.order.capturedOrders);
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
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  primary: true,
                  shrinkWrap: true,
                  itemCount: widget.order.capturedOrders.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 10, right: 5, top: 5, bottom: 5),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageView(
                                    url: widget
                                        .order.capturedOrders[index].image,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      widget.order.capturedOrders[index].image,
                                  imageBuilder: (context, imageProvider) =>
                                      Image(
                                    fit: BoxFit.fill,
                                    height: 200,
                                    width: 200,
                                    image: imageProvider,
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
                                    child: SizedBox(
                                      height: 50.0,
                                      width: 50.0,
                                      child: CircularProgressIndicator(
                                          value: downloadProgress.progress,
                                          valueColor: AlwaysStoppedAnimation(
                                              CustomColors.blue),
                                          strokeWidth: 2.0),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    size: 35,
                                  ),
                                  fadeOutDuration: Duration(seconds: 1),
                                  fadeInDuration: Duration(seconds: 2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 150,
                          height: 50,
                          child: TextFormField(
                            initialValue:
                                '${widget.order.capturedOrders[index].price}',
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
                              labelText: "Price",
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: CustomColors.lightGreen),
                              ),
                            ),
                            onChanged: (val) {
                              widget.order.capturedOrders[index].price =
                                  double.parse(val);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          )
        : Container();
  }
}
