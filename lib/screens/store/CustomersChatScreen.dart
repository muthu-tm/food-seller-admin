import 'package:chipchop_seller/db/models/chat_temp.dart';
import 'package:chipchop_seller/screens/store/StoreChatScreen.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomersChatScreen extends StatelessWidget {
  CustomersChatScreen(this.storeID);

  final String storeID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Customers",
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.lightGrey, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      body: StreamBuilder(
          stream: ChatTemplate().streamStoreCustomers(storeID),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            Widget child;

            if (snapshot.hasData) {
              if (snapshot.data.documents.length == 0) {
                child = Center(
                  child: Container(
                    child: Text(
                      "No Chats",
                      style: TextStyle(color: CustomColors.black),
                    ),
                  ),
                );
              } else {
                child = Container(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    primary: true,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.all(5),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StoreChatScreen(
                                    storeID: storeID,
                                    custID: snapshot
                                        .data.documents[index].documentID),
                                settings:
                                    RouteSettings(name: '/store/chat/customer'),
                              ),
                            );
                          },
                          leading: Icon(Icons.person),
                          title:
                              Text(snapshot.data.documents[index].data['name']),
                          subtitle:
                              Text(snapshot.data.documents[index].documentID),
                        ),
                      );
                    },
                  ),
                );
              }
            } else if (snapshot.hasError) {
              child = Container(
                child: Text(
                  "Error...",
                  style: TextStyle(color: CustomColors.black),
                ),
              );
            } else {
              child = Container(
                child: Text(
                  "Loading...",
                  style: TextStyle(color: CustomColors.black),
                ),
              );
            }
            return child;
          }),
    );
  }
}
