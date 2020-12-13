import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/db/models/user_activity_tracker.dart';
import 'package:chipchop_seller/screens/products/ProductDetailsScreen.dart';
import 'package:chipchop_seller/screens/products/ProductWidget.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StoreSearchBar extends StatefulWidget {
  StoreSearchBar(this.storeID, this.storeName);

  final String storeID;
  final String storeName;
  @override
  _StoreSearchBarState createState() => new _StoreSearchBarState();
}

class _StoreSearchBarState extends State<StoreSearchBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _searchController = TextEditingController();
  Future<List<Map<String, dynamic>>> snapshot;

  @override
  void initState() {
    super.initState();
  }

  void _submit(String key) {
    setState(() {
      snapshot = Products().getByNameRange(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: CustomColors.primary,
        centerTitle: true,
        titleSpacing: 0.0,
        title: TextFormField(
          controller: _searchController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          textCapitalization: TextCapitalization.sentences,
          style: TextStyle(
            color: CustomColors.black,
          ),
          onFieldSubmitted: (searchKey) {
            if (searchKey.trim().isNotEmpty) {
              UserActivityTracker _activity = UserActivityTracker();
              _activity.keywords = searchKey;
              _activity.type = 4; // 4 - product search
              _activity.create();

              _submit(searchKey);
            }
          },
          decoration: InputDecoration(
            hintText: "Type Keyword",
            hintStyle: TextStyle(color: CustomColors.black),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: CustomColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.close,
              size: 25.0,
              color: CustomColors.alertRed,
            ),
            onPressed: () async {
              setState(() {
                _searchController.text = "";
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: snapshot,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    _searchController.text != '') {
                  if (snapshot.data.isNotEmpty) {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ProductWidget(
                          Products.fromJson(snapshot.data[index]),
                        );
                      },
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "No Results Found",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CustomColors.alertRed,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(),
                        Text(
                          "Try with different KEYWORDS..",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CustomColors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    );
                  }
                } else if (snapshot.hasError) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: AsyncWidgets.asyncError(),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: AsyncWidgets.asyncWaiting(),
                  );
                } else {
                  return RecentProductsWidget(widget.storeID);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

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
                                                name: '/products'),
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
                                                CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress),
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
