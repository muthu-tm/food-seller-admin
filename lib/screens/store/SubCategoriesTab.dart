import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/product_sub_categories.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/store/SubCategoriesProductScreen.dart';
import 'package:chipchop_seller/screens/utils/AsyncWidgets.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class SubCategoriesTab extends StatelessWidget {
  SubCategoriesTab(this.categoryID, this.store);

  final String categoryID;
  final Store store;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ProductSubCategories().getSubCategoriesForCategoryWithIDs(
          categoryID, store.availProductSubCategories),
      builder: (context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: AsyncWidgets.asyncWaiting(),
              ),
            );
          default:
            if (snapshot.hasError)
              return Center(
                child: Column(
                  children: AsyncWidgets.asyncError(),
                ),
              );
            else
              return GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 5,
                shrinkWrap: true,
                mainAxisSpacing: 10,
                padding: EdgeInsets.all(1.0),
                children: List<Widget>.generate(
                  snapshot.data.length,
                  (index) {
                    ProductSubCategories _sc = snapshot.data[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubCategoriesProductsScreen(
                                store.uuid,
                                store.name,
                                categoryID,
                                _sc.uuid,
                                _sc.name),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          color: CustomColors.white,
                        ),
                        alignment: Alignment.centerLeft,
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              CachedNetworkImage(
                                imageUrl: _sc.getSubCategoryImage(),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: 75,
                                  height: 75,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    shape: BoxShape.rectangle,
                                    image: DecorationImage(
                                        fit: BoxFit.fill, image: imageProvider),
                                  ),
                                ),
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) => Center(
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
                              ),
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  _sc.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: CustomColors.black,
                                      fontFamily: 'Roboto-Light.ttf',
                                      fontSize: 12),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
        }
      },
    );
  }
}
