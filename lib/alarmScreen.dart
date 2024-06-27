// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';



import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';







/// Example app for Espresso plugin.
class AlarmScreenClass extends StatelessWidget {
  const AlarmScreenClass({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: _AlarmHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class _AlarmHomePage extends StatefulWidget {
  const _AlarmHomePage({Key? key, required this.title}) : super(key: key);
  final String title;


  @override
  _AlarmHomePageState createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<_AlarmHomePage> {
  int snoozeMin=11;
   late SharedPreferences sharedPreferences;
  int _counter = 0;
 // final assetsAudioPlayer = AssetsAudioPlayer();
 // final player = AudioPlayer();
  List<String> hourList=[];
  List<bool> onOffList=[];
  double sleepCoin=0;
  final dataBase = FirebaseFirestore.instance;
  final currentUser=FirebaseAuth.instance.currentUser;
  double snoozePrice=1;
  @override
  void initState() {
    print("asd started");
    initStateAsync();
   /* FlutterAlarmClock.createAlarm(
        11, 55);
    print('alarm set');*/
    //_launchUrl();

    super.initState();


    // Register for events from the background isolate. These messages will
    // always coincide with an alarm firing.

  }
  initStateAsync()async{


   sharedPreferences= await SharedPreferences.getInstance();

  await getShared();
  try{
    double firebaseSleepCoin= await getData();
    if(firebaseSleepCoin!=0)sleepCoin=firebaseSleepCoin;
  }catch(e){
    print("error firebaseSleepCoin $e");
  }


   await turnsOffOnGoingAlarmFromList(hourList);

   setState((){});
    ring();
 //  isMorThanSixHour();
 // await saveBeallitasEbresztes();

  }
  getData()async{
    double r=0;
    var snapshot=await dataBase.collection("user").doc(currentUser!.email).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    data["pez"];
    print(data["pez"]);
    r=data["pez"];
    return r;
  }
  setData(double coinNumber) async {
    try {

      await dataBase.collection("user").doc(currentUser!.email).set({"pez": coinNumber})
          .whenComplete(() => showMeesage("feltoltve"))
          .catchError((error, stackTrace) {
        showMeesage("nemsiker ${error.toString()}");
        print("nemsiker ${error.toString()}");
      });
    }catch(e){
      print("try error $e");
    };

  }
  showMeesage(String errorCode){
    showDialog(context: context,
        builder: (context){
          return AlertDialog(
            backgroundColor: Colors.grey,
            title: Center(child:
            Text(errorCode),),
          );
        }
    );
  }
  saveOnOffList() async {
    List<String> stringList=[];
    for(int i=0;i<onOffList.length;i++){
      if(onOffList[i]){
        stringList.add("true");
      }else{
        stringList.add("false");
      }
    }

    await sharedPreferences.setStringList("onofflist", stringList);
  }
  saveHourList()async{
    await sharedPreferences.setStringList("hourlist", hourList);
  }

  getShared()async{
    snoozeMin=sharedPreferences.getInt("snooze")??10;
    hourList=await sharedPreferences.getStringList("hourlist")??[];
    sleepCoin=await sharedPreferences.getDouble("sleepcoin")??0;
    snoozePrice= await sharedPreferences.getDouble("snoozeprice")??1;
    List<String> stringListOnOff=await sharedPreferences.getStringList("onofflist")??[];
    for(int i=0;i<stringListOnOff.length;i++){
      if(stringListOnOff[i].contains("true")){
        onOffList.add(true);
      }
      if(stringListOnOff[i].contains("false")){
        onOffList.add(false);
      }
    }
    setState(() {

    });

  }

  turnsOffOnGoingAlarmFromList(List <String> timeList) async {
    bool alarmTime=false;
    DateTime dateTime =DateTime.now();
    DateTime plusMinit= dateTime.add(Duration(minutes: 1));
    DateTime minusMinit= dateTime.subtract(Duration(minutes: 1));
    String nowTime=DateFormat('HH:mm').format(dateTime);
    String sMinusMinit=DateFormat('HH:mm').format(minusMinit);
    String sPlusMinit=DateFormat('HH:mm').format(plusMinit);
    print(nowTime);
    for(int i=0;i<timeList.length;i++){
      print(timeList[i]);
      if(nowTime.contains(timeList[i])){
        alarmTime=true;
        onOffList[i]=false;


      }
      if(sMinusMinit.contains(timeList[i])){
        alarmTime=true;
        onOffList[i]=false;

      }
      if(sPlusMinit.contains(timeList[i])){
        alarmTime=true;
        onOffList[i]=false;

      }

    }
    if(alarmTime )await saveOnOffList();

    print("now timeee: $nowTime alamTime: $alarmTime");
    return alarmTime;
  }
isMorThanSixHour() async {
 double? hourDouble = sharedPreferences!.getDouble("hour");
  String? alarmsetingdateString=sharedPreferences.getString("alarmsetingdate");
  if(!alarmsetingdateString!.contains("nincs") && !alarmsetingdateString!.contains("volt")){
  //  DateTime alarmsetingdateTimeFormat=DateTime.parse(alarmsetingdateString!);
  //  DateTime nowDate=DateTime.now();
  //  DateTime alarmLength = DateTime(nowDate.year- alarmsetingdateTimeFormat.year, nowDate.month-alarmsetingdateTimeFormat.month,nowDate.day-alarmsetingdateTimeFormat.day,nowDate.hour-alarmsetingdateTimeFormat.hour,nowDate.minute-alarmsetingdateTimeFormat.minute);
   // print(" alarm length ${alarmLength.hour}:${alarmLength.minute}");
   // if(alarmLength.minute.toInt()>2) await sharedPreferences.setString("alarmsetingdate","van");
    if(hourDouble!>0.2) await sharedPreferences.setString("alarmsetingdate","van");

  }




}
  /*ring()async{
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    String? ringTonePath=sharedPreferences.getString("ring");

    assetsAudioPlayer.open(
      Audio.file(ringTonePath!),

      showNotification: true,
      volume: 0.5
    );
    assetsAudioPlayer.setVolume(0.5);

  }*/
  ring()async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    String? ringTonePath=sharedPreferences.getString("ring");
    print("ringtone: $ringTonePath");
    if(ringTonePath!=null){
      FlutterRingtonePlayer.play(

        fromPath: ringTonePath,
        ios: IosSounds.glass,
        looping: true, // Android only - API >= 28
        asAlarm: true, // Android only - all APIs
      );
    }else{
      FlutterRingtonePlayer.play(

        android: AndroidSounds.alarm,
        ios: IosSounds.glass,
        looping: true, // Android only - API >= 28
        asAlarm: true, // Android only - all APIs
      );
    }


  }
 /* ring()async{
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    String? ringTonePath=sharedPreferences.getString("ring");




    final duration = await player.setFilePath(           // Load a URL
        ringTonePath!);
    player.play();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.al);
   // player.setVolume(0.5);
  }*/
  @override
  void dispose() {
   disposeAsync();

    super.dispose();
  }
  disposeAsync()async{
    SharedPreferences preferences=await SharedPreferences.getInstance();
    preferences.setBool('alarm', false);
    print("alarm pref set false");
  }


  Future<void> _launchUrl() async {
    final Uri _url = Uri.parse('https://open.spotify.com/track/0NAjsPwvBwJKs0p2RL4GeM');
    if(await canLaunchUrl(_url))launchUrl(_url);
    /* if (!await canLaunchUrl(_url)) {
      throw 'Could not launch $_url';
    }*/
  }

  snoozeButton()async{

    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.txt');
    await file.writeAsString('true');



  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 10,
      channelKey: 'basic_channel',
      title: 'eloterben teljeskepernyo',
      body: '',
      category: NotificationCategory.Alarm,
      fullScreenIntent: true,



      // notificationLayout: Text('data');
    ),
    schedule: NotificationInterval(
      interval: (snoozeMin*60).toInt(), preciseAlarm: true,),
    actionButtons: [

      NotificationActionButton(
        key: 'DECLINE',
        label: 'Decline',
        autoDismissible: true,
        buttonType: ActionButtonType.DisabledAction,
      ),
    ],
  );

  FlutterRingtonePlayer.stop();
    FlutterRingtonePlayer.play(

      fromAsset: "assets/cash.mp3",
      ios: IosSounds.glass,
      looping: false, // Android only - API >= 28
      asAlarm: true, // Android only - all APIs
    );
    sleepCoin=sleepCoin-snoozePrice;
    await sharedPreferences.setDouble("sleepcoin", sleepCoin);
    await setData(sleepCoin);
  SystemNavigator.pop();


}
  saveBeallitasEbresztes()async{
    DateTime time =DateTime.now();
    String timeString=DateFormat('dd HH:mm').format(time);
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/beallitasebresztes.txt');
    String list  = await file.readAsString();
    list = " $timeString alert"+"\n"+list;
    await file.writeAsString(list);


  }
  stopButton()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool("alarm", false);
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/my_file.txt');
    await file.writeAsString("falsee");
  //  assetsAudioPlayer.pause();

    FlutterRingtonePlayer.stop();
  /*  FlutterRingtonePlayer.play(

      android: AndroidSounds.alarm,
      ios: IosSounds.glass,
      looping: true, // Android only - API >= 28
      asAlarm: true, // Android only - all APIs
    );*/
    SystemNavigator.pop();
  }
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headline4;
    return Scaffold(
  /*    appBar: AppBar(
        title: Text("Alarm"),
      ),*/
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              /*  Text(
                  'Alarm',
                  style: textStyle,
                ),*/

              ],
            ),
            Column(
              children: [

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
          style: ElevatedButton.styleFrom(
          primary: Colors.green,
          onPrimary: Colors.white,
          shadowColor: Colors.greenAccent,
          elevation: 3,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0)),
          minimumSize: Size(200, 100), //////// HERE
      ),
      onPressed: () {snoozeButton();},
      child: Text('\$nooze $snoozeMin min'),
    ),
        ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      onPrimary: Colors.white,
                      shadowColor: Colors.blue,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                      minimumSize: Size(200, 100), //////// HERE
                    ),
                    onPressed: () {stopButton();},
                    child: Text('Stop'),
                  ),
                ),
              ],
            ),
           // ElevatedButton(onPressed: () async {   print("setvolumeee ");await player.setVolume(1);}, child: Text("asd"))

          ],
        ),
      ),
    );
  }
}