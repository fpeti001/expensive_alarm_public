import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:expensive_alarm/LogIn/logInState.dart';
import 'package:expensive_alarm/sleepcoinprovider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:open_settings/open_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';

//import 'package:spotify/spotify.dart';

import 'LogIn/register.dart';
import 'alarmScreen.dart';

import 'LogIn/firebase_options.dart';
import 'LogIn/login.dart';
import 'navigator.dart';
import 'package:expensive_alarm/sleepcoinprovider.dart';







Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white),
      /*  NotificationChannel(
            channelGroupKey: 'basic_channel_group2',
            channelKey: 'my_foreground',
            channelName: 'Basic notifications2',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)*/
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);






  bool alarm = false;
  String text = "false";
  var page;


  runApp(
    ChangeNotifierProvider(
      create: (context)=>SleepCoinProvider(),
      child:   MaterialApp(
        theme: ThemeData(
            primarySwatch: Colors.green
        ),
        navigatorKey: NavigationService.navigationKey,
        onGenerateRoute: (RouteSettings settings) {
          if (text.contains("true")) {
            page = "/alarmscreen";
          } else {
            page = settings.name;
            // page = "/loginstate";
          }

          switch (page) {
            case '/':
              return MaterialPageRoute(builder: (_) => NavigatorClass());


            case '/alarmscreen':
              return MaterialPageRoute(builder: (_) => AlarmScreenClass());
            case '/login':
              return MaterialPageRoute(builder: (_) => Login());
            case '/loginstate':
              return MaterialPageRoute(builder: (_) => LogInState());
            case '/register':
              return MaterialPageRoute(builder: (_) => RegisterPage());

            default:
              return null;
          }
        },

        /* initialRoute: page,
      routes: {

        '/': (contaxt) => MyApp(),
        '/alarmscreen': (contaxt) => Asdclass(),
        //    '/spotify': (contaxt) => spotify(),


      }*/
      ),

    )
    );
}









