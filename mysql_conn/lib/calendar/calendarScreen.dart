import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../class/transaction.dart';
import '../utils.dart';

class Event {
  DateTime date;
  String title;

  Event(this.date, this.title);
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<Event>> _events = {};
  List<Transaction> transaction = [];

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();


  @override
  void initState() {
    super.initState();
    _loadExternalTransactions();
    _loadEvents();
  }

  // 외부 데이터 로딩 메서드
  void _loadExternalTransactions() {
    // 예시로 사용할 외부 데이터
    List<Map<String, dynamic>> externalData = [
      {'id': 't1', 'title': 'new shoes', 'amount': 36.99, 'date': DateTime.utc(2024, 7, 1)},
      {'id': 't2', 'title': 'shoes', 'amount': 77.99, 'date': DateTime.utc(2024, 7, 8)},
    ];

    //externalData.add({'id': 't3', 'title': 'rain coat', 'amount': 36.99, 'date': DateTime.utc(2024, 7, 23)},);
    externalData.add({'id': 't4', 'title': 'burgerKing', 'amount': 36.99, 'date': DateTime.utc(2024, 7, 26)},);

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
    transaction.forEach((event) {
      DateTime date = event.date;
      String title = event.title;

      // 이벤트 리스트 초기화
      if (!events.containsKey(date)) {
        events[date] = [];
      }
      //events[date]!.add(title);
      // Event 객체 생성 후 리스트에 추가
      events[date]!.add(Event(date, title));
      print("event date : $date , $title ,  ");
    });
    setState(() {
      _events = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar with Events'),
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            },
          ),
          ..._events[_selectedDay]?.map((event) => ListTile(
            title: Text(event.title),
          )) ?? [],
        ],
      ),
    );
  }
}