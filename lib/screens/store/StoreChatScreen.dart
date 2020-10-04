import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chipchop_seller/db/models/chat_temp.dart';
import 'package:chipchop_seller/screens/orders/ChatImageView.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/controllers/user/user_service.dart';
import '../utils/CustomColors.dart';

class StoreChatScreen extends StatefulWidget {
  final String storeID;
  final String custID;

  StoreChatScreen({Key key, @required this.storeID, @required this.custID})
      : super(key: key);

  @override
  State createState() => StoreChatScreenState(storeID: storeID, custID: custID);
}

class StoreChatScreenState extends State<StoreChatScreen> {
  StoreChatScreenState(
      {Key key, @required this.storeID, @required this.custID});

  String storeID;
  String custID;

  List<DocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  final int _limitIncrement = 20;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  String imageUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        print("reach the top");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListener);

    isLoading = false;
    imageUrl = '';
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    imageFile = File(pickedFile.path);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = 'store_chats/$storeID/$fileName.png';
      StorageReference reference =
          FirebaseStorage.instance.ref().child(filePath);
      StorageUploadTask uploadTask = reference.putFile(imageFile);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
      await onSendMessage(imageUrl, 1);
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    }
  }

  Future<void> onSendMessage(String content, int type) async {
    // type: 0 = text, 1 = image
    if (content.trim() != '') {
      textEditingController.clear();

      ChatTemplate oc = ChatTemplate();
      oc.content = content;
      oc.messageType = type;
      oc.senderType = 1; // Seller
      await oc.storeChatCreate(storeID, custID);

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Colors.grey,
          textColor: Colors.white);
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document.data['sender_type'] == 1) {
      // Right (my message)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: <Widget>[
              document.data['msg_type'] == 0
                  // Text
                  ? Container(
                      child: Text(
                        document.data['content'],
                        style: TextStyle(color: CustomColors.white),
                      ),
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      width: 200.0,
                      decoration: BoxDecoration(
                          color: CustomColors.grey,
                          borderRadius: BorderRadius.circular(8.0)),
                      margin: EdgeInsets.only(bottom: 5.0, right: 10.0),
                    )
                  : Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    CustomColors.grey),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: CustomColors.grey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document.data['content'],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatImageView(
                                url: document.data['content'],
                              ),
                            ),
                          );
                        },
                        padding: EdgeInsets.all(0),
                      ),
                      margin: EdgeInsets.only(bottom: 5.0, right: 10.0),
                    )
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),

          // Time
          isLastMessageRight(index)
              ? Container(
                  child: Text(
                    DateFormat('dd MMM kk:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(
                        (document.data['created_at'] as Timestamp)
                            .millisecondsSinceEpoch,
                      ),
                    ),
                    style: TextStyle(
                        color: CustomColors.blue,
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic),
                  ),
                  margin: EdgeInsets.only(right: 20),
                )
              : Container()
        ],
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Material(
                  child: Icon(
                    Icons.headset_mic,
                    size: 35,
                    color: CustomColors.grey,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(18.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                ),
                document.data['msg_type'] == 0
                    ? Container(
                        child: Text(
                          document.data['content'],
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: CustomColors.green,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : Container(
                        child: FlatButton(
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      CustomColors.grey),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: CustomColors.grey,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Material(
                                child: Image.asset(
                                  'images/img_not_available.jpeg',
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                              imageUrl: document.data['content'],
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatImageView(
                                  url: document.data['content'],
                                ),
                              ),
                            );
                          },
                          padding: EdgeInsets.all(0),
                        ),
                        margin: EdgeInsets.only(left: 10.0),
                      )
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                        DateTime.fromMillisecondsSinceEpoch(
                          (document.data['created_at'] as Timestamp)
                              .millisecondsSinceEpoch,
                        ),
                      ),
                      style: TextStyle(
                          color: CustomColors.blue,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data['from'] == cachedLocalUser.getID()) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data['from'] != cachedLocalUser.getID()) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat",
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.lightGrey, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  // List of messages
                  buildListMessage(),
                  // Input content
                  buildInput(),
                ],
              ),
            ),
          ),

          // Loading
          buildLoading()
        ],
      ),
    );
  }

  Widget buildLoading() {
    return Center(
      child: isLoading
          ? Container(
              height: 100,
              width: 100,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(CustomColors.grey),
                ),
              ),
              color: CustomColors.blueGreen.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: CustomColors.blueGreen,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, 0);
                },
                style: TextStyle(color: CustomColors.black, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: CustomColors.grey),
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: CustomColors.blueGreen,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: CustomColors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Container(
      child: StreamBuilder(
        stream: ChatTemplate().streamStoreChats(storeID, custID, _limit),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(CustomColors.grey),
              ),
            );
          } else {
            listMessage.addAll(snapshot.data.documents);
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              shrinkWrap: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }
}
