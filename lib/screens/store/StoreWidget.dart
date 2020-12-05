import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/db/models/user_activity_tracker.dart';
import 'package:chipchop_seller/screens/customers/CustomersHome.dart';
import 'package:chipchop_seller/screens/store/ViewStoreScreen.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/services/utils/DateUtils.dart';
import 'package:flutter/material.dart';

class StoreWidget extends StatelessWidget {
  StoreWidget(this.store);

  final Store store;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Container(
                height: 120,
                width: 110,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.0),
                    bottomLeft: Radius.circular(5.0),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: store.getPrimaryImage(),
                    imageBuilder: (context, imageProvider) => Image(
                      fit: BoxFit.fill,
                      image: imageProvider,
                    ),
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Center(
                      child: SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                            valueColor:
                                AlwaysStoppedAnimation(CustomColors.blue),
                            strokeWidth: 2.0),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error,
                      size: 35,
                    ),
                    fadeOutDuration: Duration(seconds: 1),
                    fadeInDuration: Duration(seconds: 2),
                  ),
                ),
              ),
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    store.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: CustomColors.purple,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    store.address.city ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CustomColors.black,
                      fontSize: 12.0,
                    ),
                  ),
                  Text(
                    "${DateUtils.getFormattedTime(store.activeFrom)} : ${DateUtils.getFormattedTime(store.activeTill)}",
                    style: TextStyle(fontSize: 12, color: CustomColors.black),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: RaisedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomersHome(),
                                    settings:
                                        RouteSettings(name: '/customers/store'),
                                  ),
                                );
                              },
                              color: CustomColors.primary,
                              child: Text(
                                "Chat",
                                style: TextStyle(fontSize: 13),
                              )),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: RaisedButton(
                            onPressed: () {
                              UserActivityTracker _activity =
                                  UserActivityTracker();
                              _activity.keywords = "";
                              _activity.storeID = store.uuid;
                              _activity.storeName = store.name;
                              _activity.type = 1;
                              _activity.create();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewStoreScreen(store),
                                  settings: RouteSettings(name: '/store'),
                                ),
                              );
                            },
                            color: CustomColors.lightGreen,
                            child: Text(
                              "Preview",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
