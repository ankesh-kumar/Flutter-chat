# flutter_chat
A Chat Helper for create chat application in Flutter using Firebase as backend services.

# Checkout Web Demo
[Just Chat Demo](https://just-chat-eb4e7.web.app)

# Support Development
If you found this project helpful or you learned something from the source code and want to thank me, consider buying me a cup of ☕️

[PayPal](https://paypal.me/ankeshkumar01)

[<img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" height="60px" width="200px"/>](https://www.buymeacoffee.com/ankeshkumar)

## Features:
1. 1-1 chat.
2. Chat with only added friends(Privacy). New
3. Share Pic with Gallery/Camera
4. User online status 
5. Flutter web supported

## Next Future Scope

1. Notification 
2. Group Chat
3. User acceptance on chat request
4. share location on chat



## Screenshots:

![login screen](https://1.bp.blogspot.com/-hM837Uh65W0/Xj7adGUmwxI/AAAAAAAANjo/PoDM9bh7rZQqT37yIOu-IXAX4F-5W0NNgCLcBGAsYHQ/s640/splash_screen.jpg)
![user screen](https://1.bp.blogspot.com/-ok2AZvPw9FY/Xj7adz8i8vI/AAAAAAAANjw/TTXUBkbbBv8Ti4AvzVOVIWo5o_V6Ei63ACLcBGAsYHQ/s640/user_list.jpg)
![chat screen](https://1.bp.blogspot.com/-r2TK8wT_mV8/Xj7ade30n8I/AAAAAAAANjs/Uw6OQCBpf-Ec0Cm5XB9DIykJ5VGpDfpyACLcBGAsYHQ/s640/chat_screen.jpg)

## Getting Started
* Add this to your package's pubspec.yaml file:<br/>
dependencies:<br/>[flutter_chat](https://pub.dev/packages/flutter_chat)

* Add [firebase](https://firebase.google.com/) in your android and ios project.

* Deploy "Cloud Function"  on firebase. (provided on cloudFunction folder, used for show user online/offline status).  

* Create a Stateful widget class and call the method in body (example can be found in Github repo),<br/> 
    within initState():<br/>
    -> ChatData.init("app name",context); <br/>
    and in body of Widget build:<br/>
    -> ChatData.widgetWelcomeScreen(context)


## Flutter Web

* If want to run Flutter-Chat project, on web 
Go to App, Firebase->Settings and then add new app, web
Follow the instructions,
Put the firebaseConfig script on index.html in web folder,
<script>
          // Your web app's Firebase configuration
          var firebaseConfig = {
          .....
          ....
          
          }
</script>

Enjoy Fluttering           
