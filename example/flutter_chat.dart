import 'package:flutter_chat/chatData.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = "welcome_screen";
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    ChatData.init("Just Chat",context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ChatData.getAppBar(),
        backgroundColor: Colors.white,
        body: ChatData.widgetWelcomeScreen(context));
  }
}
