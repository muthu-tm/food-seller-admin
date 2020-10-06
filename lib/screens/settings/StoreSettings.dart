import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/store/EditStoreScreen.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/AddStoreWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoreSettings extends StatefulWidget {
  @override
  _StoreSettingsState createState() => _StoreSettingsState();
}

class _StoreSettingsState extends State<StoreSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Store Settings",
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.lightGrey, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
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
          if (snapshot.data.documents.isNotEmpty) {
            children = ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) {
                Store store =
                    Store.fromJson(snapshot.data.documents[index].data);
                return Container(
                  height: 100,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditStoreScreen(store),
                            settings: RouteSettings(name: '/store/edit'),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Container(
                              height: 75,
                              width: 75,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CachedNetworkImage(
                                  imageUrl: store.getStoreImages().first,
                                  imageBuilder: (context, imageProvider) =>
                                      Image(
                                    fit: BoxFit.fill,
                                    image: imageProvider,
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Center(
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
                          Container(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  store.name,
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    color: CustomColors.blue,
                                    fontSize: 14.0,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Container(
                                  child: Text(
                                    "Timings - ${store.activeFrom} : ${store.activeTill}",
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      color: CustomColors.black,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                      "No Store Available",
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
}
