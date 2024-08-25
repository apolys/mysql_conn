import 'package:crypto/crypto.dart'; // password hashing algorithms
import 'dart:convert'; // for the utf8.encode method
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mysql_conn/loginPage/loginProvider.dart';
import 'package:mysql_conn/utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calendar/vListProvider.dart';
import 'config/mySqlconnector.dart';
import 'loginPage/loginMainpage.dart';
import 'memoPage/memoListProvider.dart';



void main() async{

//   Idol blackPink = Idol();
// //  Idol blackPink = new Idol();
// // dart 언어에서는 new 생성자 있는거 없는거 차이가 없다.
//
//   print(blackPink.name);
//   print(blackPink.members);
//   blackPink.sayHello();
//   blackPink.introduce();

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(); // Initiali

  dbConnector();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_)=>MemoUpdator()),
      ChangeNotifierProvider(create: (_)=>VacationUpdator()),
      //ChangeNotifierProvider(create: (_)=>Loginprovider()),
    ],
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MemoApp',
      //home: LoginMainPage(),
      home: TokenCheck(),
    );
  }
}

//
//
// // 기본 홈
// class MyAppPage extends StatefulWidget {
//   const MyAppPage({super.key});
//
//   @override
//   State<MyAppPage> createState() => MyAppState();
// }
//
// class MyAppState extends State<MyAppPage> {
//   // 바텀 네비게이션 바 인덱스
//   int _selectedIndex = 0;
//
//   final List<Widget> _navIndex = [
//     MyMemoPage(),
//     CommunityPage(),
//     MyInfoPage(),
//   ];
//
//   void _onNavTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _navIndex.elementAt(_selectedIndex),
//       bottomNavigationBar: BottomNavigationBar(
//         fixedColor: Colors.blue,
//         unselectedItemColor: Colors.blueGrey,
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           // BottomNavigationBarItem(
//           //   icon: Icon(Icons.home_filled),
//           //   label: '홈',
//           //   backgroundColor: Colors.white,
//           // ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.my_library_books_outlined),
//             label: '메모2',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(CupertinoIcons.chat_bubble_2),
//             label: '커뮤니티2',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: '내 정보2',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onNavTapped,
//       ),
//     );
//   }
// }
//
// // 메모 페이지
// // 앱의 상태를 변경해야하므로 StatefulWidget 상속
// class MyMemoPage extends StatefulWidget {
//   const MyMemoPage({super.key});
//
//   @override
//   MyMemoState createState() => MyMemoState();
// }
//
// class MyMemoState extends State<MyMemoPage> {
//   // 검색어
//   String searchText = '';
//
//   // 리스트뷰에 표시할 내용
//   final List<String> items = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];
//   final List<String> itemContents = [
//     'Item 1 Contents',
//     'Item 2 Contents',
//     'Item 3 Contents',
//     'Item 4 Contents'
//   ];
//
//   // 플로팅 액션 버튼을 이용하여 항목을 추가할 제목과 내용
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController contentController = TextEditingController();
//
//   // 리스트뷰 카드 클릭 이벤트
//   void cardClickEvent(BuildContext context, int index) {
//     String content = itemContents[index];
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         // 정의한 ContentPage의 폼 호출
//         builder: (context) => ContentPage(content: content),
//       ),
//     );
//   }
//
//   // 플로팅 액션 버튼 클릭 이벤트
//   Future<void> addItemEvent(BuildContext context) {
//     // 다이얼로그 폼 열기
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('항목 추가하기'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               TextField(
//                 controller: titleController,
//                 decoration: InputDecoration(
//                   labelText: '제목',
//                 ),
//               ),
//               TextField(
//                 controller: contentController,
//                 decoration: InputDecoration(
//                   labelText: '내용',
//                 ),
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('취소'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('추가'),
//               onPressed: () {
//                 setState(() {
//                   String title = titleController.text;
//                   String content = contentController.text;
//                   items.add(title);
//                   itemContents.add(content);
//                 });
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   centerTitle: true,
//       //   title: Text('Bottom Navigation Bar Example'), // 앱 상단바 설정
//       // ),
//       body: Column(
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: '검색어를 입력해주세요.',
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   searchText = value;
//                 });
//               },
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               // items 변수에 저장되어 있는 모든 값 출력
//               itemCount: items.length,
//               itemBuilder: (BuildContext context, int index) {
//                 // 검색 기능, 검색어가 있을 경우
//                 if (searchText.isNotEmpty &&
//                     !items[index]
//                         .toLowerCase()
//                         .contains(searchText.toLowerCase())) {
//                   return SizedBox.shrink();
//                 }
//                 // 검색어가 없을 경우, 모든 항목 표시
//                 else {
//                   return Card(
//                     elevation: 3,
//                     shape: RoundedRectangleBorder(
//                         borderRadius:
//                         BorderRadius.all(Radius.elliptical(20, 20))),
//                     child: ListTile(
//                       title: Text(items[index]),
//                       onTap: () => cardClickEvent(context, index),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//       // 플로팅 액션 버튼
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => addItemEvent(context), // 버튼을 누를 경우
//         tooltip: 'Add Item', // 플로팅 액션 버튼 설명
//         child: Icon(Icons.add), // + 모양 아이콘
//       ),
//     );
//   }
// }
//
// // 선택한 항목의 내용을 보여주는 추가 페이지
// class ContentPage extends StatelessWidget {
//   final String content;
//
//   const ContentPage({Key? key, required this.content}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Content'),
//       ),
//       body: Center(
//         child: Text(content),
//       ),
//     );
//   }
// }
//
// 커뮤니티 페이지
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => CommunityState();
}

class CommunityState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '방문결과 입력',
        ),
      ),
    );
  }
}

class Idol{
  String name = '블랙핑크';
  List <String> members = ['지수', '제니', '리사', '로제'];

  void sayHello(){
    print('안녕하세요 ${members} 입니다.');
  }

  void introduce(){
    print('저희 맴버는 지수,제니,리사,로제 입니다.');
  }

}

// 내 정보 페이지
// class MyInfoPage extends StatefulWidget {
//   MyInfoPage({super.key});
//
//   Idol blackPink = Idol();
//
//   // print(blackPink.name);
//   // print(blackPink.members);
//   // blackPink.sayHello();
//   // blackPink.introduce();
//   @override
//   State<MyInfoPage> createState() => _MyInfoPageState();
// }
//
// class _MyInfoPageState extends State<MyInfoPage> {
//
//   String? _uName;
//
//   void initState() {
//     super.initState();
//     _loadUserName();
//   }
//
//   Future<void> _loadUserName() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _uName = prefs.getString('uName');
//     });
//     print('로딩');
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Column(
//         children: <Widget>[
//           Padding(
//             padding: EdgeInsets.all(20.0),
//             child:
//             Text(
//               'title',
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Text(
//               'value',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// 내 정보 페이지
class MyCalendar extends StatelessWidget {
  const MyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'my MyCalendar page',
        ),
      ),
    );
  }
}

//
//
// class TableEventsExample extends StatefulWidget {
//   @override
//   _TableEventsExampleState createState() => _TableEventsExampleState();
// }
//
// class _TableEventsExampleState extends State<TableEventsExample> {
//   late final ValueNotifier<List<Event>> _selectedEvents;
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
//       .toggledOff; // Can be toggled on/off by longpressing a date
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   DateTime? _rangeStart;
//   DateTime? _rangeEnd;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _selectedDay = _focusedDay;
//     _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
//   }
//
//   @override
//   void dispose() {
//     _selectedEvents.dispose();
//     super.dispose();
//   }
//
//   List<Event> _getEventsForDay(DateTime day) {
//     // Implementation example
//     return kEvents[day] ?? [];
//   }
//
//   List<Event> _getEventsForRange(DateTime start, DateTime end) {
//     // Implementation example
//     final days = daysInRange(start, end);
//
//     return [
//       for (final d in days) ..._getEventsForDay(d),
//     ];
//   }
//
//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     if (!isSameDay(_selectedDay, selectedDay)) {
//       setState(() {
//         _selectedDay = selectedDay;
//         _focusedDay = focusedDay;
//         _rangeStart = null; // Important to clean those
//         _rangeEnd = null;
//         _rangeSelectionMode = RangeSelectionMode.toggledOff;
//       });
//
//       _selectedEvents.value = _getEventsForDay(selectedDay);
//     }
//   }
//
//   void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
//     setState(() {
//       _selectedDay = null;
//       _focusedDay = focusedDay;
//       _rangeStart = start;
//       _rangeEnd = end;
//       _rangeSelectionMode = RangeSelectionMode.toggledOn;
//     });
//
//     // `start` or `end` could be null
//     if (start != null && end != null) {
//       _selectedEvents.value = _getEventsForRange(start, end);
//     } else if (start != null) {
//       _selectedEvents.value = _getEventsForDay(start);
//     } else if (end != null) {
//       _selectedEvents.value = _getEventsForDay(end);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text('call plan'),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           TableCalendar<Event>(
//             firstDay: kFirstDay,
//             lastDay: kLastDay,
//             focusedDay: _focusedDay,
//             selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//             rangeStartDay: _rangeStart,
//             rangeEndDay: _rangeEnd,
//             calendarFormat: _calendarFormat,
//             rangeSelectionMode: _rangeSelectionMode,
//             eventLoader: _getEventsForDay,
//             startingDayOfWeek: StartingDayOfWeek.monday,
//             calendarStyle: CalendarStyle(
//               // Use `CalendarStyle` to customize the UI
//               outsideDaysVisible: false,
//             ),
//             onDaySelected: _onDaySelected,
//             onRangeSelected: _onRangeSelected,
//             onFormatChanged: (format) {
//               if (_calendarFormat != format) {
//                 setState(() {
//                   _calendarFormat = format;
//                 });
//               }
//             },
//             onPageChanged: (focusedDay) {
//               _focusedDay = focusedDay;
//             },
//           ),
//           const SizedBox(height: 8.0),
//           Expanded(
//             child: ValueListenableBuilder<List<Event>>(
//               valueListenable: _selectedEvents,
//               builder: (context, value, _) {
//                 return ListView.builder(
//                   itemCount: value.length,
//                   itemBuilder: (context, index) {
//                     return Container(
//                       margin: const EdgeInsets.symmetric(
//                         horizontal: 12.0,
//                         vertical: 4.0,
//                       ),
//                       decoration: BoxDecoration(
//                         border: Border.all(),
//                         borderRadius: BorderRadius.circular(12.0),
//                       ),
//                       child: ListTile(
//                         onTap: () => print('${value[index]}'),
//                         title: Text('${value[index]}'),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }