import 'package:chipchop_seller/screens/utils/ColorLoader.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/GradientText.dart';
import 'package:flutter/material.dart';

class AsyncWidgets {
  static asyncWaiting(
      {dotOneColor = CustomColors.alertRed,
      dotTwoColor = CustomColors.blue,
      dotThreeColor = CustomColors.lightPurple}) {
    return <Widget>[
      ColorLoader(
        dotOneColor: dotOneColor,
        dotTwoColor: dotTwoColor,
        dotThreeColor: dotThreeColor,
        dotIcon: Icon(Icons.adjust),
      ),
      GradientText(
        'Loading...',
        size: 18.0,
        gradient: LinearGradient(
          colors: [
            CustomColors.green,
            CustomColors.blue,
          ],
        ),
      ),
    ];
  }

  static asyncError() {
    return <Widget>[
      Icon(
        Icons.error_outline,
        color: CustomColors.alertRed,
        size: 60,
      ),
      Text(
        'Unable to load, Error!',
        style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            color: CustomColors.alertRed),
      ),
    ];
  }
}
