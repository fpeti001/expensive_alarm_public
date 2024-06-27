import 'package:expensive_alarm/LogIn/logInState.dart';
import 'package:expensive_alarm/settings.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'home2.dart';


class NavigatorClass extends StatefulWidget {
  const NavigatorClass({Key? key}) : super(key: key);

  @override
  State<NavigatorClass> createState() => _NavigatorClassState();
}

class _NavigatorClassState extends State<NavigatorClass> {
  int _selectedIndex = 0; //New
  String appBarString="Alarm";

  void _onItemTapped(int index) {
    print("------------index $index");
    setState(() {
      _selectedIndex = index;

      switch(index){
        case 0:
          appBarString= "Home";
          break;

        case 1:
          appBarString= "Settings";
          break;
        case 2:
          appBarString= "Profile";
          break;

      }

    });
  }
  static const List<Widget> _pages = <Widget>[
Alarms_home(),
 Settings(),
    LogInState()
  ];
  @override
  Widget build(BuildContext context) {

    return Sizer(
      builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
      return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: AppBar(
          title:  Text(appBarString),
        ),
        body:  Container(child: _pages.elementAt(_selectedIndex),),
        bottomNavigationBar: BottomNavigationBar(
          iconSize: 30,
          items: const <BottomNavigationBarItem>[

            BottomNavigationBarItem(
              icon: Icon(Icons.alarm),
              label: 'Alarm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),


          ],
          currentIndex: _selectedIndex, //New
          onTap: _onItemTapped,
        ),
      );
      },
    );

  }
}
