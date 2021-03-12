import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatDBFireStore {
  static Future<bool> isUserSignedIn() async {
    // GoogleSignInAccount? user = _currentUser;

    return false;
  }

  static String getDocName() {
    String dbUser = "users";
    return dbUser;
  }

  static Future<void> checkUserExists(User logInUser) async {
    print('abcdearlier');
    QuerySnapshot result;
    try {
      result = await FirebaseFirestore.instance
          .collection(getDocName())
          .where('userId', isEqualTo: logInUser.uid)
          .get();
    } catch (e) {
      print('ex ' + e.toString());
    }

    print('abcdeafter');
    final List<DocumentSnapshot> documents = result.docs;
    print('abcdeafterfinal');
    if (documents.length == 0) {
      // Update data to server if new user
      await saveNewUser(logInUser);
    }
  }

  static saveNewUser(User logInUser) {
    print('UserId ' + logInUser.uid);
    print('UserID' + logInUser.displayName);
    print('UserID' + logInUser.photoURL);
    print('UserID' + logInUser.email);

    List<String> friendList = [];

    FirebaseFirestore.instance.collection(getDocName()).doc(logInUser.uid).set({
      'nickname': logInUser.displayName,
      'photoUrl': logInUser.photoURL,
      'userId': logInUser.uid,
      'email': logInUser.email,
      'friends': friendList,
      'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
      'chattingWith': null,
      'online': null
    });
  }

  static streamChatData() {
    FirebaseFirestore.instance
        .collection(ChatDBFireStore.getDocName())
        .snapshots();
  }

  static Future<void> makeUserOnline(User logInUser) async {
    FirebaseDatabase.instance
        .reference()
        .child("/status/" + logInUser.uid)
        .onDisconnect()
        .set("offline");

    FirebaseDatabase.instance
        .reference()
        .child("/status/" + logInUser.uid)
        .set("online");
  }
}
