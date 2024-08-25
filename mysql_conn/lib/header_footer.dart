import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql_conn/calendar/calendar.dart';
import 'package:mysql_conn/main.dart';
import 'package:mysql_conn/work/checkinMainPage.dart';
import 'package:mysql_conn/work/planMainPage.dart';
import 'package:mysql_conn/work/workMainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calendar/calendarScreen.dart';
import 'calendar/calendar_page.dart';
import 'loginPage/loginMainpage.dart';
import 'memoPage/memoMainPage.dart';
import 'myinfoPage/myinfoMainPage.dart';
import 'newDBCon/newCalendarPage.dart';
import 'work/tab/plantest2.dart';

class MyAppPage extends StatefulWidget {
  const MyAppPage({super.key});

  @override
  State<MyAppPage> createState() => MyAppState();
}

class MyAppState extends State<MyAppPage> {
  // 바텀 네비게이션 바 인덱스
  int _selectedIndex = 0;
  String? userid = "";
  String? _uName = "";

  final List<Widget> _navIndex = [
    //MyMemoPage(),
    CheckinPage(),
    workMain(),
    TableEventsExample(),
    WorkMain(),
    planMain(),
    //newCalendarPage(),
    //CalendarScreen(),
    //CalendarPage(),
    MyInfoPage(),

  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _uName = prefs.getString('uName');
    });
  }

  @override
  void initState() {
    super.initState();
    //_autoLoginName();
    _loadUserName();
  }

  void _autoLoginName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _uName = prefs.getString('uName');
    });
  }

  // 자동 로그인 해제
  void _delAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('hf_remove token!!!!');
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(

        automaticallyImplyLeading: false,
        middle: const Text('marketPro'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(
                CupertinoIcons.arrowshape_turn_up_left,
                size: 30,
              ),
              onPressed: () {
                showCupertinoModalPopup<void>(
                  context: context,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                    title: const Text('알림'),
                    content: const Text('로그아웃하시겠습니까?'),
                    actions: <CupertinoDialogAction>[
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        onPressed: () => Navigator.pop(context),
                        child: const Text('아니오'),
                      ),
                      CupertinoDialogAction(
                        isDestructiveAction: true,
                        onPressed: () {
                          _delAutoLogin();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => LoginMainPage(),
                            ),
                          );
                        },
                        child: Text('예 $_uName'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _navIndex.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.blue,
        unselectedItemColor: Colors.blueGrey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.home_filled),
          //   label: '홈',
          //   backgroundColor: Colors.white,
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_history_outlined),
            label: '근태',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_sharp),
            label: '휴가',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mark_chat_read_outlined),
            label: '방문계획',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.queue_play_next_outlined),
            label: 'plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '내정보',
          ),


        ],
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}