
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Models/UserModel.dart';

class ChatDBFireStore{

  static String getDocName(){
     String dbUser = "users";
     return dbUser;
  }

  static Future<void> checkUserExists(FirebaseUser logInUser) async {
    
    final QuerySnapshot result = await Firestore.instance
            .collection(getDocName())
            .where('id', isEqualTo: logInUser.uid)
            .getDocuments();
        final List<DocumentSnapshot> documents = result.documents;
        if (documents.length == 0) {
          // Update data to server if new user
          await saveNewUser(logInUser);
        }    

  }

  static saveNewUser(FirebaseUser logInUser){
    Firestore.instance
              .collection(getDocName())
              .document(logInUser.uid)
              .setData({
            'nickname': logInUser.displayName,
            'photoUrl': logInUser.photoUrl,
            'id': logInUser.uid,
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            'chattingWith': null
          });
  }
  
  static streamChatData(){
      Firestore.instance.collection(ChatDBFireStore.getDocName()).snapshots();
  }


}