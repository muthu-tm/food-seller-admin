import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/screens/store/ViewStoreScreen.dart';
import 'package:flutter/material.dart';

import '../../db/models/store.dart';
import '../utils/CustomColors.dart';

class HomeScreenStoreWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Store().getStoresForUser(),
        builder: (context, AsyncSnapshot<List<Store>> snapshot) {
          Widget child;

          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              child = Container(
                child: Text(
                  "No stores",
                  style: TextStyle(color: CustomColors.black),
                ),
              );
            } else {
              child = Container(
                height: (snapshot.data.length * 150).toDouble(),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  primary: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    Store store = snapshot.data[index];

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
                                builder: (context) => ViewStoreScreen(store),
                                settings: RouteSettings(name: '/store'),
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
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      CustomColors.blue),
                                              strokeWidth: 2.0),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
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
                ),
              );
            }
          } else if (snapshot.hasError) {
            child = Container(
              child: Text(
                "Error...",
                style: TextStyle(color: CustomColors.black),
              ),
            );
          } else {
            child = Container(
              child: Text(
                "Loading...",
                style: TextStyle(color: CustomColors.black),
              ),
            );
          }
          return child;
        });
  }
}
