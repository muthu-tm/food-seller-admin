import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/customers/CustomersScreen.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/NoStoresWidget.dart';
import 'package:flutter/material.dart';

class CustomersHome extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Store().getStoresForUser(),
        builder: (context, AsyncSnapshot<List<Store>> snapshot) {
          Widget child;

          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              child = Center(
                child: NoStoresWidget()
              );
            } else {
              child = Container(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  primary: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    Store _s = snapshot.data[index];
                    return Padding(
                      padding: EdgeInsets.all(5),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CustomersScreen(_s.uuid, _s.name),
                              settings: RouteSettings(
                                  name: '/customers/store'),
                            ),
                          );
                        },
                        leading: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: Center(
                            child: CachedNetworkImage(
                              imageUrl: _s.getStoreImages().first,
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                radius: 45.0,
                                backgroundImage: imageProvider,
                                backgroundColor: Colors.transparent,
                              ),
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) => Icon(
                                Icons.error,
                                size: 35,
                              ),
                              fadeOutDuration: Duration(seconds: 1),
                              fadeInDuration: Duration(seconds: 2),
                            ),
                          ),
                        ),
                        title: Text(
                          _s.name,
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          } else if (snapshot.hasError) {
            child = Container(
              child: Column(
                children: AsyncWidgets.asyncError(),
              ),
            );
          } else {
            child = Container(
              child: Column(
                children: AsyncWidgets.asyncWaiting(),
              ),
            );
          }
          return child;
        },
    );
  }
}
