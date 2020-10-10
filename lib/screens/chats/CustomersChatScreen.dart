import 'package:chipchop_seller/db/models/chat_temp.dart';
import 'package:chipchop_seller/screens/chats/StoreChatScreen.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
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
      body: FutureBuilder(
          future: ChatTemplate().streamStoreCustomers(storeID),
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
                          leading: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                            color: CustomColors.grey,
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            child: Icon(
                              Icons.person,
                              color: CustomColors.blueGreen,
                            ),
                          ),
                          title: Text(
                            snapshot.data.documents[index].data['first_name'],
                          ),
                          subtitle: Text(
                            snapshot
                                .data.documents[index].data['contact_number'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            } else if (snapshot.hasError) {
              child = Container(
                child:  Column(
                  children: AsyncWidgets.asyncError()
                ),
              );
            } else {
              child = Container(
                child: Column(
                  children: AsyncWidgets.asyncWaiting()
                ),
              );
            }
            return child;
          }),
    );
  }
}
