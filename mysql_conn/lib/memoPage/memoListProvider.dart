import 'package:flutter/material.dart';

class MemoUpdator extends ChangeNotifier {
  List _memoList = [];
  List get memoList => _memoList;

  List _planList = [];
  List get planList => _planList;

  // 리스트 업데이트
  void updateList(List newList) {
    _memoList = newList;
    notifyListeners();
  }
  // 리스트 업데이트
  void updatePlan(List newList) {
    _planList = newList;
    notifyListeners();
  }
}



// planList.add(callPlanInfo);