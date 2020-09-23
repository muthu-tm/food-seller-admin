import 'package:flutter/material.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/GradientText.dart';

class CustomDialogs {
  static information(BuildContext context, String title, Color titleColor,
      String description) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 10.0,
            title: Text(
              title,
              style: TextStyle(
                  color: titleColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(description)],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
                textColor: CustomColors.sellerBlue,
                color: CustomColors.sellerGreen,
              )
            ],
          );
        });
  }

  static waiting(BuildContext context, String title, String description) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 10.0,
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(description)],
              ),
            ),
          );
        });
  }

  static actionWaiting(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: CustomColors.sellerLightGrey.withOpacity(0.7),
      child: Container(
        alignment: Alignment.center,
        width: 50,
        height: 50,
        child: Stack(
          children: <Widget>[
            Container(
              width: 45,
              height: 45,
              alignment: Alignment.center,
              child: ClipRRect(
                child: Image.asset(
                  "images/icons/logo.png",
                  height: 35,
                  width: 35,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: SizedBox(
                width: 45,
                height: 45,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  backgroundColor: CustomColors.sellerBlue,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(CustomColors.sellerGreen),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static confirm(BuildContext context, String title, String description,
      Function() yesAction, Function() noAction) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 10.0,
          title: new Text(
            title,
            style: TextStyle(
                color: CustomColors.sellerAlertRed,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.start,
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Container(
                  child: Text(
                    description,
                    style: TextStyle(
                        color: CustomColors.sellerGreen, fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              elevation: 10.0,
              splashColor: CustomColors.sellerBlue,
              child: Text(
                'NO',
                style:
                    TextStyle(color: CustomColors.sellerBlue, fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              onPressed: noAction,
            ),
            RaisedButton(
              elevation: 10.0,
              splashColor: CustomColors.sellerAlertRed,
              child: Text(
                'YES',
                style: TextStyle(
                    color: CustomColors.sellerAlertRed, fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              onPressed: yesAction,
            ),
          ],
        );
      },
    );
  }
}
