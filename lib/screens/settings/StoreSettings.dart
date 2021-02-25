import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/customers/CustomersScreen.dart';
import 'package:chipchop_seller/screens/store/EditStoreScreen.dart';
import 'package:chipchop_seller/screens/store/ViewStoreScreen.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/AddStoreWidget.dart';
import 'package:chipchop_seller/services/utils/DateUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class StoreSettings extends StatefulWidget {
  @override
  _StoreSettingsState createState() => _StoreSettingsState();
}

class _StoreSettingsState extends State<StoreSettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Store Settings",
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.primary,
      ),
      floatingActionButton: AddStoreWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
          child: Container(
        child: getStores(context),
      )),
    );
  }

  Widget getStores(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Store().streamStoresForUser(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.docs.isNotEmpty) {
            children = ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                Store store =
                    Store.fromJson(snapshot.data.docs[index].data());
                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.20,
                  child: Container(height: 100, child: _getStoreBody(store)),
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
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewStoreScreen(store),
                          settings: RouteSettings(name: '/store'),
                        ),
                      ),
                    ),
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
              },
            );
          } else {
            children = Center(
              child: Container(
                height: 90,
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    Text(
                      "Hey, Yet No Stores has been Added !!",
                      style: TextStyle(
                        color: CustomColors.alertRed,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(
                      flex: 2,
                    ),
                    Text(
                      "Add your Store Now!",
                      style: TextStyle(
                        color: CustomColors.blue,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Spacer(),
                  ],
                ),
              ),
            );
          }
        } else if (snapshot.hasError) {
          children = Center(
            child: Column(
              children: AsyncWidgets.asyncError(),
            ),
          );
        } else {
          children = Center(
            child: Column(
              children: AsyncWidgets.asyncWaiting(),
            ),
          );
        }

        return children;
      },
    );
  }

  Widget _getStoreBody(Store store) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: Container(
              height: 100,
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
                child: CachedNetworkImage(
                  imageUrl: store.getPrimaryImage(),
                  imageBuilder: (context, imageProvider) => Image(
                    fit: BoxFit.fill,
                    image: imageProvider,
                  ),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                    child: SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(
                          value: downloadProgress.progress,
                          valueColor: AlwaysStoppedAnimation(CustomColors.blue),
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Text(
                    store.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CustomColors.black,
                      fontSize: 14.0,
                    ),
                  ),
                ),
                SizedBox(height: 5.0),
                Text(
                  "${DateUtils.getFormattedTime(store.activeFrom)} to ${DateUtils.getFormattedTime(store.activeTill)}",
                  style: TextStyle(
                    color: CustomColors.black,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Switch(
            value: store.isActive,
            onChanged: (value) async {
              await store.updateStoreStatus(store.uuid, value);
            },
            inactiveTrackColor: CustomColors.alertRed,
            activeTrackColor: CustomColors.primary,
            activeColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
