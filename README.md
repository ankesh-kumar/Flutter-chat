# flutter_chat

A Chat Helper for Flutter using Firebase as backend services.

## Getting Started
Add this to your package's pubspec.yaml file:<br/>
dependencies:<br/>
flutter_chat: ^0.1.2<br/>

You can install packages from the command line:<br/> with Flutter:<br/> $ flutter pub get<br/>


Use ChatData.dart for start building your chat.<br/>

You can use your own widget in Stateful Widget Class.<br/>
Steps:<br/>
1. add firebase in your android and ios project<br/>
2.  Create a Stateful widget class and call the method in body<br/>
    within initState():<br/>
    ChatData.init("app name",context);<br/> 
3. and in body of Widget build:<br/>
   ChatData.widgetWelcomeScreen(context)<br/>


Now enjoy the chat.
