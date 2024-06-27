import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController nameController;
  late TextEditingController passwordController;
  bool loggedIn =false;

  @override
  void initState()  {

    nameController=TextEditingController();
    passwordController=TextEditingController();
    initAsync();

    super.initState();
  }
  initAsync()async{
    await checkIfLogedIn();
  }


  showErrorMessage(String errorCode){
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
  checkIfLogedIn(){
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
    showDialog(context: context, builder: (context){
      return Center(
        child: CircularProgressIndicator(),
      );
    });
    try{

      await FirebaseAuth.instance.signInWithEmailAndPassword(email: nameController.text, password: passwordController.text);
      Navigator.pop(context);
    }on FirebaseAuthException catch (e){
      Navigator.pop(context);
      showErrorMessage(e.code);



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

          SizedBox(height: 20,),
          Icon(Icons.lock,size: 100,),

          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              children: [

                TextField(
                  controller: nameController,
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
                SizedBox(height: 20,),
                Transform.scale(scale:1.5,child: ElevatedButton(onPressed: (){singUserIn();}, child: Text("Sign in"))),
                
                Row(mainAxisAlignment:MainAxisAlignment.center,children: [

                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                  //  child: SizedBox(height: 60,child:IconButton(iconSize: 60,onPressed: (){}, icon: Image.asset("assets/google.png"))),
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
