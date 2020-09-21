import 'package:chipchop_seller/db/models/chipchop_products.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  AddProduct(this.product);

  final ChipChopProducts product;
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> pImages = [];
  String pName = "";
  List<String> keywords = [];
  bool validKeyword = true;

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      this.pImages = widget.product.productImages;
      this.keywords = widget.product.keywords;
      this.pName = widget.product.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: CustomColors.sellerLightGrey,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: Search());
            },
            icon: Icon(Icons.search),
          )
        ],
        backgroundColor: CustomColors.sellerGreen,
        title: Text("Add Products"),
      ),
      body: SingleChildScrollView(
        child: getBody(context),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Container(
              color: CustomColors.sellerWhite,
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          child: Text("Add Image"),
                          decoration: BoxDecoration(
                            color: CustomColors.sellerGrey,
                            border: Border.all(
                              width: 1,
                              style: BorderStyle.none,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          child: Text("Add Image"),
                          decoration: BoxDecoration(
                            color: CustomColors.sellerGrey,
                            border: Border.all(
                              width: 1,
                              style: BorderStyle.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          child: Text("Add Image"),
                          decoration: BoxDecoration(
                            color: CustomColors.sellerGrey,
                            border:
                                Border.all(width: 1, style: BorderStyle.none),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          child: Text("Add Image"),
                          decoration: BoxDecoration(
                            color: CustomColors.sellerGrey,
                            border:
                                Border.all(width: 1, style: BorderStyle.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Search extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  ChipChopProducts selectedResult;

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          print("Product clicked");
        },
        child: Text(selectedResult != null ? selectedResult.name : ""),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<ChipChopProducts>>(
      future: ChipChopProducts().searchByKeyword(query),
      builder: (BuildContext context,
          AsyncSnapshot<List<ChipChopProducts>> snapshot) {
        Widget children;

        if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {
            children = ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    snapshot.data[index].name,
                  ),
                  leading: query.isEmpty ? Icon(Icons.access_time) : SizedBox(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProduct(snapshot.data[index]),
                        settings: RouteSettings(name: '/settings/products/add'),
                      ),
                    );

                    // print("Product onclick event");
                    // selectedResult = snapshot.data[index];
                    // showResults(context);
                  },
                );
              },
            );
          } else {
            children = Container(
              height: 90,
              child: Column(
                children: <Widget>[
                  Spacer(),
                  Text(
                    "No Products Found",
                    style: TextStyle(
                      color: CustomColors.sellerAlertRed,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(
                    flex: 2,
                  ),
                  Text(
                    "Sorry. Please Try Again Later!",
                    style: TextStyle(
                      color: CustomColors.sellerBlue,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Spacer(),
                ],
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
