import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/url_launcher_utils.dart';
import 'package:chipchop_seller/services/utils/DateUtils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StoreProfileWidget extends StatelessWidget {
  StoreProfileWidget(this.store);

  final Map<String, String> tempCollectionDays = {
    "0": "Sun",
    "1": "Mon",
    "2": "Tue",
    "3": "Wed",
    "4": "Thu",
    "5": "Fri",
    "6": "Sat",
  };

  final Store store;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: true,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              FontAwesomeIcons.store,
              color: CustomColors.primary,
            ),
            title: Text(
              store.name,
              style: TextStyle(
                color: CustomColors.black,
                fontSize: 13.0,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.addressCard,
              color: CustomColors.primary,
            ),
            title: Text(
              store.address.toString(),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: CustomColors.black,
                fontSize: 13.0,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.mobileAlt,
              color: CustomColors.primary,
            ),
            title: Text(
              "Contacts",
              style: TextStyle(
                  color: CustomColors.grey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 60.0),
            child: Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                primary: true,
                shrinkWrap: true,
                itemCount: store.contacts.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: CustomColors.white),
                        child: RawMaterialButton(
                          onPressed: () {
                            UrlLauncherUtils.makePhoneCall(
                                store.contacts[index].contactNumber);
                          },
                          shape: CircleBorder(),
                          child: Icon(FontAwesomeIcons.image,
                              color: CustomColors.blue),
                        ),
                      ),
                      Text(
                        store.contacts[index].contactName,
                        style: TextStyle(
                          color: CustomColors.black,
                        ),
                      ),
                      Text(
                        store.contacts[index].contactNumber,
                        style: TextStyle(
                          color: CustomColors.black,
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.calendarCheck,
              color: CustomColors.primary,
            ),
            title: Text(
              "Business Days",
              style: TextStyle(
                  color: CustomColors.grey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: CustomColors.grey, width: 1.0),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: selectedDays.toList(),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.businessTime,
              color: CustomColors.primary,
            ),
            title: Text(
              "Active From: ",
              style: TextStyle(
                  color: CustomColors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500),
            ),
            trailing: Text(
              DateUtils.getFormattedTime(store.activeFrom),
              textAlign: TextAlign.start,
              style: TextStyle(
                color: CustomColors.black,
                fontSize: 14.0,
              ),
            ),
          ),
          ListTile(
            leading: Text(""),
            title: Text(
              "Active Till: ",
              style: TextStyle(
                  color: CustomColors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500),
            ),
            trailing: Text(
              DateUtils.getFormattedTime(store.activeTill),
              textAlign: TextAlign.start,
              style: TextStyle(
                color: CustomColors.black,
                fontSize: 14.0,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.truck,
              color: CustomColors.primary,
            ),
            title: Text(
              "Delivery Details",
              style: TextStyle(
                  color: CustomColors.grey,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 60.0),
            child: Column(
              children: [
                ListTile(
                  leading: Text(
                    "Delivery From:",
                    style: TextStyle(
                      color: CustomColors.black,
                    ),
                  ),
                  trailing: Text(
                    DateUtils.getFormattedTime(
                        store.deliveryDetails.deliveryFrom),
                    style: TextStyle(
                      color: CustomColors.black,
                    ),
                  ),
                ),
                ListTile(
                  leading: Text(
                    "Delivery Till:",
                    style: TextStyle(
                      color: CustomColors.black,
                    ),
                  ),
                  trailing: Text(
                    DateUtils.getFormattedTime(
                        store.deliveryDetails.deliveryTill),
                    style: TextStyle(
                      color: CustomColors.black,
                    ),
                  ),
                ),
                ListTile(
                  leading: Text(
                    "Max Distance:",
                    style: TextStyle(
                      color: CustomColors.black,
                    ),
                  ),
                  trailing: Text(
                    '${store.deliveryDetails.maxDistance.toString()} km',
                    style: TextStyle(
                      color: CustomColors.black,
                    ),
                  ),
                ),
                SizedBox(
                  height: 60
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Iterable<Widget> get selectedDays sync* {
    for (MapEntry days in tempCollectionDays.entries) {
      yield Transform(
        transform: Matrix4.identity()..scale(0.9),
        child: ChoiceChip(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          label: Text(days.value),
          selected: store.workingDays.contains(int.parse(days.key)),
          elevation: 2.0,
          selectedColor: CustomColors.primary,
          backgroundColor: CustomColors.white,
          labelStyle: TextStyle(
              color: store.workingDays.contains(int.parse(days.key))
                  ? CustomColors.blue
                  : CustomColors.black),
        ),
      );
    }
  }
}
