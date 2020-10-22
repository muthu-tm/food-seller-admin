import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/store/StoreItemWidget.dart';
import 'package:chipchop_seller/screens/utils/CarouselIndicatorSlider.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewStoreScreen extends StatelessWidget {
  ViewStoreScreen(this.store);

  final Store store;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.lightGrey,
      appBar: AppBar(
        title: Text(
          store.name,
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.blue,
        onPressed: () {},
        label: Text("Order NOW"),
        icon: Icon(FontAwesomeIcons.solidSmile),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // StoreSearchBar(),
            Padding(
              padding: EdgeInsets.all(10),
              child: CarouselIndicatorSlider(store.getStoreImages()),
            ),
            Expanded(
              child: StoreItemWidget(store),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getImages() {
    List<Widget> images = [];

    for (var item in store.getStoreImages()) {
      images.add(
        CachedNetworkImage(
          imageUrl: item,
          imageBuilder: (context, imageProvider) => Image(
            height: 150,
            width: double.infinity,
            fit: BoxFit.contain,
            image: imageProvider,
          ),
          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
            child: SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(
                  value: downloadProgress.progress,
                  valueColor: AlwaysStoppedAnimation(CustomColors.blue),
                  strokeWidth: 2.0),
            ),
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.error,
            size: 35,
          ),
          fadeOutDuration: Duration(seconds: 1),
          fadeInDuration: Duration(seconds: 2),
        ),
      );
    }

    return images;
  }
}
