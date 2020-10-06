import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class SearchOptionsRadio extends StatelessWidget {
  SearchOptionsRadio(this._item, this._color);

  final CustomRadioModel _item;
  final Color _color;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Container(
        height: 40.0,
        width: MediaQuery.of(context).size.width * 0.33,
        child: new Center(
          child: new Text(_item.buttonText,
              style: new TextStyle(
                  fontFamily: "Georgia",
                  color: _item.isSelected
                      ? CustomColors.white
                      : CustomColors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0)),
        ),
        decoration: new BoxDecoration(
          color: _item.isSelected ? _color : CustomColors.lightGrey,
          border: new Border.all(
              width: 1.0,
              color: _item.isSelected
                  ? CustomColors.blueGreen
                  : CustomColors.grey),
          borderRadius: const BorderRadius.all(const Radius.circular(2.0)),
        ),
      ),
    );
  }
}

class CustomRadioModel {
  bool isSelected;
  final String buttonText;
  final String text;

  CustomRadioModel(this.isSelected, this.buttonText, this.text);
}