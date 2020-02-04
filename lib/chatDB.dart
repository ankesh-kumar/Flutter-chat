import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatDBFireStore {
  static String getDocName() {
    String dbUser = "users";
    return dbUser;
  }

  static Future<void> checkUserExists(FirebaseUser logInUser) async {
    final QuerySnapshot result = await Firestore.instance
        .collection(getDocName())
        .where('userId', isEqualTo: logInUser.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {
      // Update data to server if new user
      await saveNewUser(logInUser);
    }
  }

  static saveNewUser(FirebaseUser logInUser) {
    Firestore.instance
        .collection(getDocName())
        .document(logInUser.uid)
        .setData({
      'nickname': logInUser.displayName,
      'photoUrl': logInUser.photoUrl,
      'userId': logInUser.uid,
      'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
      'chattingWith': null,
      'online': null
    });
  }

  static streamChatData() {
    Firestore.instance.collection(ChatDBFireStore.getDocName()).snapshots();
  }

  static Future<void> makeUserOnline(FirebaseUser logInUser) async {
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
