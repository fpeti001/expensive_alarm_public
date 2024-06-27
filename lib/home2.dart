import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:expensive_alarm/ppp.dart';
import 'package:expensive_alarm/sleepcoinprovider.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:optimize_battery/optimize_battery.dart';
//import 'package:is_lock_screen/is_lock_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class Alarms_home extends StatefulWidget {
  const Alarms_home({Key? key}) : super(key: key);

  @override
  State<Alarms_home> createState() => _Alarms_homeState();
}

class _Alarms_homeState extends State<Alarms_home> with WidgetsBindingObserver{
  final List<String> entries = <String>['t', 'f', 't'];
  List<bool> onOffList=[];
   List<String> hourList = [];
   List<String> minList = [];
  final weekList= {"m": 1,"tu":2,"w":3,"th":4,"f":5,"se":6,"su":7};
late SharedPreferences sharedPreferences;
double sleepCoin=0;
  final dataBase = FirebaseFirestore.instance;
  final currentUser=FirebaseAuth.instance.currentUser;

  PPP ppp = PPP();
  static final facebookAppEvents = FacebookAppEvents();

SleepCoinProvider asd =SleepCoinProvider();
  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    initasync();

    super.initState();
  }
firstStart()async{
  print("first start");
    bool firstStart=await sharedPreferences.getBool("firststart")??true;
    if(firstStart) {
      print ("if(firstStart)true");
     // sleepCoin++;
    //   await sharedPreferences.setDouble("sleepcoin",sleepCoin);
      await setData(sleepCoin);
      await sharedPreferences.setBool("firststart", false);
      await xiaomiDialog();
      facebookAppEvents.logEvent(
        name: 'first_start_event_exal',
        parameters: {
          'button_id': 'first_start_event_button_exal',
        },);
    }
  }
  xiaomiDialog() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final map = deviceInfo.toMap();
    String brand = map["brand"];

    if (brand == "Xiaomi"||brand == "xiaomi") {
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
  getData()async{
    double r=0;
    try{
      var snapshot=await dataBase.collection("user").doc(currentUser!.email).get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      data["pez"];
      print(data["pez"]);
      r=data["pez"];
    }catch(e){
      print("error getData() $e");
    }

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
  isBatterySaverOn()async{
    bool batterySaverOn=true;
 await OptimizeBattery.isIgnoringBatteryOptimizations().then((onValue) {
  setState(() {
  if (onValue) {
  // Igonring Battery Optimization
    print(" battery optimization turnd off");
    batterySaverOn=false;
  } else {
  print("battery optimization turnd on");
  batterySaverOn=true;
  // App is under battery optimization
  }
  });
  });
  return batterySaverOn;
  }
  void showToast(String text ) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content:  Text(text),
        //action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
  isAlarmTime(List <String> timeList){
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
      if(nowTime.contains(timeList[i])&&onOffList[i]==true){
        alarmTime=true;
      }
      if(sMinusMinit.contains(timeList[i])&&onOffList[i]==true){
        alarmTime=true;
      }
      if(sPlusMinit.contains(timeList[i])&&onOffList[i]==true){
        alarmTime=true;
      }
    }


    print("now timeee: $nowTime alamTime: $alarmTime");
    return alarmTime;
  }
  initasync()async{

sharedPreferences=await SharedPreferences.getInstance();
await getShared();
double firebaseSleepCoin= await getData();
await firstStart();
if(firebaseSleepCoin!=0)sleepCoin=firebaseSleepCoin;
if(isAlarmTime(hourList)){
  Navigator.pushReplacementNamed(context, '/alarmscreen');
}else{

setState(() {

});
}

  }

timeToDateTime(String time){

  int hour=int.parse(time.split(":").first);
  int min=int.parse(time.split(":").last);
  DateTime dateNow = DateTime.now();
  DateTime alarm=DateTime(dateNow.year,dateNow.month,dateNow.day,hour,min,dateNow.second);
  if(alarm.isBefore(dateNow))alarm=alarm.add(Duration(days: 1));
  return alarm;

}
  batterySaverDialog(){
      // set up the button
      Widget settingsButton = TextButton(
        child: Text("Settings"),
        onPressed: () {

          Navigator.pop(context);
          OptimizeBattery.stopOptimizingBatteryUsage();
        },
      );
      Widget cancelButton = TextButton(
        child: Text("cancel"),
        onPressed: () {
          Navigator.pop(context);
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("Turn off battery optimization"),
        content: Text("For this app to work properly, you need to turn off battery optimization."),
        actions: [
          settingsButton,cancelButton
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

  permissionDialog() async {
    bool notificationpermissionGaranted = false;
    //   bool otherPermissionsGaranted=false;
    List<NotificationPermission> neededPermissions = [
      NotificationPermission.PreciseAlarms,
      NotificationPermission.FullScreenIntent,
      NotificationPermission.Alert
    ];
    List<NotificationPermission> allowedPermissions =
    await requestUserPermissions(
      context,
      permissionList: neededPermissions,
      channelKey: 'basic_channel',
    );
    List<NotificationPermission> permissionsAllowed =
    await AwesomeNotifications().checkPermissionList(
        channelKey: 'basic_channel', permissions: neededPermissions);
    print(
        "neededPermissions: $neededPermissions \nallowedPermissions: $allowedPermissions\n permissionsAllowed: $permissionsAllowed");

    if (neededPermissions.length == permissionsAllowed.length)
      notificationpermissionGaranted = true;
    return notificationpermissionGaranted;

  }
  static Future<List<NotificationPermission>> requestUserPermissions(
      BuildContext context,
      {
        // if you only intends to request the permissions until app level, set the channelKey value to null
        required String? channelKey,
        required List<NotificationPermission> permissionList}) async {
    // Check if the basic permission was conceived by the user
    //if(!await requestBasicPermissionToSendNotifications(context))
    //  return [];

    // Check which of the permissions you need are allowed at this time
    List<NotificationPermission> permissionsAllowed =
    await AwesomeNotifications().checkPermissionList(
        channelKey: channelKey, permissions: permissionList);
    print(permissionsAllowed);
    print(permissionList);

    // If all permissions are allowed, there is nothing to do
    if (permissionsAllowed.length == permissionList.length) {
      return permissionsAllowed;
    }

    // Refresh the permission list with only the disallowed permissions
    List<NotificationPermission> permissionsNeeded =
    permissionList.toSet().difference(permissionsAllowed.toSet()).toList();

    // Check if some of the permissions needed request user's intervention to be enabled
    List<NotificationPermission> lockedPermissions =
    await AwesomeNotifications().shouldShowRationaleToRequest(
        channelKey: channelKey, permissions: permissionsNeeded);

    // If there is no permissions depending on user's intervention, so request it directly
    print("1  if (!lockedPermissions.isEmpty) ${!lockedPermissions.isEmpty}");
    if (!lockedPermissions.isEmpty) {
      // If you need to show a rationale to educate the user to conceived the permission, show it
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Color(0xfffbfbfb),
            title:  Text(
              'We needs your permission',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'To proceed, you need to enable the permission ' + ':',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  'NotificationPermission.',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Deny',
                    style: TextStyle(color: Colors.red, fontSize: 16.sp),
                  )),
              TextButton(
                onPressed: () async {
                  // Request the permission through native resources. Only one page redirection is done at this point.
                  await AwesomeNotifications()
                      .requestPermissionToSendNotifications(
                      channelKey: channelKey,
                      permissions: lockedPermissions);

                  // After the user come back, check if the permissions has successfully enabled
                  permissionsAllowed = await AwesomeNotifications()
                      .checkPermissionList(
                      channelKey: channelKey,
                      permissions: lockedPermissions);

                  Navigator.pop(context);
                },
                child: Text(
                  'Allow',
                  style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ));
    }
    lockedPermissions = await AwesomeNotifications()
        .shouldShowRationaleToRequest(
        channelKey: channelKey, permissions: permissionsNeeded);
    print("2  if (lockedPermissions.isEmpty) ${lockedPermissions.isEmpty}");
    if (lockedPermissions.isEmpty) {
      // Request the permission through native resources.
      await AwesomeNotifications().requestPermissionToSendNotifications(
          channelKey: channelKey, permissions: permissionsNeeded);

      // After the user come back, check if the permissions has successfully enabled
      permissionsAllowed = await AwesomeNotifications().checkPermissionList(
          channelKey: channelKey, permissions: permissionsNeeded);
    }
    print(" 3permission allowed : $permissionsAllowed");
    // Return the updated list of allowed permissions
    return permissionsAllowed;
  }
  getShared()async{
    hourList=await sharedPreferences.getStringList("hourlist")??[];
    List<String> stringListOnOff=await sharedPreferences.getStringList("onofflist")??[];
    sleepCoin= await sharedPreferences.getDouble("sleepcoin")??0;
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
  saveHourList()async{
   await sharedPreferences.setStringList("hourlist", hourList);
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
  deleteAlarmFromList(int index)async{
    print("deletealarmlist");
    hourList.removeAt(index);
    onOffList.removeAt(index);
    await saveHourList();
    await saveOnOffList();
    stopAlarm(index);
    setState(() {

    });
  }
  createAlarmDialog()async{
    if(sleepCoin>0) {
    if(await isBatterySaverOn()){
    batterySaverDialog();
    print("asdasd;");
    }else{
      if(await permissionDialog()){
        TimeOfDay? selectedTime =await  showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );
        hourList.add(selectedTime!.format(context).toString());
        onOffList.add(true);
        //  minList[index]=selectedTime!.minute.toString();
        await saveHourList();
        await saveOnOffList();

        setAlarm(hourList[hourList.length-1], hourList.length-1);
        setState(() {

        });

      }
    }
    }else{
      ppp.showMyDialog("SleepCoin", "You need to have, at least one sleep coin to set alarm. \n (log in to buy)", context);
    }

  }

  changeAlarmTime(int index)async{
    stopAlarm(index);
    TimeOfDay? selectedTime =await  showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    hourList[index]=selectedTime!.format(context).toString();
    //  minList[index]=selectedTime!.minute.toString();
  await  saveHourList();
  setAlarm(hourList[index], index) ;
    setState(() {

    });
  }
  stopAlarm(int id) {
    AwesomeNotifications().cancel(id);
  }
  setAlarm(String time,int id) async {
    if(sleepCoin>0) {
      if (await permissionDialog()) {
        final Directory directory = await getApplicationDocumentsDirectory();
        final File file = File('${directory.path}/my_file.txt');
        await file.writeAsString("true");

        print("1ALRAM SET TRUUUUUUUUU");


        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: id,
            channelKey: 'basic_channel',
            title: 'Alarm',
            body: '',
            category: NotificationCategory.Alarm,
            fullScreenIntent: true,

            // notificationLayout: Text('data');
          ),
          schedule: NotificationCalendar.fromDate(date: timeToDateTime(time))

          /* NotificationInterval(
          interval: 500,
          preciseAlarm: true,
        )*/,
          actionButtons: [
            NotificationActionButton(
                key: 'Open',
                label: 'OPEN',
                autoDismissible: true,
                buttonType: ActionButtonType.DisabledAction),
            /* NotificationActionButton(
            key: 'DECLINE',
            label: 'Decline',
            autoDismissible: true,
            buttonType: ActionButtonType.DisabledAction,
          ),*/
          ],
        );
        showToast("alarm set at: $time");
      }
    }else{
      ppp.showMyDialog("SleepCoin", "You need to have, at least one sleep coin to set alarm.", context);
    }
  }
  @override
  void dispose() async{

    super.dispose();
    print("home dispose");
    WidgetsBinding.instance?.removeObserver(this);




      //exit(0);


  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("lifecicle changed to ${state}");
    if (state == AppLifecycleState.inactive) {
      print("inactive");
    } else if (state == AppLifecycleState.paused) {
      print('app paused');
      //   exit(0);

    } else if (state == AppLifecycleState.resumed) {
      print('app resumed');
      if(isAlarmTime(hourList)){
        Navigator.pushReplacementNamed(context, '/alarmscreen');
      }


    /*  bool islocked;
      print('app resumed2');
   //   islocked = (await isLockScreen())!;
      print("islocked= $islocked");
      if (islocked) {
        final Directory directory = await getApplicationDocumentsDirectory();
        final File file = File('${directory.path}/my_file.txt');
        String text = await file.readAsString();
        print(text);
        print("locked");
        if (text.contains("true")) {
          Navigator.pushReplacementNamed(context, '/alarmscreen');
        }
      }*/
    }


  }
  @override
  Widget build(BuildContext context) {
    return Consumer<SleepCoinProvider>(builder: (context, value, child) => Column(
        children:[
          showSleepCoinCount(value),
          alarmListView(context),
        //Text(value.sleepCoin)

        ]
    ),);
  }
  showSleepCoinCount(SleepCoinProvider value){

        return Row(children: [
          Icon(Icons.monetization_on_outlined,size: 30,),
          Text("${value.sleepCoin} Sleep Coin",style: TextStyle(fontSize: 30),),

        ],

    );
  }
  Widget alarmListView(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: hourList.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 150,
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(onPressed: () async {
                             await changeAlarmTime(index);
                              },
                              child:
                              Text("${hourList[index] } ",style: TextStyle(fontSize: 50),) ,
                              // Text("${hourList[index] } : ${minList[index]}")
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Transform.scale(scale:1.5,
                            child: Switch(value:onOffList[index], onChanged: (bool nowValue) async {
                              onOffList[index]=nowValue;
                              if(nowValue){
                                setAlarm(hourList[index],index);
                              }else{
                                stopAlarm(index);
                              }

                              await saveOnOffList();
                              setState(() {

                              });
                            })),
                          )
                        ],
                      ),
                      Row(children: [
                        Expanded(child: Align(child:IconButton(
                          icon: Icon(Icons.delete_outline,size: 40,), onPressed: () {
                            deleteAlarmFromList(index);
                        },
                        ),alignment: Alignment.centerRight,))
                      ],)

                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          ),
       //  ElevatedButton(onPressed: (){Navigator.pushNamed(context, "/login");}, child: Text("loginpage")),
       //   ElevatedButton(onPressed: (){}, child: Text("asd")),
         // IconButton(onPressed: () async {await createAlarmDialog();}, icon:Icon(Icons.add))
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RawMaterialButton(
              onPressed: () async {

                createAlarmDialog();

                },
              elevation: 2.0,
              fillColor: Colors.green,
              child: Icon(
                Icons.add,
                size: 35.0,
              ),
              padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
            ),
          )
        ],

      ),
    );

  }
}
