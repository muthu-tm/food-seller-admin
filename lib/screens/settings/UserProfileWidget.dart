import 'package:chipchop_seller/app_localizations.dart';
import 'package:chipchop_seller/db/models/user.dart';
import 'package:chipchop_seller/screens/settings/ChangeSecret.dart';
import 'package:chipchop_seller/screens/settings/EditUserProfile.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:chipchop_seller/services/controllers/user/user_service.dart';
import 'package:chipchop_seller/services/utils/DateUtils.dart';
import 'package:flutter/material.dart';

class UserProfileWidget extends StatelessWidget {
  UserProfileWidget(this.user, [this.title = "Profile Details"]);

  final User user;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustomColors.sellerLightGrey,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.assignment_ind,
              size: 35.0,
              color: CustomColors.sellerButtonGreen,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: CustomColors.sellerPurple,
                fontSize: 18.0,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.edit,
                size: 35.0,
                color: CustomColors.sellerButtonGreen,
              ),
              onPressed: () {
                if (user.mobileNumber != cachedLocalUser.mobileNumber) {
                  CustomDialogs.information(
                      context,
                      "Warning",
                      CustomColors.sellerAlertRed,
                      "You are not allowed to edit this user data!");
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUserProfile(),
                      settings: RouteSettings(name: '/settings/user/edit'),
                    ),
                  );
                }
              },
            ),
          ),
          Divider(
            color: CustomColors.sellerButtonGreen,
          ),
          ListTile(
            leading: SizedBox(
              width: 95,
              child: Text(
                AppLocalizations.of(context).translate('name'),
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.sellerGrey),
              ),
            ),
            title: TextFormField(
              initialValue: user.firstName,
              decoration: InputDecoration(
                fillColor: CustomColors.sellerWhite,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: CustomColors.sellerGrey,
                )),
              ),
              readOnly: true,
            ),
          ),
          ListTile(
            leading: SizedBox(
              width: 95,
              child: Text(
                AppLocalizations.of(context).translate('contact_number'),
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.sellerGrey),
              ),
            ),
            title: TextFormField(
              initialValue: user.countryCode.toString() +
                  ' ' +
                  user.mobileNumber.toString(),
              decoration: InputDecoration(
                fillColor: CustomColors.sellerLightGrey,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.sellerGrey)),
              ),
              enabled: false,
              autofocus: false,
            ),
          ),
          (user.mobileNumber == cachedLocalUser.mobileNumber)
              ? ListTile(
                  leading: SizedBox(
                    width: 95,
                    child: Text(
                      AppLocalizations.of(context).translate('password'),
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Georgia",
                          fontWeight: FontWeight.bold,
                          color: CustomColors.sellerGrey),
                    ),
                  ),
                  title: TextFormField(
                    initialValue: "****",
                    textAlign: TextAlign.start,
                    obscureText: true,
                    decoration: InputDecoration(
                      fillColor: CustomColors.sellerWhite,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: CustomColors.sellerGrey)),
                    ),
                    readOnly: true,
                  ),
                  trailing: IconButton(
                    highlightColor:
                        CustomColors.sellerAlertRed.withOpacity(0.5),
                    tooltip: AppLocalizations.of(context)
                        .translate('change_password'),
                    icon: Icon(
                      Icons.edit,
                      size: 25.0,
                      color: CustomColors.sellerAlertRed.withOpacity(0.7),
                    ),
                    onPressed: () {
                      if (user.mobileNumber == cachedLocalUser.mobileNumber) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeSecret(),
                            settings: RouteSettings(
                                name: '/settings/user/secret/edit'),
                          ),
                        );
                      }
                    },
                  ),
                )
              : Container(),
          ListTile(
            leading: SizedBox(
              width: 95,
              child: Text(
                AppLocalizations.of(context).translate('gender'),
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.sellerGrey),
              ),
            ),
            title: TextFormField(
              initialValue: user.gender,
              decoration: InputDecoration(
                fillColor: CustomColors.sellerWhite,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.sellerGrey)),
              ),
              readOnly: true,
            ),
          ),
          ListTile(
            leading: SizedBox(
              width: 95,
              child: Text(
                AppLocalizations.of(context).translate('email'),
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.sellerGrey),
              ),
            ),
            title: TextFormField(
              initialValue: user.emailID,
              decoration: InputDecoration(
                fillColor: CustomColors.sellerWhite,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.sellerWhite)),
              ),
              readOnly: true,
            ),
          ),
          ListTile(
            leading: SizedBox(
              width: 95,
              child: Text(
                AppLocalizations.of(context).translate('dob'),
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.sellerGrey),
              ),
            ),
            title: TextFormField(
              initialValue: user.dateOfBirth == null
                  ? ''
                  : DateUtils.formatDate(
                      DateTime.fromMillisecondsSinceEpoch(user.dateOfBirth)),
              decoration: InputDecoration(
                fillColor: CustomColors.sellerWhite,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.sellerGrey)),
                suffixIcon: Icon(
                  Icons.perm_contact_calendar,
                  size: 35,
                  color: CustomColors.sellerButtonGreen,
                ),
              ),
              readOnly: true,
            ),
          ),
          ListTile(
            leading: SizedBox(
              width: 95,
              child: Text(
                AppLocalizations.of(context).translate('address'),
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Georgia",
                    fontWeight: FontWeight.bold,
                    color: CustomColors.sellerGrey),
              ),
            ),
            title: TextFormField(
              initialValue: user.address.toString(),
              maxLines: 5,
              decoration: InputDecoration(
                fillColor: CustomColors.sellerWhite,
                filled: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 1.0, horizontal: 5.0),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: CustomColors.sellerGrey)),
              ),
              readOnly: true,
            ),
          )
        ],
      ),
    );
  }
}
