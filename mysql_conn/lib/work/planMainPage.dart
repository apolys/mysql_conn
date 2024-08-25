import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mysql_conn/calendar/vListProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../class/transaction.dart';
import '../memoPage/memoDB.dart';
import '../memoPage/memoDetailPage.dart';
import '../memoPage/memoListProvider.dart';
import '../utils.dart';

class Event {
  DateTime date;
  String title;
  String type;

  Event(this.date, this.title , this.type);
}

class planMain extends StatefulWidget {
  @override
  _planMainState createState() => _planMainState();
}

class _planMainState extends State<planMain> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  Map<DateTime, List<Event>> _events = {};
  List<Transaction> transaction = [];

  // 플로팅 액션 버튼을 이용하여 항목을 추가할 제목과 내용
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController plandata = TextEditingController();

  String? dropdownValue;
  String searchText = '';
  String? _uName;
  String? storeName;

  // 메모 리스트 저장 변수
  List items = [];
  List dateList = [];

  //getPlanList
  List pList = [];
  List planList = [];

  bool _isSwitched = false;
  List<Map<String, dynamic>> storeInfoList = [];

  String _formatMonth(int month) {
    return month.toString().padLeft(2, '0');
  }

  // 외부 데이터 로딩 메서드
  void _loadStoreList(){
    storeInfoList = [
      {'index': '1', 'code': 's10001', 'channel': '이마트', 'store': '가양점'},
      {'index': '2', 'code': 's10002', 'channel': '현대백화점', 'store': '목동점'},
      {'index': '3', 'code': 's10003', 'channel': '홈플러스', 'store': '강서점'},
      {'index': '4', 'code': 's10004', 'channel': '코스트코', 'store': '양평점'},
      {'index': '5', 'code': 's10005', 'channel': '하나로마트', 'store': '하나로마트'},
    ];
  }


  void _loadExternalTransactions() {
    // 예시로 사용할 외부 데이터
    List<Map<String, dynamic>> externalData = [
      {'id': 't1', 'title': 'new shoes', 'amount': 36.99, 'date': DateTime.utc(2024, 7, 1)},
      {'id': 't2', 'title': 'shoes', 'amount': 77.99, 'date': DateTime.utc(2024, 7, 8)},
    ];

    //externalData.add({'id': 't3', 'title': 'rain coat', 'amount': 36.99, 'date': DateTime.utc(2024, 7, 23)},);
    externalData.add({'id': 't1', 'title': 'burgerKing', 'amount': 36.99, 'date': DateTime.utc(2024, 7, 1)},);

    // 외부 데이터를 반복문으로 처리하여 transaction 리스트에 추가
    for (var data in externalData) {
      transaction.add(Transaction(
        id: data['id'],
        title: data['title'],
        amount: data['amount'],
        date: data['date'],
      ));
    }
  }

  void _loadEvents() async {
    Map<DateTime, List<Event>> events = {};

    print("_loadEvents");
    transaction.forEach((event) {
      DateTime date = event.date;
      String title = event.title;
      String id = event.id;

      // 이벤트 리스트 초기화
      if (!events.containsKey(date)) {
        events[date] = [];
      }
      //events[date]!.add(title);
      // Event 객체 생성 후 리스트에 추가
      events[date]!.add(Event(date, title , id));
      print("event date : $date , $title , $id ,  ");
    });
    setState(() {
      _events = events;
    });
  }


  Future<void> getVacationList(String pDate) async {

    List vList = [];
    List<Map<String, dynamic>> externalData = [];
    // DB에서 메모 정보 호출
    //   var result = await selectMemoALL();
    print('휴가확인 시작1');
    var result = await selectVacationALL(pDate);

    print("vataction query ok");
    print(result?.numOfRows);

    // 메모 리스트 저장
    for (final row in result!.rows) {
      var vInfo = {
        'id': row.colByName('id'),
        'userIndex': row.colByName('userIndex'),
        'userName': row.colByName('userName'),
        'vTitle': row.colByName('vTitle'),
        'vDate': row.colByName('vDate'),
        'vContent': row.colByName('vContent'),
        'createDate': row.colByName('createDate'),
        'updateDate': row.colByName('updateDate')
      };
      vList.add(vInfo);
    }

    print('vacationMainPage - getvList : $vList');
    context.read<VacationUpdator>().updateList(vList);

    for (final row in result!.rows) {

      // 데이터 확인
      String mDate = row.colByName('vDate').toString().split(" ")[0];
      String dateY = mDate.substring(0,4);
      String dateM = mDate.substring(5,7);
      String dateD = mDate.substring(8,10);

      // null 체크 후 안전하게 정수로 변환
      var dateYY = dateY != null ? int.tryParse(dateY) ?? 0 : 0;
      var dateMM = dateM != null ? int.tryParse(dateM) ?? 0 : 0;
      var dateDD = dateD != null ? int.tryParse(dateD) ?? 0 : 0;

      var pInfo = {
        'id': row.colByName('userIndex'),
        'title': row.colByName('vTitle'),
        'amount': 0.0,
        //'date': DateTime.utc(dateVV as int),
        // 유효한 날짜 객체 생성
        'date': DateTime.utc(dateYY, dateMM, dateDD),
      };
      print("연차확인");
      print(pInfo);
      //pList.add(pInfo);
      externalData.add(pInfo);
    }

    for (var data in externalData) {
      transaction.add(Transaction(
        id: data['id'],
        title: data['title'],
        amount: data['amount'],
        //date: data['date'], // 문자열을 DateTime으로 변환
        date: data['date'], // 문자열을 DateTime으로 변환
      ));

      print("externalData create");
      print(transaction.toString());
      print(data['date']);
      //print(DateTime.parse(data['date']));

    }
    print(transaction.length);
    //_loadExternalTransactions();
    _loadEvents();
  }


  void _updateEvents() {
    // Update your events or reload them from a data source here
    setState(() {
      String pDate = _selectedDay.toString().split(" ")[0];
      getPlanList(pDate);
    });
  }

  Future<void> getPlanList(String pDate) async {
    // DB에서 메모 정보 호출
    //   var result = await selectMemoALL();
    print('근태확인 시작2');
    var result = await selectPlanALL(pDate);

    print(result?.numOfRows);

    List<Map<String, dynamic>> externalData = [];

    //externalData.add({'id': 't4', 'title': 'burgerKing', 'amount': 36.99, 'date': DateTime.utc(2024, 7, 26)},);


    // 메모 리스트 저장
    print("plan 리스트 저장");
    for (final row in result!.rows) {

      var dateY = row.colByName('year');
      var dateM = row.colByName('month');
      var dateD = row.colByName('day');

      // null 체크 후 안전하게 정수로 변환
      var dateYY = dateY != null ? int.tryParse(dateY) ?? 0 : 0;
      var dateMM = dateM != null ? int.tryParse(dateM) ?? 0 : 0;
      var dateDD = dateD != null ? int.tryParse(dateD) ?? 0 : 0;

      //var dateV = "DateTime.utc(${dateY}.${dateM}.${dateD})";
      var dateV = "(${dateY}.${dateM}.${dateD})";
      var dateVV = "(${dateYY},${dateMM},${dateDD})";
      var dateVisit = row.colByName('visitdate');
      var dateP = row.colByName('plan');

      var pMarker = "DateTime.utc(${dateV}) : [Event('${dateP}')]";
      //planList.add(pMarker);

      var pInfo = {
        'id': row.colByName('id'),
        'title': row.colByName('plan'),
        'amount': 0.0,
        //'date': DateTime.utc(dateVV as int),
        // 유효한 날짜 객체 생성
        'date': DateTime.utc(dateYY, dateMM, dateDD),
      };
      print(pInfo);
      //pList.add(pInfo);
      externalData.add(pInfo);
      //externalData.add({'id': 't4', 'title': 'burgerKing', 'amount': 36.99, 'date': DateTime.utc(2024, 7, 26)},);


      planList.add(dateVisit);//2024-07-18
    }

    // print('planMainPage - getpList : $pList');
    // context.read<VacationUpdator>().updateList(pList);
    //print('planList - getplan : $planList');

    // 외부 데이터를 반복문으로 처리하여 transaction 리스트에 추가
    //transaction.clear();
    for (var data in externalData) {
      transaction.add(Transaction(
        id: data['id'],
        title: data['title'],
        amount: data['amount'],
        //date: data['date'], // 문자열을 DateTime으로 변환
        date: data['date'], // 문자열을 DateTime으로 변환
      ));

      print("externalData create");
      print(transaction.toString());
      print(data['date']);
      //print(DateTime.parse(data['date']));

    }
    print(transaction.length);
    //_loadExternalTransactions();
    _loadEvents();// 잠시 지움 08.14


  }

  @override
  void initState() {
    super.initState();

    _loadUserName();
    _loadStoreList(); // Store list 로드

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

    print("오늘은 몇일? ${_selectedDay}");
    String pDate = _selectedDay.toString().split(" ")[0];

    //String formattedMonth = _formatMonth(_selectedDay.month);
    transaction.clear();
    getVacationList(pDate);
    getPlanList(pDate);

    //_loadExternalTransactions();
    //_loadEvents();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _uName = prefs.getString('uName');
    });
    print('로딩');
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    //return kEvents[day] ?? [];
    //return vaEvents[day] ?? [];
    return _events[day] ?? [];
    //return pEvents[day] ?? [];
  }
  //위에 vaEvents 오류나서 이거 잠시 넣어둠
  Map<DateTime, List<Event>> vaEvents = {
    DateTime(2024, 7, 11): [Event(DateTime(2024, 7, 11), "Sample Event" , "1")],
    // 더 많은 이벤트 추가
  };


  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if(_isSwitched == true){//매장등록을 위해 plan 입력모드 해제
      setState(() {
        _selectedDay = selectedDay;
        dateList.clear();
      });

    }else {//plan 입력
      if (!isSameDay(_selectedDay, selectedDay)) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _rangeStart = null; // Important to clean those
          _rangeEnd = null;
          _rangeSelectionMode = RangeSelectionMode.toggledOff;

          //add list
          dateList.add(selectedDay);
          List updateList = [];
          //update list
          updateList = dateList.toSet().toList();
          dateList.clear();
          dateList = updateList;

          final int lcount = dateList.length;

          print('set state 도는지 확인 ${lcount} /  ${dateList}');
        });
        _selectedEvents.value = _getEventsForDay(selectedDay);
      }
      print('날짜값 이벤트 확인${selectedDay}');
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  // 리스트뷰 카드 클릭 이벤트
  void cardClickEvent(BuildContext context, int index) async {

    dynamic content = items[index];
    print('content : $content');
    // 메모 리스트 업데이트 확인 변수 (false : 업데이트 되지 않음, true : 업데이트 됨)
    var isMemoUpdate = await Navigator.push(
      context,
      MaterialPageRoute(
        // 정의한 ContentPage의 폼 호출
        builder: (context) => ContentPage(content: content),
      ),
    );

    // 메모 수정이 일어날 경우, 메모 메인 페이지의 리스트 새로고침
    if (isMemoUpdate != null) {
      setState(() {
        //getVacationList();
        items = Provider.of<MemoUpdator>(context, listen: false).memoList;
      });
    }
  }

  // 플로팅 액션 버튼 클릭 이벤트
  Future<void> addPlanEvent(BuildContext context) {
    // 다이얼로그 폼 열기
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('휴가 등록 : ${_uName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: ()  {

                },
                child: Text('선택한 날짜 : ${_selectedDay.toString().split(" ")[0]}'),),

              // Text(
              //   _selectedDay != null
              //       ? _selectedDay.toString().split(" ")[0]
              //       : "날짜가 아직 선택되지 않음 ${_selectedDay}",
              // ),

              // TextField(
              //   controller: titleController,
              //   maxLines: null, // 다중 라인 허용
              //   decoration: InputDecoration(
              //     labelText: '구분',
              //   ),
              // ),
              SizedBox(height: 50.0,),
              DropdownButtonFormField<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                decoration: InputDecoration(
                  labelText: '휴가 종류를 선택하세요',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                items: <String>['선택없음','연차', '반차', 'Option 3', 'Option 4']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an option';
                  }
                  return null;
                },
              ),

              TextField(
                controller: contentController,
                maxLines: null, // 다중 라인 허용
                decoration: InputDecoration(
                  labelText: '사유',
                ),
              ),

            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('추가'),
              onPressed: () async {
                //String title = titleController.text;
                String? title = dropdownValue;
                String content = contentController.text;
                DateTime? vDate = _selectedDay;
                // 메모 추가
                //await addMemo(title, content);
                await addVacation(title!, content,vDate!);

                setState(() {
                  // 메모 리스트 새로고침
                  print("MemoMainPage - addMemo/setState");

                  transaction.clear();
                  getVacationList(vDate.toString());
                  getPlanList(vDate.toString());
                  //getMemoList();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('매장방문계획&결과'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ColoredBox(
            color: Colors.white24,
            child: TableCalendar<Event>(
              locale: 'ko_KR', // 추가
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              calendarFormat: _calendarFormat,
              rangeSelectionMode: _rangeSelectionMode,
              eventLoader: _getEventsForDay,
              // eventLoader: (day) {
              //   return _events[day] ?? [];
              // },
              startingDayOfWeek: StartingDayOfWeek.sunday,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context,day,events){
                  //return null;
                  if(events.isNotEmpty){
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.map((event) {
                        Color markerColor;

                        if (event.title == '1') {
                          markerColor = Colors.blue;
                        } else if (event.title == '21') {
                          markerColor = Colors.red;
                        } else {
                          markerColor = Colors.grey; // 기본 색상
                        }

                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: markerColor,
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return null;

                }
              ),
              calendarStyle: CalendarStyle(
                // Use `CalendarStyle` to customize the UI
                outsideDaysVisible: false,
              ),
              onDaySelected: _onDaySelected,
              onRangeSelected: _onRangeSelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                String formattedMonth = _formatMonth(focusedDay.month);
                print("Current visible month: ${focusedDay.year}-$formattedMonth");
                String change_date = "${focusedDay.year}-$formattedMonth";
                transaction.clear();
                getVacationList(change_date);
                getPlanList(change_date);
              },
            ),
          ),
          const SizedBox(height: 2.0),
          // Expanded(
          //   child: ValueListenableBuilder<List<Event>>(
          //     valueListenable: _selectedEvents,
          //     builder: (context, value, _) {
          //       return ListView.builder(
          //         itemCount: value.length,
          //         itemBuilder: (context, index) {
          //           return Container(
          //             margin: const EdgeInsets.symmetric(
          //               horizontal: 12.0,
          //               vertical: 4.0,
          //             ),
          //             decoration: BoxDecoration(
          //               border: Border.all(),
          //               borderRadius: BorderRadius.circular(12.0),
          //             ),
          //             child: ListTile(
          //               onTap: () => print('${value[index]}'),
          //               title: Text('${value[index]}'),
          //             ),
          //           );
          //         },
          //       );
          //     },
          //   ),
          // ),
          // Expanded(
          //   child: Builder(
          //     builder: (context) {
          //       // 메모 수정이 일어날 경우 메모 리스트 새로고침
          //       items = context.watch<VacationUpdator>().vList;
          //
          //
          //       // 메모가 없을 경우의 페이지
          //       if (items.isEmpty) {
          //         return const Center(
          //           child:
          //           Column(
          //             children: [
          //               Text(
          //                 "표시할 휴가가 없습니다.",
          //                 style: TextStyle(fontSize: 20),
          //               ),
          //             ],
          //           ),
          //         );
          //       }
          //       // 메모가 있을 경우의 페이지
          //       else {
          //         // items 변수에 저장되어 있는 모든 값 출력
          //         return ListView.builder(
          //           itemCount: items.length,
          //           itemBuilder: (BuildContext context, int index) {
          //             // 메모 정보 저장
          //             dynamic vInfo = items[index];
          //             String userName = vInfo['userName'];
          //             String vDate = vInfo['vDate'];
          //             String vTitle = vInfo['vTitle'];
          //             String vContent = vInfo['vContent'];
          //             String createDate = vInfo['createDate'];
          //             String updateDate = vInfo['updateDate'];
          //
          //             // 검색 기능, 검색어가 있을 경우, 제목으로만 검색
          //             if (searchText.isNotEmpty &&
          //                 !items[index]['memoTitle']
          //                     .toLowerCase()
          //                     .contains(searchText.toLowerCase())) {
          //               return SizedBox.shrink();
          //             }
          //             // 검색어가 없을 경우
          //             // 혹은 모든 항목 표시
          //             else {
          //               return Card(
          //                 elevation: 3,
          //                 shape: RoundedRectangleBorder(
          //                     borderRadius:
          //                     BorderRadius.all(Radius.elliptical(20, 20))),
          //                 child: ListTile(
          //                   leading: Text(userName),
          //                   title: Text(vTitle),
          //                   subtitle: Text(vContent),
          //                   trailing: Text(vDate),
          //                   onTap: () => cardClickEvent(context, index),
          //                 ),
          //               );
          //             }
          //           },
          //         );
          //       }
          //     },
          //   ),
          // ),
          Expanded(child:
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {

                  updateListQuery(dateList);
                  // 2초 동안 딜레이
                  await Future.delayed(Duration(seconds: 2));
                  setState(() {
                  String pDate = _selectedDay.toString().split(" ")[0];
                  print ("플랜 마커 업데이트 ${pDate}");
                  transaction.clear();
                  getPlanList(pDate);
                  getVacationList(pDate);
                  });



                  // setState(() {
                  //   dateList.clear();
                  //   _updateEvents();
                  // });

                },
                child: Text('총 ${dateList.length}일 : Plan업데이트'),
              ),
              SizedBox(width: 10,),
              ElevatedButton(
                onPressed: (){
                  setState(() {
                    dateList.clear();
                  });
                },
                child: Text('취소'),
              ),
              SizedBox(width: 10,),
              Switch(
                //title: Text('매장등록'),
                value: _isSwitched,
                onChanged: (bool value){
                  setState(() {
                    _isSwitched = value;
                  });
                },
              ),
              Text('휴가등록'),
            ],
          ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //Text('선택한 일정 모두 업데이트'),
                  ColoredBox(
                    color: Colors.grey,
                    child: Column(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            itemCount: dateList.length,
                            itemBuilder: (context,index)=>ListTile(
                              title: Text(
                                '${index+1}. ${dateList[index].toString().split(" ")[0]}',
                                style: TextStyle(
                                  fontSize: 15,
                                ),),
                            )),
                      ],
                    ),
                  ),
                  Container(
                    height: 20,
                    color: Colors.green,
                    child: const Center(
                      child: Text("end list"),
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  )

                ],
              ),
            ),
          ),

        ],
      ),
      // 플로팅 액션 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () => addPlanEvent(context), // 버튼을 누를 경우 메모 추가 UI 표시
        tooltip: 'Add Item', // 플로팅 액션 버튼 설명
        child: Icon(Icons.add), // + 모양 아이콘
      ),
    );
  }
}