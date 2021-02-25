import 'package:chipchop_seller/db/models/chat_temp.dart';
import 'package:chipchop_seller/db/models/customers.dart';
import 'package:chipchop_seller/screens/app/appBar.dart';
import 'package:chipchop_seller/screens/app/sideDrawer.dart';
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
      appBar: appBar(context),
      drawer: sideDrawer(context),
      body: Container(
        child: StreamBuilder(
          stream: Customers().streamStoreCustomers(storeID),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            Widget child;

            if (snapshot.hasData) {
              if (snapshot.data.docs.length == 0) {
                child = Center(
                  child: Container(
                    child: Text(
                      "No Customers !!",
                      style: TextStyle(color: CustomColors.black),
                    ),
                  ),
                );
              } else {
                child = ListView.builder(
                  scrollDirection: Axis.vertical,
                  primary: true,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    Customers cust =
                        Customers.fromJson(snapshot.data.docs[index].data());
                    return Padding(
                      padding: EdgeInsets.all(5),
                      child: Card(
                        elevation: 3,
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: CustomColors.grey,
                                      borderRadius: BorderRadius.circular(40.0),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: CustomColors.primary,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(cust.firstName +
                                                " " +
                                                cust.lastName ??
                                            ""),
                                        Text(
                                          cust.contactNumber,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                      width: 100,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.yellow[200],
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  StoreChatScreen(
                                                storeID: storeID,
                                                custID: cust.contactNumber,
                                                custName: cust.firstName +
                                                    ' ' +
                                                    cust.lastName,
                                              ),
                                              settings: RouteSettings(
                                                  name: '/customers/store/chats'),
                                            ),
                                          ).then((value) async {
                                            await ChatTemplate().updateToRead(
                                                storeID,
                                                snapshot.data.docs[index]
                                                    .id);
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            (cust.hasStoreUnread)
                                                ? Icon(
                                                    Icons.mark_chat_unread,
                                                    color: Colors.red[500],
                                                  )
                                                : Icon(
                                                    Icons.mark_chat_read,
                                                    color: Colors.black,
                                                  ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            Text(
                                              "Chats",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      )),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    width: 100,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.green[200],
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CustomersAccountScreen(cust),
                                            settings: RouteSettings(
                                                name: '/customers/store/accounts'),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.account_balance_wallet,
                                            color: CustomColors.black,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            "Wallet",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
          },
        ),
      ),
    );
  }
}
