import 'package:chipchop_seller/db/models/chat_temp.dart';
import 'package:chipchop_seller/db/models/customers.dart';
import 'package:chipchop_seller/screens/customers/CustomersAccountScreen.dart';
import 'package:chipchop_seller/screens/customers/StoreChatScreen.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomersScreen extends StatelessWidget {
  CustomersScreen(this.storeID, this.storeName);

  final String storeID;
  final String storeName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$storeName',
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
      body: StreamBuilder(
          stream: Customers().streamStoreCustomers(storeID),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            Widget child;

            if (snapshot.hasData) {
              if (snapshot.data.documents.length == 0) {
                child = Center(
                  child: Container(
                    child: Text(
                      "No Customers",
                      style: TextStyle(color: CustomColors.black),
                    ),
                  ),
                );
              } else {
                child = Container(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    primary: true,
                    shrinkWrap: true,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      Customers cust = Customers.fromJson(
                          snapshot.data.documents[index].data);
                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: CustomColors.grey,
                                    borderRadius: BorderRadius.circular(40.0),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: CustomColors.primary,
                                  ),
                                ),
                                title: Text(cust.firstName),
                                trailing: (cust.hasStoreUnread)
                                    ? Icon(
                                        Icons.question_answer,
                                        color: CustomColors.alertRed,
                                      )
                                    : Text(""),
                                subtitle: Text(
                                  cust.contactNumber,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Spacer(
                                    flex: 2,
                                  ),
                                  FlatButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StoreChatScreen(
                                            storeID: storeID,
                                            custID: cust.contactNumber,
                                            custName: cust.firstName +
                                                ' ' +
                                                cust.lastName,
                                          ),
                                          settings: RouteSettings(
                                              name: '/customers/chats'),
                                        ),
                                      ).then((value) async {
                                        await ChatTemplate().updateToRead(
                                            storeID,
                                            snapshot.data.documents[index]
                                                .documentID);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.question_answer,
                                      color: CustomColors.alertRed,
                                    ),
                                    label: Text(
                                      "Chats",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.indigo.shade700),
                                    ),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                  ),
                                  Spacer(
                                    flex: 3,
                                  ),
                                  Container(
                                    height: 20,
                                    width: 1,
                                    color: Colors.grey,
                                  ),
                                  Spacer(
                                    flex: 3,
                                  ),
                                  FlatButton.icon(
                                    onPressed: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CustomersAccountScreen(cust),
                                          settings: RouteSettings(
                                              name: '/customers/accounts'),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.account_balance_wallet,
                                      color: CustomColors.alertRed,
                                    ),
                                    label: Text(
                                      "Accounts",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.indigo.shade700),
                                    ),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                  ),
                                  Spacer(
                                    flex: 2,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            } else if (snapshot.hasError) {
              child = Container(
                child: Column(
                  children: AsyncWidgets.asyncError(),
                ),
              );
            } else {
              child = Container(
                child: Column(
                  children: AsyncWidgets.asyncWaiting(),
                ),
              );
            }
            return child;
          }),
    );
  }
}
