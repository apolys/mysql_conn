import 'package:flutter/material.dart';

class Loginprovider with ChangeNotifier {
  // List _memoList = [];
  // List get memoList => _memoList;
  //
  // // 리스트 업데이트
  // void updateList(List newList) {
  //   _memoList = newList;
  //   notifyListeners();
  // }

  String uname;

  Loginprovider({
   required this.uname,
  });

  String getUname() => uname;
  void setUname(String _uname){
    uname = _uname;
    notifyListeners();
  }
}