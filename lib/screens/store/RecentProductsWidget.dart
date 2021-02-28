import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/db/models/user_activity_tracker.dart';
import 'package:chipchop_seller/screens/products/ProductDetailsScreen.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RecentProductsWidget extends StatelessWidget {
  RecentProductsWidget(this.storeID);
  final String storeID;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: storeID.trim().isEmpty
          ? UserActivityTracker().getRecentActivity([2])
          : UserActivityTracker().getRecentActivityForStore(storeID, [2]),
      builder: (context, AsyncSnapshot<List<UserActivityTracker>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isEmpty) {
            return Container();
          } else {
            return Column(
              children: [
                ListTile(
                  title: Text(
                    "Recently Viewed Products",
                    style: TextStyle(
                        color: CustomColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Container(
                    height: 160,
                    child: Stack(
                      children: [
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListView.builder(
                            primary: true,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.length,
                            padding: EdgeInsets.all(5),
                            itemBuilder: (BuildContext context, int index) {
                              UserActivityTracker _ua = snapshot.data[index];
                              return Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Container(
                                  width: 130,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: InkWell(
                                    onTap: () async {
                                      CustomDialogs.actionWaiting(context);
                                      Products _p = await Products()
                                          .getByProductID(_ua.productID);

                                      if (_p != null) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetailsScreen(_p),
                                            settings: RouteSettings(
                                                name: '/store/products'),
                                          ),
                                        );
                                      } else {
                                        Navigator.pop(context);
                                        Fluttertoast.showToast(
                                            msg:
                                                'Error, Unable to Load Product!',
                                            backgroundColor:
                                                CustomColors.alertRed,
                                            textColor: CustomColors.white);
                                      }
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: CachedNetworkImage(
                                            imageUrl: _ua.getImage(),
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              width: 130,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                shape: BoxShape.rectangle,
                                                image: DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image: imageProvider),
                                              ),
                                            ),
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Container(
                                              width: 130,
                                              height: 100,
                                              alignment: Alignment.center,
                                              child: SizedBox(
                                                width: 50,
                                                height: 50,
                                                child:
                                                    CircularProgressIndicator(
                                                        value: downloadProgress
                                                            .progress),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              width: 130,
                                              height: 100,
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.error,
                                                size: 35,
                                              ),
                                            ),
                                            fadeOutDuration:
                                                Duration(seconds: 1),
                                            fadeInDuration:
                                                Duration(seconds: 2),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            _ua.productName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: CustomColors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        } else {
          return Container();
        }
      },
    );
  }
}
