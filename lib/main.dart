import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatting_app/screens/welcome_screen.dart';
import 'package:chatting_app/screens/login_screen.dart';
import 'package:chatting_app/screens/registration_screen.dart';
import 'package:chatting_app/screens/chat_screen.dart';

//void main async() => runApp(FlashChat());

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black54),
        ),
      ),
      //home: WelcomeScreen(),
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) =>WelcomeScreen(),
        LoginScreen.id : (context) => LoginScreen(),
        ChatScreen.id : (context) => ChatScreen(),
        RegistrationScreen.id : (context) => RegistrationScreen()
      },
    );

  }
}
