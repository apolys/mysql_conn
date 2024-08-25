

import 'package:flutter/material.dart';
import 'package:mysql_conn/calendar/vListProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../memoPage/memoDB.dart';
import '../memoPage/memoDetailPage.dart';
import '../memoPage/memoListProvider.dart';
import '../utils.dart';

class TableEventsExample extends StatefulWidget {
  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;


  // 플로팅 액션 버튼을 이용하여 항목을 추가할 제목과 내용
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController plandata = TextEditingController();

  String? dropdownValue;

  String searchText = '';

  String? _uName;

  // 메모 리스트 저장 변수
  List items = [];


  Future<void> getVacationList() async {

    List vList = [];
    // DB에서 메모 정보 호출
 //   var result = await selectMemoALL();
    print('휴가확인 시작');
    String pDate = "1";
    var result = await selectVacationALL(pDate);

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
  }

  @override
  void initState() {
    super.initState();
    getVacationList();
    _loadUserName();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
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
    return vaEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
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
        getVacationList();
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
        title: Text('call plan'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.sunday,
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
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
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
          Expanded(
            child: Builder(
              builder: (context) {
                // 메모 수정이 일어날 경우 메모 리스트 새로고침
                items = context.watch<VacationUpdator>().vList;


                // 메모가 없을 경우의 페이지
                if (items.isEmpty) {
                  return const Center(
                    child:
                    Column(
                      children: [
                        Text(
                          "표시할 휴가가 없습니다.",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                }
                // 메모가 있을 경우의 페이지
                else {
                  // items 변수에 저장되어 있는 모든 값 출력
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int index) {
                      // 메모 정보 저장
                      dynamic vInfo = items[index];
                      String userName = vInfo['userName'];
                      String vDate = vInfo['vDate'];
                      String vTitle = vInfo['vTitle'];
                      String vContent = vInfo['vContent'];
                      String createDate = vInfo['createDate'];
                      String updateDate = vInfo['updateDate'];

                      // 검색 기능, 검색어가 있을 경우, 제목으로만 검색
                      if (searchText.isNotEmpty &&
                          !items[index]['memoTitle']
                              .toLowerCase()
                              .contains(searchText.toLowerCase())) {
                        return SizedBox.shrink();
                      }
                      // 검색어가 없을 경우
                      // 혹은 모든 항목 표시
                      else {
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.elliptical(20, 20))),
                          child: ListTile(
                            leading: Text(userName),
                            title: Text(vTitle),
                            subtitle: Text(vContent),
                            trailing: Text(vDate),
                            onTap: () => cardClickEvent(context, index),
                          ),
                        );
                      }
                    },
                  );
                }
              },
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