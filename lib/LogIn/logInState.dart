import 'package:expensive_alarm/alarmScreen.dart';
import 'package:expensive_alarm/LogIn/login.dart';
import 'package:expensive_alarm/LogIn/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogInState extends StatelessWidget {
  const LogInState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      resizeToAvoidBottomInset : false,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          print("loginstate snapshot has data= ${snapshot.hasData}");

          if(snapshot.hasData){
            return UserProfile();
          }else{
            return Login();
            Navigator.pushNamed(context, "/alarmscreen");
            //  Navigator.pushNamed(context, "/alarmscreen");
          }

        },
      ),
    );
  }
}
