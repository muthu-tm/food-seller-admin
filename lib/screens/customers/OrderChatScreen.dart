import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:chipchop_seller/db/models/chat_temp.dart';
import 'package:chipchop_seller/screens/app/TakePicturePage.dart';
import 'package:chipchop_seller/screens/utils/ImageView.dart';
import 'package:chipchop_seller/services/storage/image_uploader.dart';
import 'package:chipchop_seller/services/utils/DateUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/controllers/user/user_service.dart';
import '../utils/CustomColors.dart';

class OrderChatScreen extends StatefulWidget {
  final String orderUUID;
  final String buyerID;

  OrderChatScreen({Key key, @required this.orderUUID, @required this.buyerID})
      : super(key: key);

  @override
  State createState() =>
      OrderChatScreenState(orderUUID: orderUUID, buyerID: buyerID);
}

class OrderChatScreenState extends State<OrderChatScreen> {
  OrderChatScreenState(
      {Key key, @required this.orderUUID, @required this.buyerID});

  String orderUUID;
  String buyerID;

  List<DocumentSnapshot> listMessage = new List.from([]);
  int _limit = 10;
  final int _limitIncrement = 10;
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

  @override
  void dispose() {
    listScrollController.dispose();
    super.dispose();
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      isLoading = true;
    });

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    String filePath = 'order_chats/${cachedLocalUser.getID()}/$fileName.png';
    try {
      imageUrl =
          await Uploader().uploadImageFile(false, pickedFile.path, filePath);
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
      await oc.orderChatCreate(buyerID, orderUUID);

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
    if (document.data()['sender_type'] == 1) {
      // Right (my message)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              document.data()['msg_type'] == 0
                  // Text
                  ? Container(
                      child: Text(
                        document.data()['content'],
                        style: TextStyle(color: CustomColors.white),
                      ),
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      width: MediaQuery.of(context).size.width * 0.75,
                      decoration: BoxDecoration(
                          color: CustomColors.primary,
                          borderRadius: BorderRadius.circular(20.0)),
                      margin: EdgeInsets.only(bottom: 3.0),
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
                            imageUrl: document.data()['content'],
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
                              builder: (context) => ImageView(
                                url: document.data()['content'],
                              ),
                            ),
                          );
                        },
                        padding: EdgeInsets.all(0),
                      ),
                      margin: EdgeInsets.only(bottom: 3.0),
                    )
            ],
          ),

          // Time
          isLastMessageRight(index)
              ? Container(
                  child: Text(
                    DateUtils.formatDateTime(
                      DateTime.fromMillisecondsSinceEpoch(
                        (document.data()['created_at'] as Timestamp)
                            .millisecondsSinceEpoch,
                      ),
                    ),
                    style: TextStyle(
                        color: CustomColors.blue,
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic),
                  ),
                  margin: EdgeInsets.only(right: 10),
                )
              : Container()
        ],
      );
    } else {
      // Left (peer message)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              document.data()['msg_type'] == 0
                  ? Container(
                      child: Text(
                        document.data()['content'],
                        style: TextStyle(color: Colors.white),
                      ),
                      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                          color: CustomColors.grey,
                          borderRadius: BorderRadius.circular(20.0)),
                      margin: EdgeInsets.only(bottom: 3),
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
                            imageUrl: document.data()['content'],
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
                              builder: (context) => ImageView(
                                url: document.data()['content'],
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
                    DateUtils.formatDateTime(
                      DateTime.fromMillisecondsSinceEpoch(
                        (document.data()['created_at'] as Timestamp)
                            .millisecondsSinceEpoch,
                      ),
                    ),
                    style: TextStyle(
                        color: CustomColors.blue,
                        fontSize: 12.0,
                        fontStyle: FontStyle.italic),
                  ),
                  margin: EdgeInsets.only(left: 10.0),
                )
              : Container()
        ],
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['sender_type'] != 0 &&
            listMessage[index - 1].data()['from'] == cachedLocalUser.getID()) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['sender_type'] != 1 &&
            listMessage[index - 1].data()['from'] != cachedLocalUser.getID()) ||
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
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Container(child: buildListMessage()),
          // Input content
          Positioned(bottom: 0, left: 0, child: buildInput()),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
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
              color: CustomColors.primary.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          InkWell(
            onTap: () async {
              String tempPath = (await getTemporaryDirectory()).path;
              String filePath = '$tempPath/chipchop_image.png';
              if (File(filePath).existsSync()) await File(filePath).delete();
              await _showCamera(filePath);
            },
            child: Container(
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.camera_alt,
                size: 25,
                color: CustomColors.black,
              ),
              color: CustomColors.white,
            ),
          ),
          InkWell(
            onTap: getImage,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.image,
                size: 25,
                color: CustomColors.black,
              ),
              color: CustomColors.white,
            ),
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
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: () => onSendMessage(textEditingController.text, 0),
              color: CustomColors.primary,
            ),
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: CustomColors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

  Future<void> _showCamera(String filePath) async {
    List<CameraDescription> cameras = await availableCameras();
    CameraDescription camera = cameras.first;

    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePicturePage(
          camera: camera,
          path: filePath,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        isLoading = true;
      });
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = 'order_chats/${cachedLocalUser.getID()}/$fileName.png';
      try {
        imageUrl =
            await Uploader().uploadImageFile(true, result.toString(), filePath);
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
  }

  Widget buildListMessage() {
    return StreamBuilder(
      stream: ChatTemplate()
          .streamOrderChats(widget.buyerID, widget.orderUUID, _limit),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CustomColors.lightGrey),
            ),
          );
        } else {
          if (snapshot.data.docs.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(10.0),
              child: Container(
                alignment: AlignmentDirectional.center,
                child: Text(
                  "No Chats Found !!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: CustomColors.grey, fontSize: 16),
                ),
              ),
            );
          }
          listMessage.clear();
          listMessage.addAll(snapshot.data.docs);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) =>
                      buildItem(index, snapshot.data.docs[index]),
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  controller: listScrollController,
                ),
              ),
              SizedBox(
                height: 50,
              )
            ],
          );
        }
      },
    );
  }
}
