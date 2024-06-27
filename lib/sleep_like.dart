import 'package:flutter/material.dart';

class SleepLike extends StatelessWidget {
   SleepLike({Key? key}) : super(key: key);

  List<String> items = ["a", "b"];


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      prototypeItem: ListTile(
        title: Text(items.first),
      ),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index]),
        );
      },
    );
  }
}