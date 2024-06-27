import 'package:flutter/material.dart';



class SleepCoinProvider extends ChangeNotifier{
  double _sleepCoin =0;
  get sleepCoin  =>_sleepCoin;

  setSleepCoin(double sleepCoin){
    _sleepCoin=sleepCoin;
  }
}