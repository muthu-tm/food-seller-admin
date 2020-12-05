import 'package:chipchop_seller/db/models/customers.dart';
import 'package:chipchop_seller/db/models/user_store_wallet_history.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/services/analytics/analytics.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:chipchop_seller/services/utils/DateUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
        backgroundColor: CustomColors.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: CustomColors.blueGreen,
        onPressed: () {
          _scaffoldKey.currentState.showBottomSheet(
            (context) => AddUserTransaction(
                widget.customer.storeID, widget.customer.contactNumber),
          );
        },
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            getWalletWidget(),
            getTransactionHistoryWidget(context),
          ],
        ),
      ),
    );
  }

  Widget getWalletWidget() {
    return StreamBuilder(
      stream: Customers().streamUsersData(
          widget.customer.storeID, widget.customer.contactNumber),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        Widget widget;

        if (snapshot.hasData) {
          if (snapshot.data.exists && snapshot.data.data.isNotEmpty) {
            Customers _cust = Customers.fromJson(snapshot.data.data);
            double amount = _cust.availableBalance;

            widget = Padding(
              padding: EdgeInsets.all(10),
              child: Card(
                elevation: 5.0,
                shadowColor: CustomColors.primary.withOpacity(0.7),
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        "Available Balance",
                        style: TextStyle(
                          color: CustomColors.blueGreen,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "₹ ${amount ?? 0.00}",
                        style: TextStyle(
                          color: amount.isNegative
                              ? CustomColors.alertRed
                              : CustomColors.primary,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            widget = Card(
              elevation: 5.0,
              shadowColor: CustomColors.alertRed.withOpacity(0.7),
              child: Container(
                padding: EdgeInsets.all(10),
                height: 50,
                child: Text(
                  "Rs.0.00",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CustomColors.primary,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

        return Card(
          color: CustomColors.lightGrey,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.account_balance_wallet,
                  size: 35.0,
                  color: CustomColors.alertRed,
                ),
                title: Text(
                  "Wallet Amount",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CustomColors.primary,
                    fontSize: 17.0,
                  ),
                ),
              ),
              Divider(
                color: CustomColors.primary,
              ),
              widget,
            ],
          ),
        );
      },
    );
  }

  Widget getTransactionHistoryWidget(BuildContext context) {
    return StreamBuilder(
      stream: UserStoreWalletHistory().streamUsersStoreWallet(
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
                UserStoreWalletHistory history =
                    UserStoreWalletHistory.fromJson(
                        snapshot.data.documents[index].data);

                Color tileColor = CustomColors.blueGreen;
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
                                  history.details,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
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
                                              ? "Store Transaction"
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
                      fontWeight: FontWeight.bold,
                      color: CustomColors.primary,
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

class AddUserTransaction extends StatefulWidget {
  AddUserTransaction(this.storeID, this.custID);

  final String storeID;
  final String custID;
  @override
  _AdUserdTransactionState createState() => _AdUserdTransactionState();
}

class _AdUserdTransactionState extends State<AddUserTransaction> {
  String details = "";
  double amount = 0.00;
  String _selectedType = "0";
  Map<String, String> _types = {
    "0": "Credit",
    "1": "Debit",
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: CustomColors.lightGrey,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
        border: Border.all(color: CustomColors.primary),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Card(
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: SizedBox(
                    width: 70,
                    child: Text(
                      "Details",
                      style: TextStyle(
                          fontSize: 16.0, color: CustomColors.blueGreen),
                    ),
                  ),
                  title: TextFormField(
                    textAlign: TextAlign.start,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.lightGreen),
                      ),
                      hintText: "Ex, Account Settlement",
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                    onChanged: (val) {
                      this.details = val.trim();
                    },
                  ),
                ),
                ListTile(
                  leading: SizedBox(
                    width: 70,
                    child: Text(
                      "Amount",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: CustomColors.blueGreen,
                      ),
                    ),
                  ),
                  title: TextFormField(
                    textAlign: TextAlign.start,
                    initialValue: amount.toString(),
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.lightGreen),
                      ),
                      fillColor: CustomColors.white,
                      filled: true,
                    ),
                    onChanged: (val) {
                      this.amount = double.parse(val.trim());
                    },
                  ),
                ),
                ListTile(
                  leading: SizedBox(
                    width: 70,
                    child: Text(
                      "Type",
                      style: TextStyle(
                          fontSize: 16.0, color: CustomColors.blueGreen),
                    ),
                  ),
                  title: Container(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        items: _types.entries.map(
                          (f) {
                            return DropdownMenuItem<String>(
                              value: f.key,
                              child: Text(f.value),
                            );
                          },
                        ).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedType = val;
                          });
                        },
                        value: _selectedType,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton.icon(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                color: CustomColors.alertRed,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.cancel,
                  color: CustomColors.white,
                ),
                label: Text(
                  "Cancel",
                  style: TextStyle(
                    color: CustomColors.white,
                  ),
                ),
              ),
              RaisedButton.icon(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                color: CustomColors.primary,
                onPressed: () async {
                  try {
                    UserStoreWalletHistory tran = new UserStoreWalletHistory();

                    if (_selectedType == "1")
                      tran.amount = this.amount * -1;
                    else
                      tran.amount = this.amount;

                    tran.details = this.details;
                    tran.type = 2;
                    tran.id = "";
                    tran.storeUUID = widget.storeID;
                    tran.createdAt = DateTime.now().millisecondsSinceEpoch;
                    tran.addedBy = cachedLocalUser.getID();
                    await tran.addTransaction(widget.storeID, widget.custID);
                    Navigator.pop(context);
                  } catch (err) {
                    Analytics.sendAnalyticsEvent({
                      'type': 'customer_accounts_error',
                      'store_id': widget.storeID,
                      'error': err.toString()
                    }, 'customer');
                    Fluttertoast.showToast(
                        msg: 'Sorry, Unable to ADD Transaction');
                  }
                },
                icon: Icon(Icons.add_circle),
                label: Text("Save"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
