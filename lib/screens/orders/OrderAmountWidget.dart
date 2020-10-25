import 'package:chipchop_seller/db/models/order.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderAmountWidget extends StatefulWidget {
  OrderAmountWidget(this.order);

  final Order order;
  @override
  _OrderAmountWidgetState createState() => _OrderAmountWidgetState();
}

class _OrderAmountWidgetState extends State<OrderAmountWidget> {
  double oAmount;
  double wAmount;
  double dAmount;
  double rAmount;

  @override
  void initState() {
    super.initState();

    oAmount = widget.order.amount.orderAmount;
    wAmount = widget.order.amount.walletAmount ?? 0.00;
    dAmount = widget.order.amount.deliveryCharge;
    rAmount = widget.order.amount.paidAmount ?? 0.00;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        color: CustomColors.grey,
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                FontAwesomeIcons.moneyBill,
                color: CustomColors.blueGreen,
              ),
              title: Text("Amount Details"),
              trailing: Text('₹ ${oAmount + dAmount}'),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: TextFormField(
                initialValue: '$oAmount',
                textAlign: TextAlign.start,
                autofocus: false,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefix: Text('₹ '),
                  labelText: "Order Amount",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.lightGreen),
                  ),
                ),
                onChanged: (val) {
                  this.oAmount = double.parse(val);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: TextFormField(
                initialValue: '$wAmount',
                textAlign: TextAlign.start,
                autofocus: false,
                readOnly: true,
                decoration: InputDecoration(
                  prefix: Text('₹ '),
                  labelText: "Wallet Amount",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.lightGreen),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextFormField(
                initialValue: '$dAmount',
                textAlign: TextAlign.start,
                autofocus: false,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefix: Text('₹ '),
                  labelText: "Delivery Charge",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.lightGreen),
                  ),
                ),
                onChanged: (val) {
                  this.dAmount = double.parse(val);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextFormField(
                initialValue: '$rAmount',
                textAlign: TextAlign.start,
                autofocus: false,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefix: Text('₹ '),
                  labelText: "Received Amount",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.lightGreen),
                  ),
                ),
                onChanged: (val) {
                  this.rAmount = double.parse(val);
                },
              ),
            ),
            RaisedButton.icon(
              color: CustomColors.alertRed,
              onPressed: () async {
                try {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  await widget.order.updateAmountDetails(
                      widget.order.userNumber, oAmount, dAmount, rAmount);
                  Fluttertoast.showToast(
                      msg: 'Updated Amount Details',
                      backgroundColor: CustomColors.green,
                      textColor: CustomColors.black);
                } catch (err) {
                  print(err);
                  Fluttertoast.showToast(
                      msg: 'Error, Unable to Amount Details',
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
            )
          ],
        ),
      ),
    );
  }
}
