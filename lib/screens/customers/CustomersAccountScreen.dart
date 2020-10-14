import 'package:chipchop_seller/db/models/customers.dart';
import 'package:chipchop_seller/db/models/user_store_wallet_history.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/services/utils/DateUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomersAccountScreen extends StatefulWidget {
  CustomersAccountScreen(this.customer);

  final Customers customer;
  @override
  _CustomersAccountScreenState createState() => _CustomersAccountScreenState();
}

class _CustomersAccountScreenState extends State<CustomersAccountScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          '${widget.customer.firstName}',
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
        backgroundColor: CustomColors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: CustomColors.blueGreen,
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      body: getTransactionHistoryWidget(context),
    );
  }

  Widget getTransactionHistoryWidget(BuildContext context) {
    return StreamBuilder(
      stream: UserStoreWalletHstory().streamUsersStoreWallet(
          widget.customer.storeID, widget.customer.contactNumber),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget widget;

        if (snapshot.hasData) {
          if (snapshot.data.documents.length > 0) {
            widget = ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                UserStoreWalletHstory history = UserStoreWalletHstory.fromJson(
                    snapshot.data.documents[index].data);

                Color tileColor = CustomColors.green;
                Color textColor = CustomColors.white;

                if (index % 2 == 0) {
                  tileColor = CustomColors.white;
                  textColor = CustomColors.alertRed;
                }

                return Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Material(
                    color: tileColor,
                    elevation: 3.0,
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      height: MediaQuery.of(context).size.width / 5,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: tileColor,
                      ),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.local_offer,
                              size: 35.0,
                              color: CustomColors.alertRed.withOpacity(0.6),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5, top: 5.0),
                            width: MediaQuery.of(context).size.width / 1.5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  history.userNumber.toString(),
                                  style: TextStyle(
                                      fontFamily: "Georgia",
                                      fontSize: 18.0,
                                      color: textColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'At: ${DateUtils.formatDate(DateTime.fromMillisecondsSinceEpoch(history.createdAt))}',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      color: textColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  history.type == 0
                                      ? "Order Debit"
                                      : history.type == 1
                                          ? "Order Credit"
                                          : history.type == 2
                                              ? "Store Offer"
                                              : "Offer",
                                  style: TextStyle(
                                      fontSize: 10.0,
                                      color: CustomColors.alertRed
                                          .withOpacity(0.7),
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              '${history.amount}/-',
                              style: TextStyle(
                                  fontSize: 14.0,
                                  color: textColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            widget = Container(
              padding: EdgeInsets.all(10),
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "No Transactions Found",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CustomColors.alertRed,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
        } else if (snapshot.hasError) {
          widget = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: AsyncWidgets.asyncError());
        } else {
          widget = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: AsyncWidgets.asyncWaiting());
        }

        return SingleChildScrollView(
          child: Card(
            color: CustomColors.lightGrey,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.all_inclusive,
                    size: 35.0,
                    color: CustomColors.alertRed,
                  ),
                  title: Text(
                    "Transaction History",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Georgia",
                      fontWeight: FontWeight.bold,
                      color: CustomColors.green,
                      fontSize: 17.0,
                    ),
                  ),
                ),
                Divider(
                  color: CustomColors.alertRed,
                ),
                widget,
              ],
            ),
          ),
        );
      },
    );
  }
}
