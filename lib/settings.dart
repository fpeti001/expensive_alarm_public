import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late SharedPreferences sharedPreferences;
  bool xiaomi = false;
  String fileName = "";

  late TextEditingController _controllerSnooze;
  late TextEditingController _controllerSnoozePrice;

  int snoozeInt=10;
  bool serviceRuningSwitch = false;
bool sensorSwitchValue=true;
  bool turnOffScreenSwitch=true;
  bool unLockScreenSwitch=true;
  bool turnOnScreenSwitch=true;
  double snoozePrice=1;


  @override
  void initState() {




    initAsync();
    super.initState();
  }
  initAsync()async{
    print("settings initasync start ");

    _controllerSnooze = TextEditingController();
    _controllerSnoozePrice=TextEditingController();

    sharedPreferences = await SharedPreferences.getInstance();
    xiaomi = sharedPreferences.getBool("xiaomi") ?? false;
    String path = sharedPreferences.getString("ring") ?? "/ ";
    serviceRuningSwitch=sharedPreferences.getBool("switch") ?? false;
    snoozeInt = sharedPreferences!.getInt("snooze")??10;
    sensorSwitchValue=sharedPreferences.getBool("sensorswitch")??true;
    turnOffScreenSwitch=sharedPreferences.getBool("turnofscreen")??true;
    unLockScreenSwitch=sharedPreferences.getBool("unlockscreen")??true;
    turnOnScreenSwitch=sharedPreferences.getBool("turnonscreen")??true;
    snoozePrice=sharedPreferences.getDouble("snoozeprice")??1;






    _controllerSnooze.text = snoozeInt.toString();

    _controllerSnoozePrice.text=snoozePrice.toString();



    path = path.substring(path.lastIndexOf("/"));
    fileName = path;
    print("adsf");
    print("path: $path filename: $fileName");
    setState(() {});
  }

  rateMe()async{

    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
    inAppReview.requestReview();
    }
  }
  xiaomiDialog() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final map = deviceInfo.toMap();
    String brand = map["brand"];
    if (brand == "xiaomi") {
      await sharedPreferences.setBool("xiaomi", true);

      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Please allow "Show on Lock screen" Setting.'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text(
                      'It can be found in "App Setting" under "other permissions".'),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () {
                    AppSettings.openAppSettings();
                  },
                  child: Text("open AppSetting")),
              TextButton(
                child: const Text('ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
  pMfilepickernyito() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    String filepath;
    if (result != null) {
      File file = File(result.files.single.path!);
      filepath = file.path;
      //await conver(filepath);
    } else {
      filepath = 'null';
      // User canceled the picker
    }
    await sharedPreferences.setString("ring", filepath);
    print('------------------------------filevalasztas kesz$filepath');

    fileName = filepath.substring(filepath.lastIndexOf("/"));
    setState(() {});
    return filepath;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
   child:        Column(
     children: [
       SizedBox(height: 20,),
       Row(
         children: [
           ElevatedButton(
               onPressed: () {
                 pMfilepickernyito();
               },
               child: Text("Alarm sound")),
           Expanded(
               child: Padding(
                 padding:  EdgeInsets.symmetric(horizontal:1.h ,vertical: 2.w),
                 child: Text(fileName),
               ))
         ],
       ),
       SizedBox(height: 20,),
       Row(
         children: [
           Text("Snooze duration:"),
           Container(
             padding: EdgeInsets.all(0),
             width: 100,
             child: TextField(
               controller: _controllerSnooze,
               onChanged: (text) async {
                 sharedPreferences.setInt(
                     "snooze", int.parse(_controllerSnooze.text));
                 /*  Fluttertoast.showToast(
                                  msg: "set ${_controllerMin.text} min",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black38,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );*/

               },
               keyboardType:
               TextInputType.numberWithOptions(decimal: true),
               inputFormatters: <TextInputFormatter>[
                 FilteringTextInputFormatter.digitsOnly
               ],
             ),
           ),
         ],
       ),
       SizedBox(height: 20,),
       Row(
         children: [
           Text("Snooze price:"),
           Container(
             padding: EdgeInsets.all(0),
             width: 100,
             child: TextField(

               controller: _controllerSnoozePrice,
               onChanged: (text) async {
                 sharedPreferences.setDouble(
                     "snoozeprice", double.parse(_controllerSnoozePrice.text));
                 /*  Fluttertoast.showToast(
                                  msg: "set ${_controllerMin.text} min",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.black38,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );*/

               },

               keyboardType: TextInputType.numberWithOptions(decimal: true),
             inputFormatters: [
               FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
               ],
             ),
           ),
           Text("Sleep coin"),
         ],
       ),
       SizedBox(height: 20,),
       xiaomi
           ? Row(
             children: [
               ElevatedButton(
               onPressed: () {
                 xiaomiDialog();
               },
               child: Text("show on lock screen")),
             ],
           )
           : SizedBox.shrink()
     ],
   ),
    );
  }
}

