import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../chatWidget.dart';
import '../constants.dart';

class Chat extends StatelessWidget {
  final String peerId;
  final String peerAvatar;
  final String peerName;
  final String currentUserId;
  static const String id = "chat";

  Chat(
      {Key key,
      @required this.currentUserId,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.peerName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        title: Text(peerName),
        backgroundColor: themeColor,
      ),
      body: new _ChatScreen(
        currentUserId: currentUserId,
        peerId: peerId,
        peerAvatar: peerAvatar,
      ),
    );
  }
}

class _ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String currentUserId;

  _ChatScreen(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.currentUserId})
      : super(key: key);

  @override
  State createState() =>
      new _ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

class _ChatScreenState extends State<_ChatScreen> {
  _ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar});

  String peerId;
  String peerAvatar;
  String id;

  var listMessage;
  String groupChatId;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    id = widget.currentUserId ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'chattingWith': peerId});

    setState(() {});
  }

  Future getImage(int index) async {
    PickedFile selectedFile;

    if (kIsWeb) {
      //selectedFile=await ImagePicker.platform.pickImage(source: ImageSource.gallery);
      selectedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    } else {
      if (index == 0)
        selectedFile =
            await ImagePicker().getImage(source: ImageSource.gallery);
      else
        selectedFile = await ImagePicker().getImage(source: ImageSource.camera);

      //imageFile =File(selectedFile.path);

    }

    if (selectedFile != null) {
      setState(() {
        //orFile=selectedFile;
        isLoading = true;
      });
      uploadFile(selectedFile);
    }
  }

  Future uploadFile(PickedFile orFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference reference =
        firebase_storage.FirebaseStorage.instance.ref().child(fileName);

    File compressedFile;
    if (!kIsWeb)
      compressedFile = await FlutterNativeImage.compressImage(orFile.path,
          quality: 80, percentage: 90);

    try {
      firebase_storage.UploadTask uploadTask;

      final metadata = firebase_storage.SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': orFile.path});

      if (kIsWeb)
        uploadTask = reference.putData(await orFile.readAsBytes(), metadata);
      else
        uploadTask = reference.putFile(compressedFile);

      firebase_storage.TaskSnapshot storageTaskSnapshot = await uploadTask;

      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
        imageUrl = downloadUrl;
        setState(() {
          isLoading = false;
          onSendMessage(imageUrl, 1);
        });
      }, onError: (err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
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
          Column(
            children: <Widget>[
              // List of messages
              ChatWidget.widgetChatBuildListMessage(groupChatId, listMessage,
                  widget.currentUserId, peerAvatar, listScrollController),

              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
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
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: () => getImage(0),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Visibility(
            visible: !kIsWeb,
            child: Material(
              child: new Container(
                margin: new EdgeInsets.symmetric(horizontal: 1.0),
                child: new IconButton(
                  icon: new Icon(Icons.camera_alt),
                  onPressed: () => getImage(1),
                  color: primaryColor,
                ),
              ),
              color: Colors.white,
            ),
          ),
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }
}
