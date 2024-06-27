import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController passwordController2;
  final currentUser=FirebaseAuth.instance.currentUser;
  final dataBase = FirebaseFirestore.instance;

  double sleepCoin=0;

  bool loggedIn =false;

  @override
  void initState()  {
    nameController=TextEditingController();
    emailController=TextEditingController();
    passwordController=TextEditingController();
    passwordController2=TextEditingController();
    initAsync();

    super.initState();
  }
  initAsync()async{
    await checkIfLogedIn();
  }


  setUserName(String userName) async {
    try {
print("cuurrentuseremail ${emailController.text}");
      await dataBase.collection("user").doc(emailController.text).set({"name": userName})
        .whenComplete(() => print("username added succesfulli!"))
          .catchError((error, stackTrace) {
        //  showMeesage("nemsiker ${error.toString()}");
        print("nemsiker ${error.toString()}");
      });
    }catch(e){
      print("try error $e");
    };

  }
  setCoin(double coinNumber) async {
    try {

      await dataBase.collection("user").doc(emailController.text).update({"pez": coinNumber})
      //  .whenComplete(() => showMeesage("feltoltve"))
          .catchError((error, stackTrace) {
        //  showMeesage("nemsiker ${error.toString()}");
        print("nemsiker ${error.toString()}");
      });
    }catch(e){
      print("try error $e");
    };

  }

  showMessage(String errorCode){
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
    await FirebaseAuth.instance.signOut();
  }
  checkIfLogedIn()async{
    if (FirebaseAuth.instance.currentUser != null) {
      loggedIn=true;
    } else {

      loggedIn=false;
    }
    setState(() {

    });
  }
  createUserWithEmailAndPassword(String emailAddress,String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  singUserIn()async{


      if(passwordController.text ==passwordController2.text){
        if(nameController.text!="") {
          showDialog(context: context, builder: (context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          });
          try {
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

            await setUserName(nameController.text);
           await setCoin(sleepCoin);
            Navigator.pop(context);
            Navigator.pop(context);
            showMessage("Account created!");
          } on FirebaseAuthException catch (e) {
            Navigator.pop(context);
            showMessage(e.code+" error1");
          }
        }else{
          showMessage("username error");
        }
      }else{
 showMessage("Passwords don't match")   ;
      }

     



//await checkIfLogedIn();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      backgroundColor: Colors.grey[100],

      body: Column(
        children: [

          SizedBox(height: 80,),


          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      hintText: "User Name",
                      enabledBorder: OutlineInputBorder(

                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      ),
                      fillColor: Colors.white,
                      filled: true

                  ),),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                      hintText: "Email",
                      enabledBorder: OutlineInputBorder(

                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      ),
                      fillColor: Colors.white,
                      filled: true

                  ),),
                SizedBox(height: 10,),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                      hintText: "Password",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      ),
                      fillColor: Colors.white,
                      filled: true

                  ),),
                SizedBox(height: 10,),
                TextField(
                  controller: passwordController2,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                      hintText: "Password",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      ),
                      fillColor: Colors.white,
                      filled: true

                  ),),
                SizedBox(height: 20,),
                Transform.scale(scale:1.5,child: ElevatedButton(onPressed: (){singUserIn();}, child: Text("Sign in"))),

                Row(mainAxisAlignment:MainAxisAlignment.center,children: [

                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    //child: SizedBox(height: 60,child:IconButton(iconSize: 60,onPressed: (){}, icon: Image.asset("assets/google.png"))),
                  ),

                ],),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Not a memember?"),
                    TextButton(onPressed: (){Navigator.pushNamed(context, "/register");}, child: Text("Register Now"))
                  ],
                )
              ],
            ),
          ),

        ],
      ),
    );
  }
}
