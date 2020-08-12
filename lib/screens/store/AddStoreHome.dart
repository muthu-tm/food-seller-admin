import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';

class AddNewStoreHome extends StatefulWidget {
  @override
  _AddNewStoreHomeState createState() => _AddNewStoreHomeState();
}

class _AddNewStoreHomeState extends State<AddNewStoreHome> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Store"),
        backgroundColor: CustomColors.sellerPurple,
      ),
      body: SingleChildScrollView(
        child: Container(

        ),
      ),
    );
  }
}