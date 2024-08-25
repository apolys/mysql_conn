
import 'package:flutter/material.dart';
import 'package:mysql_conn/work/tab/daily_dummy.dart';
import 'package:mysql_conn/work/tab/vo_checkin.dart';
import 'package:mysql_conn/work/tab/w_checkin_item.dart';

class DailyList extends StatefulWidget {
  const DailyList({super.key});

  @override
  State<DailyList> createState() => _DailyListState();
}

class _DailyListState extends State<DailyList> {

  //List<Checkin> myDailyList = [];

  @override

  void initState() {
    super.initState();
    // 페이지가 처음 로드될 때 데이터를 초기화합니다.
    _initializeData();
  }

  // 데이터를 초기화하는 메서드
  void _initializeData() {
    setState(() {
      //myDailyList.clear();
    });
  }

  Widget build(BuildContext context) {
    return Column(
      children: [


        ...myDailyList.map((element)=>CheckinItem(element)).toList(),
      ],
    );
  }
}
