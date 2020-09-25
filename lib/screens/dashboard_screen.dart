import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../chatDB.dart';
import '../chatData.dart';
import '../chatWidget.dart';
import '../constants.dart';

List<dynamic> friendList = [];

class DashboardScreen extends StatefulWidget {
  static const String id = "dashboard_screen";
  final String currentUserId;
  DashboardScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _DashboardScreenState({Key key});

  bool isLoading = false;
  bool addNewFriend = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  final friendController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getFriendList();
  }

  Future<String> getFriendList() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
        setState(() {
          friendList = documentSnapshot.data()['friends'];
          print('Document data:' + friendList[0]);
        });
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatWidget.getAppBar(),
      backgroundColor: Colors.white,
      body: WillPopScope(
        child: showFriendList(widget.currentUserId),
        onWillPop: onBackPress,
      ),
    );
  }

  Future<bool> onBackPress() {
    ChatData.openDialog(context);
    return Future.value(false);
  }

  Widget showAddFriend() {
    return Container(
      child: RaisedButton(
        child: Text('Add New Friend'),
        onPressed: _showAddFriendDialog,
      ),
    );
  }

  _showAddFriendDialog() async {
    await showDialog<String>(
      context: context,
      child: new _SystemPadding(
        child: new AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  autofocus: true,
                  controller: friendController,
                  decoration: new InputDecoration(
                      labelText: 'user Email', hintText: 'ankeshkumar@live.in'),
                ),
              )
            ],
          ),
          actions: <Widget>[
            new FlatButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            new FlatButton(
                child: const Text('Add'),
                onPressed: () {
                  print(friendController.text);
                  //if(friendController.text!='')
                  _addNewFriend();
                })
          ],
        ),
      ),
    );
  }

  void _addNewFriend() {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: friendController.text)
        .get()
        .then((value) {
      if (value.docs.length > 0) {
        value.docs.forEach((result) {
          bool alreadyExist = false;
          for (var fr in friendList) {
            if (fr == result.data()['userId']) alreadyExist = true;
          }
          if (alreadyExist == true) {
            showToast("already friend", true);
          } else {
            friendList.add(result.data()['userId']);
            FirebaseFirestore.instance
                .collection('users')
                .doc(widget.currentUserId)
                .update({"friends": friendList}).whenComplete(
                    () => showToast("friend successfully added", false));
          }
          friendController.text = "";
          Navigator.pop(context);
        });
      } else {
        showToast("No user found with this email.", true);
        Navigator.pop(context);
      }
    });
  }

  showToast(var text, bool error) {
    if (error == false) getFriendList();

    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: error ? Colors.red : Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget showFriendList(var currentUserId) {
    return Stack(
      children: <Widget>[
        // List
        Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              showAddFriend(),
            ],
          ),
        ),
        (friendList.length > 0)
            ? Container(
                margin: EdgeInsets.fromLTRB(0, 35, 0, 0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(ChatDBFireStore.getDocName())
                      .where('userId', whereIn: friendList)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            ChatWidget.userListbuildItem(context, currentUserId,
                                snapshot.data.documents[index]),
                        itemCount: snapshot.data.documents.length,
                      );
                    }
                  },
                ),
              )
            : Container()
      ],
    );
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.viewInsets / 2,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}
