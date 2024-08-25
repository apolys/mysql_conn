import 'db_helper.dart';

class DataService {
  final DBHelper _dbHelper = DBHelper();

  Future<List<Map<String, dynamic>>> getDataForDate(DateTime date) async {
    String sql = 'SELECT * FROM your_table WHERE date = ?';
    List<Map<String, dynamic>> results = await _dbHelper.query(sql, [date.toIso8601String()]);
    return results;
  }

  Future<void> updateDataForDate(DateTime date, Map<String, dynamic> data) async {
    String sql = 'UPDATE your_table SET value = ? WHERE date = ?';
    await _dbHelper.query(sql, [data['value'], date.toIso8601String()]);
  }
}
