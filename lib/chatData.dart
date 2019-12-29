import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo_view/photo_view.dart';
import 'constants.dart';
import 'screens/chat.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';

class ChatData {
  static String appName = "";

  static Future<Null> openDialog(BuildContext context) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: themeColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: Colors.white70,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white70,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  static Future<Null> handleSignOut(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }

  static Future<bool> authUsersGoogle() async {
    final String dbUser = "users";
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser logInUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    if (logInUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('$dbUser')
          .where('id', isEqualTo: logInUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance
            .collection('$dbUser')
            .document(logInUser.uid)
            .setData({
          'nickname': logInUser.displayName,
          'photoUrl': logInUser.photoUrl,
          'id': logInUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null
        });
      }
      //  else {
      //      return true;
      //      }
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> isSignedIn() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    bool isLoggedIn = await googleSignIn.isSignedIn();
    return isLoggedIn;
  }

  static Widget userListStack(String currentUserId, BuildContext context) {
    return Stack(
      children: <Widget>[
        // List
        Container(
          child: StreamBuilder(
            stream: Firestore.instance.collection('users').snapshots(),
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
                  itemBuilder: (context, index) => userListbuildItem(
                      context, currentUserId, snapshot.data.documents[index]),
                  itemCount: snapshot.data.documents.length,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  static Widget userListbuildItem(
      BuildContext context, String currentUserId, DocumentSnapshot document) {
    print('firebase ' + document['id']);
    print(currentUserId);
    if (document['id'] == currentUserId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: document['photoUrl'] != null
                    ? (Image.network(
                        document['photoUrl'],
                        height: 50.0,
                        width: 50.0,
                      ))
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: colorPrimaryDark,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Nickname: ${document['nickname']}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                          currentUserId: currentUserId,
                          peerId: document.documentID,
                          peerName: document['nickname'],
                          peerAvatar: document['photoUrl'],
                        )));
          },
          color: viewBg,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }

  static Widget widgetLoginScreen(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Icon(
                    Icons.message,
                    color: Colors.greenAccent,
                  ),
                  height: 25.0,
                ),
                Text(
                  appName,
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48.0,
          ),
          Center(
            child: FlatButton(
                onPressed: () => authUser(context),
                child: Text(
                  'SIGN IN WITH GOOGLE',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                color: Color(0xffdd4b39),
                highlightColor: Color(0xffff7f7f),
                splashColor: Colors.transparent,
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
          ),
        ],
      ),
    );
  }

  // static Future<void> getLoginUser(BuildContext context) async {
  //   final GoogleSignIn googleSignIn = GoogleSignIn();
  //   final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //   if (await isSignedIn() == true) {
  //     GoogleSignInAccount googleUser = await googleSignIn.signIn();
  //     GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  //     final AuthCredential credential = GoogleAuthProvider.getCredential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final FirebaseUser logInUser =
  //         (await firebaseAuth.signInWithCredential(credential)).user;

  //     // return ChatData.userListStack(logInUser.uid,context);
  //     Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) =>
  //                 DashboardScreen(currentUserId: logInUser.uid)));
  //   } else {
  //     // return ChatData.widgetLoginScreen(context);
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (context) => LoginScreen()));
  //   }
  // }

  static void authUser(BuildContext context) async {
    bool isValidUser = await ChatData.authUsersGoogle();

    if (isValidUser) {
      if (await ChatData.isSignedIn()) {
        ChatData.checkUserLogin(context);
      }
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
    }
  }

  static init(String applicationName, BuildContext context) {
    appName = applicationName;
    startTime(context);
  }

  static Widget getAppBar() {
    return AppBar(
      leading: null,
      title: Text(appName),
      backgroundColor: themeColor,
    );
  }

  static checkUserLogin(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    if (await isSignedIn() == true) {
      GoogleSignInAccount googleUser = await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser logInUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      //return ChatData.userListStack(logInUser.uid, context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DashboardScreen(currentUserId: logInUser.uid)));
    } else {
      //return ChatData.widgetLoginScreen(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  static Widget widgetWelcomeScreen(BuildContext context) {
    // return
    // FutureBuilder<Widget>(
    //         future: ChatData.widgetDynamic(context),
    //          builder: (BuildContext context, AsyncSnapshot snapshot) {

    //               if(snapshot.hasData){
    //                     if(snapshot.data!=null){
    //                       return snapshot.data;
    //                     }

    //                 }
    //                     else
    //                     {
    //                       return Container();
    //                     }

    //         },

    //   );
    return Center(
      child: Container(
          child: Text(
        appName,
        style: TextStyle(fontSize: 28),
      )),
    );
  }

  static Widget widgetFullPhoto(BuildContext context, String url) {
    return Container(child: PhotoView(imageProvider: NetworkImage(url)));
  }

  static startTime(BuildContext context) async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, checkUserLogin(context));
  }
}
