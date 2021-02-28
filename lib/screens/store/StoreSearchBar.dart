import 'package:chipchop_seller/db/models/products.dart';
import 'package:chipchop_seller/db/models/user_activity_tracker.dart';
import 'package:chipchop_seller/screens/products/ProductWidget.dart';
import 'package:chipchop_seller/screens/store/RecentProductsWidget.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

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
      snapshot = Products().getByNameForStore(key, widget.storeID);
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
                    return Column(children: [
                      ListTile(
                        title: Text(
                          "Your search results",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ProductWidget(
                            Products.fromJson(snapshot.data[index]),
                          );
                        },
                      ),
                    ]);
                  } else {
                    return Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "No Items found !!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: CustomColors.alertRed,
                                    fontSize: 15,
                                  ),
                                ),
                                Icon(
                                  Icons.sentiment_neutral,
                                  size: 30,
                                  color: CustomColors.alertRed,
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Search for another Items",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: CustomColors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
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
                  return Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: AsyncWidgets.asyncSearching(),
                    ),
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
