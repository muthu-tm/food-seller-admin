import 'package:chipchop_seller/screens/utils/ColorLoader.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/GradientText.dart';
import 'package:flutter/material.dart';

class AsyncWidgets {
  static asyncWaiting(
      {dotOneColor = CustomColors.sellerAlertRed,
      dotTwoColor = CustomColors.sellerBlue,
      dotThreeColor = CustomColors.sellerFadedPurple}) {
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
            CustomColors.sellerGreen,
            CustomColors.sellerBlue,
          ],
        ),
      ),
    ];
  }

  static asyncError() {
    return <Widget>[
      Icon(
        Icons.error_outline,
        color: CustomColors.sellerAlertRed,
        size: 60,
      ),
      Text(
        'Unable to load, Error!',
        style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            color: CustomColors.sellerAlertRed),
      ),
    ];
  }
}
