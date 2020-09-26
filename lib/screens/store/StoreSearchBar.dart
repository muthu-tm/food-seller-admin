import 'package:flutter/material.dart';

import '../utils/CustomColors.dart';

class StoreSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Theme(
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              filled: true,
              prefixIcon: Icon(Icons.search),
              fillColor: CustomColors.sellerWhite,
              hintStyle: TextStyle(color: CustomColors.sellerGrey),
              hintText: "What would your like to buy?",
            ),
            autofocus: false,
          ),
          data: Theme.of(context).copyWith(
            primaryColor: CustomColors.sellerGrey,
          )),
    );
  }
}
