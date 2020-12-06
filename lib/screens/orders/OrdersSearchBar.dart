import 'package:chipchop_seller/db/models/order.dart';
import 'package:chipchop_seller/screens/orders/OrderWidget.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class OrdersSearchBar extends StatefulWidget {
  @override
  _OrdersSearchBarState createState() => new _OrdersSearchBarState();
}

class _OrdersSearchBarState extends State<OrdersSearchBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _searchController = TextEditingController();
  Future<List<Order>> snapshot;

  @override
  void initState() {
    super.initState();
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
          onFieldSubmitted: (searchKey) async {
            if (searchKey.trim().isNotEmpty) {
              setState(() {
                snapshot = Order().searchForOrder(searchKey);
              });
            }
          },
          decoration: InputDecoration(
            hintText: "Type Order ID",
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
              builder:
                  (BuildContext context, AsyncSnapshot<List<Order>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    _searchController.text != '') {
                  if (snapshot.data.isNotEmpty) {
                    return ListView.separated(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: snapshot.data.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(
                        color: CustomColors.black,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        Order _order = snapshot.data[index];
                        return OrderWidget(_order);
                      },
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "No Orders Found !!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CustomColors.alertRed,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "Try with different Order ID",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CustomColors.black,
                              fontSize: 16,
                            ),
                          )
                        ],
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
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: AsyncWidgets.asyncWaiting(),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
