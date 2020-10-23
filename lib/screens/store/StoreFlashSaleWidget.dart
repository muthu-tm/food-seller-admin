import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class StoreFlashSaleWidget extends StatefulWidget {
  StoreFlashSaleWidget(this.storeID);

  final String storeID;
  @override
  _StoreFlashSaleWidgetState createState() => _StoreFlashSaleWidgetState();
}

class _StoreFlashSaleWidgetState extends State<StoreFlashSaleWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            "Flash Sale not started YET!",
            style: TextStyle(
              
              color: CustomColors.alertRed,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Coming SOON...",
            style: TextStyle(
              
              color: CustomColors.grey,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
