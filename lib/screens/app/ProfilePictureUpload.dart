import 'dart:io';
import 'package:chipchop_seller/screens/home/HomeScreen.dart';
import 'package:chipchop_seller/services/utils/constants.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chipchop_seller/screens/app/TakePicturePage.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomDialogs.dart';
import 'package:chipchop_seller/services/storage/image_uploader.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePictureUpload extends StatefulWidget {
  ProfilePictureUpload(this.type, this.picPath, this.fileName, this.id);

  final int type; // 0 - Seller, 1 - Store
  final String picPath;
  final String fileName;
  final int id;

  @override
  _ProfilePictureUploadState createState() => _ProfilePictureUploadState();
}

class _ProfilePictureUploadState extends State<ProfilePictureUpload> {
  String selectedImagePath = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        height: 350,
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(),
            Text(
              widget.type == 0 ? "Profile Photo" : "Store Profile",
              style: TextStyle(
                  color: CustomColors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Spacer(),
            selectedImagePath == ""
                ? Container(
                    height: 250,
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        widget.picPath == ""
                            ? Container(
                                width: 120,
                                height: 120,
                                margin: EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: CustomColors.primary,
                                      style: BorderStyle.solid,
                                      width: 2.0),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 45.0,
                                  color: CustomColors.primary,
                                ),
                              )
                            : CircleAvatar(
                                radius: 70.0,
                                backgroundImage: NetworkImage(widget.picPath),
                                backgroundColor: Colors.transparent,
                              ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: FlatButton(
                                padding: EdgeInsets.all(5),
                                color: CustomColors.primary,
                                child: Text(
                                  "Select Image",
                                  style: TextStyle(
                                      color: CustomColors.blue,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                                onPressed: () {
                                  _previewImage(ImageSource.gallery);
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: FlatButton(
                                padding: EdgeInsets.all(5),
                                color: CustomColors.alertRed.withOpacity(0.5),
                                child: Text(
                                  "Take Picture",
                                  style: TextStyle(
                                      color: CustomColors.black,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                                onPressed: () async {
                                  String tempPath =
                                      (await getTemporaryDirectory()).path;
                                  String filePath =
                                      '$tempPath/chipchop_image.png';
                                  if (File(filePath).existsSync())
                                    await File(filePath).delete();
                                  await _showCamera(filePath);
                                },
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                  )
                : Container(
                    height: 250,
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Spacer(),
                        CircleAvatar(
                          radius: 70.0,
                          backgroundImage: Image.memory(
                                  File(selectedImagePath).readAsBytesSync())
                              .image,
                          backgroundColor: Colors.transparent,
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: FlatButton(
                                padding: EdgeInsets.all(5),
                                color: CustomColors.primary,
                                child: Text(
                                  "Change",
                                  style: TextStyle(
                                      color: CustomColors.blue,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedImagePath = "";
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5),
                              child: FlatButton(
                                padding: EdgeInsets.all(5),
                                color: CustomColors.primary,
                                child: Text(
                                  "Upload",
                                  style: TextStyle(
                                      color: CustomColors.blue,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.start,
                                ),
                                onPressed: () async {
                                  await _uploadImage(selectedImagePath);
                                },
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        FlatButton(
                          color: CustomColors.alertRed,
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                color: CustomColors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.start,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
            Spacer(),
          ],
        ),
      ),
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
                )));
    if (result != null) {
      setState(() {
        selectedImagePath = result.toString();
      });
    }
  }

  Future _previewImage(ImageSource source) async {
    PickedFile selected = await ImagePicker().getImage(source: source);
    if (selected != null) {
      setState(() {
        selectedImagePath = selected.path.toString();
      });
    }
  }

  Future _uploadImage(String path) async {
    if (path != null) {
      File imageFile = await Uploader().fixExifRotation(path);
      CustomDialogs.actionWaiting(context);
      await Uploader().uploadImage(
        widget.type,
        widget.type == 0 ? seller_profile_folder : store_profile_folder,
        imageFile,
        widget.fileName,
        widget.id,
        () {
          if (widget.type == 0) {
            Navigator.pop(context);
            Navigator.pop(context);
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) => HomeScreen(),
              ),
              (Route<dynamic> route) => false,
            );
          }
        },
      );
    }
  }
}
