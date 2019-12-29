# Flutter-chat

A Chat Helper for Flutter using Firebase as backend services.

## Getting Started

<b>Add this to your package's pubspec.yaml file:<b/><br/>
dependencies:<br/>
  flutter_chat: ^0.1.2<br/>

You can install packages from the command line:with Flutter:<br/>
$ flutter pub get<br/>

Use ChatData.dart for start building your chat.
You can use your own widget in Stateful Widget Class.
Steps:
1. add firebase in your android and ios project
2.  Create a Stateful widget class and call the method in body
    within initState():
    -> ChatData.init("app name",context); 
3. and in body of Widget build:
   -> ChatData.widgetWelcomeScreen(context)


Now enjoy the chat.
