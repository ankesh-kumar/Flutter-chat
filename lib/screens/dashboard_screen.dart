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
import 'chat.dart';

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
          print('Document datas:' + friendList[0]);
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
        builder: (context) {
          return _SystemPadding(
            child: new AlertDialog(
              contentPadding: const EdgeInsets.all(16.0),
              content: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new TextField(
                      autofocus: true,
                      controller: friendController,
                      decoration: new InputDecoration(
                          labelText: 'user Email',
                          hintText: 'ankeshkumar@live.in'),
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                new TextButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                new TextButton(
                    child: const Text('Add'),
                    onPressed: () {
                      print(friendController.text);
                      //if(friendController.text!='')
                      _addNewFriend();
                    })
              ],
            ),
          );
        });
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
                child: StreamBuilder<QuerySnapshot>(
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
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading");
                    }

                    return new ListView(
                        children:
                            snapshot.data.docs.map((DocumentSnapshot document) {
                      return new ListTile(
                        leading: Material(
                          child: document.data()['photoUrl'] != null
                              ? ChatWidget.widgetShowImages(
                                  document.data()['photoUrl'], 50)
                              : Icon(
                                  Icons.account_circle,
                                  size: 50.0,
                                  color: colorPrimaryDark,
                                ),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        title: new Text(document.data()['nickname']),
                        subtitle: new Text(document.data()['nickname']),
                        trailing: ConstrainedBox(
                          constraints: new BoxConstraints(
                            minHeight: 10.0,
                            minWidth: 10.0,
                            maxHeight: 30.0,
                            maxWidth: 30.0,
                          ),
                          child: new DecoratedBox(
                            decoration: new BoxDecoration(
                                color: document.data()['online'] == 'online'
                                    ? Colors.greenAccent
                                    : Colors.transparent),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Chat(
                                        currentUserId: currentUserId,
                                        peerId: document.data()['userId'],
                                        peerName: document.data()['nickname'],
                                        peerAvatar: document.data()['photoUrl'],
                                      )));
                        },
                      );
                    }).toList());
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
