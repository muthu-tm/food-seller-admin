import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/app/appBar.dart';
import 'package:chipchop_seller/screens/app/bottomBar.dart';
import 'package:chipchop_seller/screens/app/sideDrawer.dart';
import 'package:chipchop_seller/screens/chats/CustomersChatScreen.dart';
import 'package:chipchop_seller/screens/store/ViewStoreScreen.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/NoStoresWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      drawer: sideDrawer(context),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: StreamBuilder(
              stream: Store().streamStoresForUser(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                Widget child;

                if (snapshot.hasData) {
                  if (snapshot.data.documents.length == 0) {
                    child = NoStoresWidget();
                  } else {
                    child = Container(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        primary: true,
                        shrinkWrap: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          Store store = Store.fromJson(
                              snapshot.data.documents[index].data);

                          return Container(
                            height: 145,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 5,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10, top: 5),
                                        child: Container(
                                          height: 75,
                                          width: 75,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  store.getStoreImages().first,
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Image(
                                                fit: BoxFit.fill,
                                                image: imageProvider,
                                              ),
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      Center(
                                                child: SizedBox(
                                                  height: 50.0,
                                                  width: 50.0,
                                                  child: CircularProgressIndicator(
                                                      value: downloadProgress
                                                          .progress,
                                                      valueColor:
                                                          AlwaysStoppedAnimation(
                                                              CustomColors
                                                                  .blue),
                                                      strokeWidth: 2.0),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                Icons.error,
                                                size: 35,
                                              ),
                                              fadeOutDuration:
                                                  Duration(seconds: 1),
                                              fadeInDuration:
                                                  Duration(seconds: 2),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    color: Colors.grey.shade300,
                                    height: 1,
                                    width: double.infinity,
                                  ),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Spacer(
                                          flex: 2,
                                        ),
                                        FlatButton.icon(
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewStoreScreen(store),
                                                settings: RouteSettings(
                                                    name: '/store'),
                                              ),
                                            );
                                          },
                                          label: Text(
                                            "View",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: CustomColors.blueGreen),
                                          ),
                                          icon: Icon(Icons.remove_red_eye),
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                        ),
                                        Spacer(
                                          flex: 3,
                                        ),
                                        Container(
                                          height: 20,
                                          width: 1,
                                          color: Colors.grey,
                                        ),
                                        Spacer(
                                          flex: 3,
                                        ),
                                        FlatButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CustomersChatScreen(
                                                        store.uuid, store.name),
                                                settings: RouteSettings(
                                                    name: '/store/chats'),
                                              ),
                                            );
                                          },
                                          label: Text(
                                            "Chats",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: CustomColors.blueGreen),
                                          ),
                                          icon: Icon(Icons.chat),
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                        ),
                                        Spacer(
                                          flex: 2,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                } else if (snapshot.hasError) {
                  child = Center(
                    child: Column(
                      children: AsyncWidgets.asyncError(),
                    ),
                  );
                } else {
                  child = Center(
                    child: Column(
                      children: AsyncWidgets.asyncWaiting(),
                    ),
                  );
                }
                return child;
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomBar(context),
    );
  }
}
