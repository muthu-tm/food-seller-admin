import 'package:flutter/material.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/url_launcher_utils.dart';

Widget contactAndSupportDialog(context) {
  return Container(
    height: 400,
    width: MediaQuery.of(context).size.width * 0.9,
    child: Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.headset_mic,
              size: 35.0,
              color: CustomColors.alertRed,
            ),
            title: Text(
              "Help and Support",
              style: TextStyle(
                  color: CustomColors.primary,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Divider(
            color: CustomColors.blue,
          ),
          SizedBox(height: 5),
          ClipRRect(
              child: Image.asset(
                "images/icons/logo.png",
                height: 60,
                width: 60,
              ),
            ),
          SizedBox(height: 15),
          Text(
            "Get Lost? Need Some Help?",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: CustomColors.primary,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          ),
          Text(
            "We are happy to help you!",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: CustomColors.positiveGreen,
                fontSize: 14.0,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 40),
          Text(
            "Contact Us",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: CustomColors.primary,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(
                flex: 2,
              ),
              RaisedButton.icon(
                icon: Icon(
                  Icons.email,
                  color: CustomColors.alertRed,
                ),
                elevation: 15.0,
                onPressed: () {
                  UrlLauncherUtils.sendEmail(
                      'hello.ifin@gmail.com',
                      'ChipChop Seller - Help %26 Support',
                      'Please type your query/issue here with your mobile number.. We will get back to you ASAP!');
                },
                label: Text(
                    "Email",
                    style: TextStyle(
                      color: CustomColors.blue,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                color: CustomColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              Spacer(
                flex: 1,
              ),
              RaisedButton.icon(
                icon: Icon(
                  Icons.phone,
                  color: CustomColors.alertRed,
                ),
                elevation: 15.0,
                onPressed: () {
                  UrlLauncherUtils.makePhoneCall('919361808580');
                },
                label: Text(
                    "Phone",
                    style: TextStyle(
                      color: CustomColors.blue,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                color: CustomColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
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
}
