
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'chatData.dart';
import 'constants.dart';
import 'screens/chat.dart';

class ChatWidget{

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
                  ChatData.appName,
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
                onPressed: () => ChatData.authUser(context),
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

  static Widget getAppBar() {
    return AppBar(
      leading: null,
      title: Text(ChatData.appName),
      backgroundColor: themeColor,
    );
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
            ChatData.appName,
            style: TextStyle(fontSize: 28),
          )),
    );
  }

  static Widget widgetFullPhoto(BuildContext context, String url) {
    return Container(child: PhotoView(imageProvider: NetworkImage(url)));
  }

}