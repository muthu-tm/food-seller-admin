import 'package:flutter/material.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';

class CustomSnackBar {
  static errorSnackBar(String errorText, int duration) {
    return SnackBar(
      content: Text(
        errorText,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 16.0,
            color: CustomColors.lightGrey,
            fontWeight: FontWeight.bold),
      ),
      duration: Duration(seconds: duration),
      backgroundColor: CustomColors.alertRed,
    );
  }

  static successSnackBar(String text, int duration) {
    return SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
          color: CustomColors.lightGrey,
          fontWeight: FontWeight.bold,
        ),
      ),
      duration: Duration(seconds: duration),
      backgroundColor: CustomColors.lightGreen,
    );
  }
}
