import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/products/AddProducts.dart';
import 'package:chipchop_seller/screens/store/ViewStoreScreen.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/NoStoresWidget.dart';
import 'package:chipchop_seller/services/utils/Dateutils.dart';
import 'package:flutter/material.dart';

class ProductsHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Card(
              elevation: 2,
              color: CustomColors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ExpansionTile(
                backgroundColor: CustomColors.lightGrey,
                title: Text("View & Edit Products"),
                children: [getStores(context)],
              ),
            ),
          ),
          Card(
            elevation: 2,
            color: CustomColors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Container(
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProduct(),
                      settings: RouteSettings(name: '/products/add'),
                    ),
                  );
                },
                leading: Text("Add Products"),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getStores(BuildContext context) {
    return FutureBuilder<List<Store>>(
      future: Store().getStoresForUser(),
      builder: (BuildContext context, AsyncSnapshot<List<Store>> snapshot) {
        Widget children;
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            children = ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Store store = snapshot.data[index];
                return Padding(
                  padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5),
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
                    child: Card(
                      elevation: 2,
                      color: CustomColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: store.getPrimaryImage(),
                            imageBuilder: (context, imageProvider) => Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                ),
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                    fit: BoxFit.fill, image: imageProvider),
                              ),
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
                          SizedBox(width: 5),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  store.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  store.address.city ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "Timings :  ${Dateutils.getFormattedTime(store.activeFrom)} - ${Dateutils.getFormattedTime(store.activeTill)}",
                                  style: TextStyle(
                                    color: CustomColors.alertRed,
                                    fontSize: 12.0,
                                  ),
                                )
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
              child: NoStoresWidget(),
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
