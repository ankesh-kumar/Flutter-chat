import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'chatDB.dart';
import 'chatWidget.dart';
import 'constants.dart';
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
                    ChatWidget.widgetShowText(
                        'Are you sure to exit app?', '', ''),
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
                    ChatWidget.widgetShowText('Cancel', '', ''),
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
                    ChatWidget.widgetShowText('Yes', '', ''),
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
    await Firebase.initializeApp();
    final GoogleSignIn googleSignIn = GoogleSignIn();

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
  }

  static Future<bool> authUsersGoogle() async {
    await Firebase.initializeApp();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential logInUser =
        await firebaseAuth.signInWithCredential(credential);

    if (logInUser != null) {
      // Check is already sign up
      await ChatDBFireStore.checkUserExists(firebaseAuth.currentUser);
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

  static void authUser(BuildContext context) async {
    bool isValidUser = await ChatData.authUsersGoogle();
    print('isValid' + isValidUser.toString());
    if (isValidUser) {
      if (await ChatData.isSignedIn()) {
        //print('sign in signin');
        ChatData.checkUserLogin(context);
      }
    } else {
      print('sign in fail');
      Fluttertoast.showToast(msg: "Sign in fail");
    }
  }

  static init(String applicationName, BuildContext context) {
    appName = applicationName;
    //startTime(context);
    checkUserLogin(context);
  }

  static checkUserLogin(BuildContext context) async {
    await Firebase.initializeApp();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    if (await isSignedIn() == true) {
      GoogleSignInAccount googleUser = await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final User logInUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      /**
       * Make user online
       */
      await ChatDBFireStore.makeUserOnline(logInUser);

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

  static startTime(BuildContext context) async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, checkUserLogin(context));
  }

  static bool isLastMessageLeft(var listMessage, String id, int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].get('idFrom') == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  static bool isLastMessageRight(var listMessage, String id, int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].get('idFrom') != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }
}
