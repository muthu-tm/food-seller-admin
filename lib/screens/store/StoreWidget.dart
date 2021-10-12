import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/db/models/user_activity_tracker.dart';
import 'package:chipchop_seller/screens/customers/CustomersScreen.dart';
import 'package:chipchop_seller/screens/store/EditStoreScreen.dart';
import 'package:chipchop_seller/screens/store/ViewStoreScreen.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/services/utils/Dateutils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class StoreWidget extends StatelessWidget {
  StoreWidget(this.store);

  final Store store;
  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.20,
      child: Container(
        child: _getStoreBody(),
      ),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Chats',
          color: Colors.blue,
          icon: Icons.question_answer,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomersScreen(
                store.uuid,
                store.name,
              ),
              settings: RouteSettings(name: '/store/customers'),
            ),
          ),
        ),
        IconSlideAction(
          caption: 'Share',
          color: Colors.indigo,
          icon: Icons.share,
          onTap: () => print("TODO"),
        ),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: 'View',
            color: Colors.black45,
            icon: Icons.remove_red_eye,
            onTap: () {
              UserActivityTracker _activity = UserActivityTracker();
              _activity.keywords = "";
              _activity.storeID = store.uuid;
              _activity.storeName = store.name;
              _activity.refImage = store.getPrimaryImage();
              _activity.type = 1;
              _activity.create();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewStoreScreen(store),
                  settings: RouteSettings(name: '/store'),
                ),
              );
            }),
        IconSlideAction(
          caption: 'Edit',
          color: Colors.red[400],
          icon: Icons.edit,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditStoreScreen(store),
              settings: RouteSettings(name: '/store/edit'),
            ),
          ),
        ),
      ],
    );
  }

  Card _getStoreBody() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      elevation: 2,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: 5, top: 5, right: 10, bottom: 5),
                      child: Container(
                        height: 75,
                        width: 75,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: store.getPrimaryImage(),
                            imageBuilder: (context, imageProvider) => Image(
                              fit: BoxFit.fill,
                              image: imageProvider,
                            ),
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Container(
                              height: 75,
                              width: 75,
                              alignment: Alignment.center,
                              child: SizedBox(
                                height: 50.0,
                                width: 50.0,
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                    valueColor: AlwaysStoppedAnimation(
                                        CustomColors.blue),
                                    strokeWidth: 2.0),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 75,
                              height: 75,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.error,
                                size: 35,
                              ),
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
                            "${Dateutils.getFormattedTime(store.activeFrom)} : ${Dateutils.getFormattedTime(store.activeTill)}",
                            style: TextStyle(
                                fontSize: 12, color: CustomColors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
