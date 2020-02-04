# flutter_chat

A Chat Helper for Flutter using Firebase as backend services.

## Getting Started
Add this to your package's pubspec.yaml file:<br/>
dependencies:<br/>
## flutter_chat: ^0.1.5<br/>

You can install packages from the command line:<br/> with Flutter:<br/> $ flutter pub get<br/>

Use ChatData.dart for start building your chat.

## Features:
1. 1-1 chat
2. User online status

You can use your own widget in Stateful Widget Class.
Steps:
1. add firebase in your android and ios project
2.  Create a Stateful widget class and call the method in body
    within initState():
    -> ChatData.init("app name",context); 
3. and in body of Widget build:
   -> ChatData.widgetWelcomeScreen(context)

You can use common methods for your application:
## Useful Methods:
1. Auth user from Google SignIn, if user is using app first time,
then user data store in firestore in "users" document,
send true if authenticated,else false
authUsersGoogle() → Future

2. check if user is loggedin with social 
isSignedIn() → Future

3. Check user authentication, if authenticated then show dashboard screen, else login screen
authUser(BuildContext context) → void

4. used to create splash screen, shows splash for 2 sec and then call to check authentication
startTime(BuildContext context) → Future

Now enjoy the chat.
