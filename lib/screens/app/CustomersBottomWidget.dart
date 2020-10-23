import 'package:chipchop_seller/db/models/chat_temp.dart';
import 'package:chipchop_seller/screens/customers/CustomersHome.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

bool newStoreNotification = false;

class CustomersBottomWidget extends StatefulWidget {
  CustomersBottomWidget(this.size);

  final Size size;

  @override
  _CustomersBottomWidgetState createState() => _CustomersBottomWidgetState();
}

class _CustomersBottomWidgetState extends State<CustomersBottomWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  bool _newStoreNotification = false;

  @override
  void initState() {
    super.initState();
    _newStoreNotification = newStoreNotification;
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        if (message['data']['type'] == '1') {
          // showDialog(
          //   context: context,
          //   builder: (context) => AlertDialog(
          //     content: ListTile(
          //       title: Text(
          //         message['notification']['title'],
          //         style: TextStyle(
          //             color: CustomColors.green,
          //             fontSize: 16.0,
          //             
          //             fontWeight: FontWeight.bold),
          //         textAlign: TextAlign.start,
          //       ),
          //       subtitle: Text(
          //         message['notification']['body'],
          //         style: TextStyle(
          //             fontSize: 14.0,
          //             
          //             fontWeight: FontWeight.bold),
          //       ),
          //     ),
          //     actions: <Widget>[
          //       FlatButton(
          //         child: Text('OK'),
          //         onPressed: () => Navigator.of(context).pop(),
          //       ),
          //     ],
          //   ),
          // );

          await ChatTemplate().updateToUnRead(
            message['data']['store_uuid'],
            message['data']['customer_uuid'],
          );
          setState(() {
            _newStoreNotification = true;
            newStoreNotification = true;
          });
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (message['data']['type'] == '1') {
          await ChatTemplate().updateToUnRead(
            message['data']['store_uuid'],
            message['data']['customer_uuid'],
          );

          setState(() {
            _newStoreNotification = true;
            newStoreNotification = true;
          });
        }
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        if (message['data']['type'] == '1') {
          await ChatTemplate().updateToUnRead(
            message['data']['store_uuid'],
            message['data']['customer_uuid'],
          );

          setState(() {
            _newStoreNotification = true;
            newStoreNotification = true;
          });
        }
        print("onResume: $message");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    _newStoreNotification
        ? child = SizedBox.fromSize
        
        (
            size: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomersHome(),
                        settings: RouteSettings(name: '/customers'),
                      ),
                    ).then((value) {
                      newStoreNotification = false;
                      _newStoreNotification = false;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.group,
                        size: 25.0,
                        color: CustomColors.black,
                      ),
                      Text(
                        "CUSTOMERS",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          
                          fontSize: 11,
                          color: CustomColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 25,
                  top: 10,
                  child: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: CustomColors.alertRed,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 13,
                      minHeight: 13,
                    ),
                    child: Text(
                      '',
                      style: TextStyle(
                        color: CustomColors.black,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          )
        : child = SizedBox.fromSize(
            size: widget.size,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomersHome(),
                    settings: RouteSettings(name: '/customers'),
                  ),
                ).then((value) {
                  newStoreNotification = false;
                  _newStoreNotification = false;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.group,
                    size: 25.0,
                    color: CustomColors.black,
                  ),
                  Text(
                    "CUSTOMERS",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.oswald()
                  ),
                ],
              ),
            ),
          );

    return child;
  }
}
