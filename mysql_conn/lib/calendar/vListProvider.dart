import 'package:flutter/material.dart';

class VacationUpdator extends ChangeNotifier {
  List _vList = [];
  List get vList => _vList;

  // 리스트 업데이트
  void updateList(List newList) {
    _vList = newList;
    notifyListeners();
  }
}