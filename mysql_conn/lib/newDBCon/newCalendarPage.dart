import 'package:flutter/material.dart';
import 'package:mysql_conn/newDBCon/data_service.dart';
import 'package:table_calendar/table_calendar.dart';

class newCalendarPage extends StatefulWidget {
  const newCalendarPage({super.key});

  @override
  State<newCalendarPage> createState() => _newCalendarPageState();
}



class _newCalendarPageState extends State<newCalendarPage> {
  final DataService _dataService = DataService();
  Map<DateTime, List> _events = {};
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    List<Map<String, dynamic>> results = await _dataService.getDataForDate(_selectedDay);
    setState(() {
      _events = {};  // Clear previous events
      for (var result in results) {
        DateTime date = DateTime.parse(result['date']);
        if (_events[date] == null) _events[date] = [];
        _events[date]?.add(result);
      }
    });
  }

  Future<void> _updateEvent(DateTime date, Map<String, dynamic> data) async {
    await _dataService.updateDataForDate(date, data);
    await _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('매장방문계획'),
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              _fetchEvents();
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            }, focusedDay: _focusedDay, firstDay: DateTime.utc(2020, 10, 16), lastDay: DateTime.utc(2030, 3, 14),
          ),
          Expanded(
            child: ListView(
              children: _events[_selectedDay]?.map((event) {
                return ListTile(
                  title: Text(event['value']),
                );
              }).toList() ?? [],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Example: Update an event for the selected day
          await _updateEvent(_selectedDay, {'value': 'Updated Event'});
        },
        child: Icon(Icons.update),
      ),
    );
  }
}