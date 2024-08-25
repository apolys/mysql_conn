import 'package:mysql_client/mysql_client.dart';

class DBHelper {
  // static const String _host = 'your-host';
  // static const int _port = 3306;
  // static const String _user = 'your-username';
  // static const String _password = 'your-password';
  // static const String _dbName = 'your-database';

  static const String _host = 'wordpress.cjvbtvfxtuvr.ap-northeast-2.rds.amazonaws.com';
  static const int _port = 3306;
  static const String _user = 'admin';
  static const String _password = 'themwp3114';
  static const String _dbName = 'marketpro';


  MySQLConnection? _connection;

  Future<void> _connect() async {
    if (_connection == null || !_connection!.connected) {
      _connection = await MySQLConnection.createConnection(
        host: _host,
        port: _port,
        userName: _user,
        password: _password,
        databaseName: _dbName,
      );
      await _connection!.connect();
    }
  }

  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic>? params]) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        await _connect();
        var result = await _connection!.execute(sql , (params ?? []) as Map<String, dynamic>?);
        // Ensure params is not null and is a List<dynamic>
        return result.rows.map((row) => row.assoc()).toList();
      } catch (e) {
        if (attempt == 2) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: 2));
      }
    }
    return [];
  }

  Future<void> close() async {
    await _connection?.close();
  }
}