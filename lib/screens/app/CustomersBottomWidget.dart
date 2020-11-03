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
        if (message['data']['type'] == '1') {
          ChatTemplate().updateToUnRead(
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
        ? child = SizedBox.fromSize(
            size: widget.size,
            child: InkWell(
              onTap: () {
                setState(() {
                  _newStoreNotification = false;
                  newStoreNotification = false;
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomersHome(),
                    settings: RouteSettings(name: '/customers'),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(alignment: Alignment.center, children: <Widget>[
                    Icon(
                      Icons.group,
                      size: 30.0,
                      color: CustomColors.black,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: CustomColors.alertRed,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
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
                    ),
                  ]),
                  Text("Customers",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orienta()),
                ],
              ),
            ),
          )
        : child = SizedBox.fromSize(
            size: widget.size,
            child: InkWell(
              onTap: () {
                setState(() {
                  _newStoreNotification = false;
                  newStoreNotification = false;
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomersHome(),
                    settings: RouteSettings(name: '/customers'),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.group,
                    size: 30.0,
                    color: CustomColors.black,
                  ),
                  Text("Customers",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.orienta()),
                ],
              ),
            ),
          );

    return child;
  }
}
