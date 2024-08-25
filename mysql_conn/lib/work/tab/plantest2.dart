import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  DateTime date;
  String title;

  Event(this.date, this.title);
}

class Transaction {
  String id;
  String title;
  double amount;
  DateTime date;

  Transaction({required this.id, required this.title, required this.amount, required this.date});
}

class WorkMain extends StatefulWidget {
  @override
  _WorkMainState createState() => _WorkMainState();
}

class _WorkMainState extends State<WorkMain> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  Map<DateTime, List<Event>> _events = {};
  List<Transaction> transaction = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadExternalTransactions();
    _loadEvents();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
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
        _rangeStart = null;
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

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  void _loadExternalTransactions() {
    // 예시 외부 데이터
    List<Map<String, dynamic>> externalData = [
      {'id': 't1', 'title': 'new shoes', 'amount': 36.99, 'date': DateTime.utc(2024, 7, 1)},
      {'id': 't2', 'title': 'shoes', 'amount': 77.99, 'date': DateTime.utc(2024, 7, 8)},
    ];
    for (var data in externalData) {
      transaction.add(Transaction(
        id: data['id'],
        title: data['title'],
        amount: data['amount'],
        date: data['date'],
      ));
    }
  }

  void _loadEvents() {
    Map<DateTime, List<Event>> events = {};
    transaction.forEach((event) {
      DateTime date = event.date;
      String title = event.title;
      if (!events.containsKey(date)) {
        events[date] = [];
      }
      events[date]!.add(Event(date, title));
    });
    setState(() {
      _events = events;
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  void _updateEvents() {
    if (_selectedDay != null) {
      final newEvent = Event(_selectedDay!, "Updated Event");
      if (!_events.containsKey(_selectedDay)) {
        _events[_selectedDay!] = [];
      }
      setState(() {
        _events[_selectedDay]!.add(newEvent);
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    }
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkMain Page'),
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: DateTime.utc(2022, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
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
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(value[index].title),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateEvents,
        child: const Icon(Icons.update),
      ),
    );
  }
}

Iterable<DateTime> daysInRange(DateTime start, DateTime end) sync* {
  var day = start;
  final lastDay = end;

  while (day.isBefore(lastDay)) {
    yield day;
    day = day.add(const Duration(days: 1));
  }
  yield lastDay;
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

void main() {
  runApp(MaterialApp(
    home: WorkMain(),
  ));
}
