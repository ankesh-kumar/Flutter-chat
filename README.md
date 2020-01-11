# flutter_chat

A Chat Helper for Flutter using Firebase as backend services.

## Getting Started
Add this to your package's pubspec.yaml file:<br/>
dependencies:<br/>
## flutter_chat: ^0.1.4<br/>

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


## Useful Methods:

Auth user from Google SignIn, if user is using app first time,<br/>
then user data store in firestore in "users" document,<br/>
send true if authenticated,else false<br/>
##authUsersGoogle() → Future<bool>



check if user is loggedin in app<br/>
## isSignedIn() → Future<bool>

Check user authentication, if authenticated then show dashboard screen, else login screen<br/>
## authUser(BuildContext context) → void

used to create splash screen, shows splash for 2 sec and then call to check authentication<br/>
## startTime(BuildContext context) → Future

Now enjoy the chat.


