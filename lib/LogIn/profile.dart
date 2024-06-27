import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensive_alarm/LogIn/logInState.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/secret.dart';
import '../ppp.dart';


class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);




  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {

  late Offerings offerings;
  String nowPageTitle = "";
  int offerNumber = 0;
  int productNumber = 0;
  String nickaName="";

  List<String> stringList=[];
  PackageType payPeriod=PackageType.monthly;

  List<MProduct> mProductList=[];
  List<MOffering> mofferList=[];

  bool syncPurchased=false;
  static final facebookAppEvents = FacebookAppEvents();
  final currentUser=FirebaseAuth.instance.currentUser;
  final dataBase = FirebaseFirestore.instance;
  PPP ppp =PPP();
  double sleepCoin=0;
  late SharedPreferences sharedPreferences;
bool showNicknameInStats=false;
  late TextEditingController nicknameController;
  List stattsNameList=[];


 /* getUserStattsList()async{

    //doc= user
    //field = show

    FirebaseFirestore.instance
        .collection("user")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        try{
          if(doc["show"]==true){

            stattsNameList.add(doc["name"]);
          }

        }catch(e){

        }

      });
    });
    return stattsNameList;
  }*/
    timeCostToString(int time,double cost){
    String r =time.toString()+"-"+cost.toString() ;
    return r;
    }
    stringToTimeCost(String timeAndCost){
      int time=int.parse(timeAndCost.split("-").first);
      double cost=double.parse(timeAndCost.split("-").last);

      return (time,cost);

    }
    getUserStats()async{
      DateTime now = new DateTime.now();
      int nowSecond=now.millisecondsSinceEpoch ~/1000;
      print("nowseconds $nowSecond");

    //doc= user
    //field = show
    List<UserStats> rUserStatsList=[];
    FirebaseFirestore.instance
        .collection("user")
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        try{
          if(doc["show"]==true){
            UserStats userStats=UserStats();
            userStats.name=doc["name"];
            userStats.show=doc["show"];

            List timeCostList=doc["timecost"];
            print("timecost: $timeCostList");
            for(int i=0;i<timeCostList.length;i++){
              var (time,cost)=stringToTimeCost(timeCostList[i]) ;
              print("time and cost  $time $cost");
              userStats.snoozeList.add(Snoozes());
              userStats.snoozeList[i].when=time;
              userStats.snoozeList[i].cost=cost;

            }
            print(userStats);
            int timesIn24hNumber=0;
               for(int i=0;i<timeCostList.length;i++){
            if( userStats.snoozeList[i].when>nowSecond-86400) userStats.h24cost=double.parse((userStats.h24cost+userStats.snoozeList[i].cost).toStringAsFixed(1)); //86400sec =24 hour
           }
            for(int i=0;i<timeCostList.length;i++){
             print("coooooooooost${userStats.snoozeList[i].cost}");//86400sec =24 hour
            }

               print("cost24 ${userStats.h24cost}");
          /*  for(int i=0;i<whenList.length;i++){
              if(whenList[i]>nowSecond-86400) timesIn24hNumber++; //86400sec =24 hour
            }*/
            //  userStats.h24cost=
          }

        }catch(e){
print("errorrrr: $e");
        }
        /*try{
          if(doc["show"]==true){
            UserStats userStats=UserStats();
            userStats.name=doc["name"];
            userStats.show=doc["show"];

            List<int> whenList=doc["when"];
            List<int> costList=doc["cost"];
            for(int i=0;i<whenList.length;i++){

              
              userStats.snozeList[i].when=whenList[i];
              userStats.snozeList[i].cost=costList[i];
            }
            int timesIn24hNumber=0;
        /*   for(int i=0;i<whenList.length;i++){
            if(whenList[i]>nowSecond-86400) timesIn24hNumber++; //86400sec =24 hour
           }*/
            for(int i=0;i<whenList.length;i++){
              if(whenList[i]>nowSecond-86400) timesIn24hNumber++; //86400sec =24 hour
            }
          //  userStats.h24cost=
          }

        }catch(e){

        }*/

      });
    });
    return rUserStatsList;
  }
  getBoolDataList(String dataName )async{
    var r;
    var snapshot=await dataBase.collection("user").doc(currentUser!.email).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    //print(data["pez"]);
    print(data[dataName]);

    r=data[dataName];
    return r;
  }
  setBoolData(var currentUserField,String variable,var value) async {
    try {

      await dataBase.collection("user").doc(currentUserField).update({variable: value})
      //  .whenComplete(() => showMeesage("feltoltve"))
          .catchError((error, stackTrace) {
        //  showMeesage("nemsiker ${error.toString()}");
        print("nemsiker ${error.toString()}");
      });
    }catch(e){
      print("try error $e");
    };

  }

  setUserName(String userName) async {
    try {
      print("cuurrentuseremail ${currentUser?.email}");
      await dataBase.collection("user").doc(currentUser!.email).set({"name": userName})
          .whenComplete(() => print("username added succesfulli!"))
          .catchError((error, stackTrace) {
        //  showMeesage("nemsiker ${error.toString()}");
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
  signOut()async{
 /*   facebookAppEvents.logEvent(
      name: 'costum_purchase_event',
      parameters: {
        'button_id': 'the_costum_purchase_event_button',
      },);*/
//    facebookAppEvents.logPurchase(amount: 1, currency: "USD");

//  await  setData(2);


    await FirebaseAuth.instance.signOut();

  }



  getData(String dataName )async{
    var r;
    var snapshot=await dataBase.collection("user").doc(currentUser!.email).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    //print(data["pez"]);
    print(data[dataName]);

    r=data[dataName];
    return r;
  }
  setData(var currentUserField,String variable,var value) async {
    try {

      await dataBase.collection("user").doc(currentUserField).update({variable: value})
        //  .whenComplete(() => showMeesage("feltoltve"))
          .catchError((error, stackTrace) {
      //  showMeesage("nemsiker ${error.toString()}");
        print("nemsiker ${error.toString()}");
      });
    }catch(e){
      print("try error $e");
    };

  }
  restore() async {
    await Purchases.syncPurchases();
/*
  try {

    PurchaserInfo restoredInfo = await Purchases.restoreTransactions();
    print("restored inffoooo: $restoredInfo");
    try {
      PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
      if (purchaserInfo.entitlements.all["50_token_offer"]!.isActive) {
        // Grant user "pro" access
        ppp.popup(' purchase Activee');
        print(" purchase Activee");
      }
    } on PlatformException catch (e) {
      ppp.popup('is purchased EROR');
      print("is purchased EROR");
      // Error fetching purchaser info
    }
    // ... check restored purchaserInfo to see if entitlement is now active
  } on PlatformException catch (e) {
    // Error restoring purchases
  }*/
  }

  isitpurchased() async {
    try {
      CustomerInfo  purchaserInfo = await Purchases.getCustomerInfo();
      if (purchaserInfo.entitlements.all["50_token_offer"]!.isActive) {
        // Grant user "pro" access
        //todo     ppp.popup(' purchase Activee');
        print(" purchase Activee");
      }
    } on PlatformException catch (e) {
      //todo      ppp.popup('is purchased EROR');
      print("is purchased EROR");
      // Error fetching purchaser info
    }
  }
  getPackage(){
    String duration=mofferList[offerNumber].productList[productNumber].productDuration;
    Package? package;
    /*

  Three Month
  Six Month
  Annual
  Lifetime*/
    switch(duration){
      case "Weekly":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.weekly;
        break;
      case "Monthly":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.monthly;
        break;
      case "Two Month":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.twoMonth;
        break;
      case "Three Month":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.threeMonth;
        break;
      case "Six Month":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.sixMonth;
        break;
      case "Annual":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.annual;
        break;
      case "Lifetime":
        package=offerings.getOffering(mofferList[offerNumber].offeringIdentifier)?.lifetime;
        break;

    }

    return package;








  }
  pruchase2proba(int offerNumberr)async{
    bool isPurchaseSuccesfull=false;


    Offerings offerings = await Purchases.getOfferings();
    String offeringIdentifier=mofferList[offerNumberr].offeringIdentifier;
    print("identifier $offeringIdentifier");
    Package? packagee = offerings.getOffering(offeringIdentifier)?.lifetime;
    try {

      CustomerInfo  purchaserInfo = await Purchases.purchasePackage(packagee!);
      isPurchaseSuccesfull=true;




      // Unlock that great "pro" content

    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        ppp.showMyDialog("Error", "Error: $e", context);
      }
    }
    if(isPurchaseSuccesfull){
      String purchasedCoinNumberString= offeringIdentifier.replaceAll(new RegExp(r'[^0-9]'),'');
      int purchasedCoinNumberInt = int.parse(purchasedCoinNumberString);
      sleepCoin+=purchasedCoinNumberInt;
      await setData(currentUser!.email,"pez",sleepCoin);


      facebookAppEvents.logEvent(
        name: 'costum_purchase_event',
        parameters: {
          'button_id': 'the_costum_purchase_event_button',
        },);
      ppp.showMyDialog("Purchase Succesfull!", "", context);
    }else{

    }
  }
  purchase2(int offerNumberr)async{
bool isPurchaseSuccesfull=false;


      Offerings offerings = await Purchases.getOfferings();
      String offeringIdentifier=mofferList[offerNumberr].offeringIdentifier;
String purchasedCoinNumberString= offeringIdentifier.replaceAll(new RegExp(r'[^0-9]'),'');
double purchasedCoinNumberDouble = double.parse(purchasedCoinNumberString);
        if((purchasedCoinNumberDouble+sleepCoin)<50){
          print("identifier $offeringIdentifier");
          Package? packagee = offerings.getOffering(offeringIdentifier)?.lifetime;
          try {

            CustomerInfo  purchaserInfo = await Purchases.purchasePackage(packagee!);
            isPurchaseSuccesfull=true;




            // Unlock that great "pro" content

          } on PlatformException catch (e) {
            var errorCode = PurchasesErrorHelper.getErrorCode(e);
            if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
              ppp.showMyDialog("Error", "Error: $e", context);
            }
          }
 if(isPurchaseSuccesfull){
     //     if(true){


            sleepCoin+=purchasedCoinNumberDouble;
            await setData(currentUser!.email,"pez",sleepCoin);
            await sharedPreferences.setDouble("sleepcoin",sleepCoin);

            facebookAppEvents.logPurchase(amount: purchasedCoinNumberDouble, currency: "USD");
         /*   facebookAppEvents.logEvent(
              name: 'costum_purchase_event',
              parameters: {
                'button_id': 'the_costum_purchase_event_button',
              },);*/
            ppp.showMyDialog("Purchase Succesfull!", "", context);
            setState(() {

            });
          }else{

          }

        }else{
          ppp.showMyDialog("You can't overstep maximum sleep coin limit! (50)", "Sleep to it, and try again :)", context);
        }

  }
  purchase() async {

    if(!syncPurchased){
      Offerings offerings = await Purchases.getOfferings();

      Package? packagee = getPackage();
      try {
        CustomerInfo  purchaserInfo = await Purchases.purchasePackage(packagee!);
        if (purchaserInfo.entitlements.all["1entitlement"]!.isActive) {
          facebookAppEvents.logEvent(
            name: 'costum_purchase_event',
            parameters: {
              'button_id': 'the_costum_purchase_event_button',
            },);
          //todo      await ppp.pMSharedBoolSet("syncPurchased", true);
          //todo          ppp.showMyDialog("Purchase Succesfull!", "", context);



          // Unlock that great "pro" content
        }
      } on PlatformException catch (e) {
        var errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
          //todo           ppp.showMyDialog("Error", "Error: $e", context);
        }
      }
    }else{
      //todo    ppp.showMyDialog("You already subscribed!", "", context);
    }



    /* if (offerings.getOffering("asdsdga")?.monthly != null) {
      try {
                PurchaserInfo purchaserInfo =
            await Purchases.purchasePackage(packagee!);
        if (purchaserInfo.entitlements.all["asdsdga"]!.isActive) {
          // Unlock that great "pro" content
          print("vááááááásáRLÁÁÁÁÁÁÁÁÁÁS KÉSSSSSSSSSSSSSSSZ");
        }
      } on PlatformException catch (e) {
        var errorCode = PurchasesErrorHelper.getErrorCode(e);
        if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
          (e);
          print("vááááááásáRLÁÁÁÁÁÁÁÁÁÁS EROOOOOOOOOOOR");
        }
      }
    }*/
  }

  Future<void> initPurchase() async {
    await Purchases.setDebugLogsEnabled(true);

    if (Platform.isAndroid) {
      print("--------------------------androiiidddd");
      await Purchases.setup(Secrets.purchasesSetupApiKeyGoogle);
    } else if (Platform.isIOS) {
      print("asdfdsssssssssssssss22");

      await Purchases.setup(Secrets.purchasesSetupApiKeyGoogle);
    }
  }

  initDataTre() async {
    List<Offering> offeringList = [];
    try {
      offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        print("printoffering:  ${offerings}");
        // Display current offering with offerings.current
      }
    } on PlatformException catch (e) {
      // optional error handling
    }
    try {
      List<String> keyList = offerings.all.keys.toList();
      for (int i = 0; keyList.length > i; i++) {
        offeringList.add(offerings.all[keyList[i]]!);
      }
    } catch (e) {}

//todo ide kell megcsinálni h mi legyen a mProductListekben azokat meg berakni az moffer list beeeee



    for(int i=0;i<offeringList.length;i++){

      List<MProduct> mProductList=[];
      try{mProductList.add(MProduct("Weekly", " ${offeringList[i].weekly!.storeProduct.price} ${offeringList[i].weekly!.storeProduct.currencyCode}"));}catch(e){};
      try{mProductList.add(MProduct("Monthly", " ${offeringList[i].monthly!.storeProduct.price} ${offeringList[i].monthly!.storeProduct.currencyCode}"));}catch(e){};
      try{   mProductList.add(MProduct("Two Month",  " ${offeringList[i].twoMonth!.storeProduct.price} ${offeringList[i].twoMonth!.storeProduct.currencyCode}"));}catch(e){};
      try{mProductList.add(MProduct("Three Month",  " ${offeringList[i].threeMonth!.storeProduct.price} ${offeringList[i].threeMonth!.storeProduct.currencyCode}"));}catch(e){};
      try{mProductList.add(MProduct("Six Month",  " ${offeringList[i].sixMonth!.storeProduct.price} ${offeringList[i].sixMonth!.storeProduct.currencyCode}"));}catch(e){};
      try{ mProductList.add(MProduct("Annual",  " ${offeringList[i].annual!.storeProduct.price} ${offeringList[i].annual!.storeProduct.currencyCode}"));}catch(e){};
      try{mProductList.add(MProduct("Lifetime",  " ${offeringList[i].lifetime!.storeProduct.price} ${offeringList[i].lifetime!.storeProduct.currencyCode}"));}catch(e){};

      mofferList.add(MOffering(offeringList[i].identifier, offeringList[i].serverDescription, mProductList,offeringList[i].identifier));
    }


    print("mofferlist= $mofferList");
    List<String> offerstring=[];
 for(int i= 0;i<offeringList.length;i++){
   offerstring.add(mofferList[i].offeringIdentifier);
 }
 print(offerstring);
 offerstring.sort();
    print(offerstring);
  }

  initAsync() async {
    nicknameController=TextEditingController();

    sharedPreferences=await SharedPreferences.getInstance();


    print("--------------------------------initAsync");
    //todo  syncPurchased=await ppp.pMSharedBoolGet('syncPurchased')??false;
   sleepCoin=await  sharedPreferences.getDouble("sleepcoin")??0;
   showNicknameInStats= await sharedPreferences.getBool("shownickname")??false;


    await initPurchase();
    await initDataTre();

    double firebaseSleepCoin= await getData("pez");
    nickaName=await getData("name");
    nicknameController.text=nickaName;
    if(firebaseSleepCoin!=0)sleepCoin=firebaseSleepCoin;
    // createOfferingList();
    //showDurationOffers();
    setState(() {});
  }

  updatePurchaseStatus() async {
    final purechaserInfo = await Purchases.getCustomerInfo();
    final entitlement = purechaserInfo.entitlements.active.values.toList();
    print("Purechaser INfoo: $entitlement");
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {

      print("Build Completed");
    });
    Purchases.addCustomerInfoUpdateListener((info) async {
      updatePurchaseStatus();
      // handle any changes to customerInfo
    });
    print("object");
    initAsync();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try{   stringList= mofferList[offerNumber].offeringDescription.split("|");
    for(int i=0;i<stringList.length;i++){
      stringList[i].replaceAll("|", "");
    }}catch(e){}



    // String arguments = (ModalRoute.of(context)?.settings.arguments ?? "nemment")as String;
    return Scaffold(
        backgroundColor:Colors.grey[80],

        // appBar: AppBar(title: Text("purchase"),),
        body:
        SingleChildScrollView(
          child: SafeArea(child: Column(children: [

            Center(
              child: Column(
                children: [
                  showSleepCoinCount(),
                  SizedBox(height: 15,),
                  Column(children:

                  offerTitles2()??[],

                    ),
                  ElevatedButton(onPressed: (){

                    signOut();}, child: Text("sing out")),
                  SizedBox(height: 15,),
                  nicknameWidget(),
                ],

              ),
            ),
           // showProfilMenu(),


          ]



          )),
        ));
  }

  nicknameWidget(){
    return Column(
      children: [
        Row(
          children: [
            Text("Nickname:"),
            SizedBox(
              width: 100,
              child: TextField(
                controller: nicknameController,
                onSubmitted: (String value) async {
                 // sharedPreferences.setString("nickname", value);
                await setData(currentUser!.email,"name", value);
                },
              ),
            ),
            //SizedBox.expand(),

          ],
        ),
        Row(children: [
          Text("show me in stats"),
          Checkbox(
              value: showNicknameInStats,
              onChanged: (bool? value){
                sharedPreferences.setBool("shownickname", value!);
                setBoolData(currentUser!.email, "show", value);
                setState(() {
                  showNicknameInStats=value!;
                });
              }),
          ElevatedButton(onPressed: () async {

            getUserStats();
           /* var (a,b) = stringToTimeCost(timeCostToString(1567, 4.5));
            print("mukszik time: $a cost $b");*/


         /*
            EZZZ JOO VALAMIRE
            var array=["harom","negy","ketto"];
            try {

              await dataBase.collection("user").doc(currentUser!.email).update({"array": FieldValue.arrayUnion(array)})
              //  .whenComplete(() => showMeesage("feltoltve"))
                  .catchError((error, stackTrace) {
                //  showMeesage("nemsiker ${error.toString()}");
                print("nemsiker ${error.toString()}");
              });
            }catch(e){
              print("try error $e");
            };*/



        //  List nameList=await getUserStattsList();
       //   print(nameList);
           /* var snapshot=await dataBase.collection("user")
                .get()
                .then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((doc) {
            print(doc["name"]);
            });
            }
            );*/
           // Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
            //print(data["pez"]);
          //  print(data[dataName]);
            //print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa$asdf");
          // double asdf= await getData("pez");


           }, child: Text("asd")),
        ],)
      ],
    );
  }

  showSleepCoinCount(){
    return Row(children: [
      Icon(Icons.monetization_on_outlined,size: 30,),
      Text("$sleepCoin Sleep Coin",style: TextStyle(fontSize: 30),),

    ],);
  }

 /* showProfilMenu(){
    return Column(
      children: [
        ElevatedButton(onPressed: (){getData(currentUser!.email);}, child: Text("get")),

        ElevatedButton(onPressed: () async {await setData(5);}, child: Text("set data")),
        ElevatedButton(onPressed: (){signOut();}, child: Text("sing out")),
        ElevatedButton(onPressed: (){Navigator.pushNamed(context, "/purchase");}, child: Text("Purchase coin")),
      ],
    );
  }*/
  offerTitles2() {
    print("offerTitles()");
    print("mofferList.length ${mofferList.length} productList");
    List<Widget> widgedtList = [];
    //  List<Offering> offeringList=offerings.all;
    widgedtList.add(
      Text("Buy Sleep Coin",style: TextStyle(fontSize: 30))
    );
    
    try {
      for (int i = 0; i < mofferList.length; i++) {
        String description = mofferList[i].offeringDescription;

        widgedtList.add(Padding(
          padding: EdgeInsets.all(3),

          child: Row(
            children: [
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            //side: BorderSide(color: Colors.red)
                          )
                      )
                  ),
                  onPressed: () async {
                    await purchase2(i);
                  },
                  child: Text(description.substring(0, description.indexOf("|")), style: TextStyle(color: Colors.white),)),
     Text(" ${mofferList[i].productList[0].productPrice} ",style: TextStyle(fontSize: 20),)
            ],
          ),
        ));
      }

      print("try vege");
      return        widgedtList;
    } catch (e) {
      print("errorrrr $e");
    }


  }











}
class MProduct  {
  String productDuration="";
  String productPrice="";



  MProduct( String productDuration, String productPrice){
    this.productDuration=productDuration;
    this.productPrice=productPrice;

  }
}
class MOffering  {
  String offeringIdentifier="";
  String offeringDescription="";
  String offeringName="";
  List<MProduct> productList=[];


  MOffering(String offeringName, String offeringDescription, List<MProduct> productList,offeringIdentifier){
    this.offeringIdentifier=offeringIdentifier;
    this.offeringName=offeringName;
    this.productList=productList;
    this.offeringDescription=offeringDescription;
  }
}
class UserStats{

  String name="";
  bool show=false;
  double h24cost=0;
  List <Snoozes> snoozeList=[];



}
class Snoozes{
  int when=0;
  double cost=0;
}