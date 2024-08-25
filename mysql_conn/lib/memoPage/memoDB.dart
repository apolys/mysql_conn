
import 'dart:ffi';

import 'package:image_picker/image_picker.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:mysql_conn/config/mySqlconnector.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 모든 메모 보기
Future<IResultSet?> selectMemoALL() async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  //final String? token = prefs.getString('loginCheck');
  String? _uName = prefs.getString('uName');
  // DB에 저장된 메모 리스트
  IResultSet result;

  print('token 확인');
  print(token);

  print('uname 확인');
  print(_uName);
  // 유저의 모든 메모 보기
  try {
    result = await conn.execute(
        "SELECT m.id, userIndex, u.userName, memoTitle, memoContent, createDate, updateDate FROM memo AS m LEFT JOIN users AS u ON m.userIndex = u.id WHERE userIndex = :token",
        {"token": token});
    if (result.numOfRows > 0) {
      return result;
    }
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
  // 메모가 없으면 null 값 반환
  return null;
}

// 메모 작성
Future<String?> addMemo(String title, String content) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  // final String? uid = prefs.getString('loginCheck');

  print('token value1');
  print(token);
  // print('uid value');
  // print(uid);

  // 쿼리 수행 결과 저장 변수
  IResultSet? result;

  // 유저의 아이디를 저장할 변수
  String? userName;

  // 메모 추가
  try {
    // 유저 이름 확인
    result = await conn.execute(
      "SELECT userName FROM users WHERE id = :token",
      {"token": token},
    );

    // 유저 이름 저장
    for (final row in result.rows) {
      userName = row.colAt(0);
    }

    // 메모 추가
    result = await conn.execute(
      "INSERT INTO memo (userIndex, memoTitle, memoContent) VALUES (:userIndex, :title, :content)",
      {"userIndex": token, "title": title, "content": content},
    );
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
  print('add memo');
  print(token);// 예외처리용 에러코드 '-1' 반환
  return '-1';
}

// 메모 수정
Future<void> updateMemo(String id, String title, String content) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  // 쿼리 수행 결과 저장 변수
  IResultSet? result;

  // 메모 수정
  try {
    await conn.execute(
        "UPDATE memo SET memoTitle = :title, memoContent = :content where id = :id and userIndex = :token",
        {"id": id, "token": token, "title": title, "content": content});
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
}

// 특정 메모 조회
Future<IResultSet?> selectMemo(String id) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  // 쿼리 수행 결과 저장 변수
  IResultSet? result;

  // 메모 수정
  try {
    result = await conn.execute(
        "SELECT m.id, userIndex, u.userName, memoTitle, memoContent, createDate, updateDate FROM memo AS m LEFT JOIN users AS u ON m.userIndex = u.id WHERE userIndex = :token and m.id = :id",
        {"token": token, "id": id});
    return result;
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }

  return null;
}

// 특정 메모 삭제
Future<void> deleteMemo(String id) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 메모 수정
  try {
    await conn.execute("DELETE FROM memo WHERE id = :id", {"id": id});
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
}





// 휴가등록
Future<String?> addVacation(String title, String content , DateTime vDate) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  // final String? uid = prefs.getString('loginCheck');

  print('token value1');
  print(token);

  // 쿼리 수행 결과 저장 변수
  IResultSet? result;
  // 유저의 아이디를 저장할 변수
  String? userName;
  // 메모 추가
  try {
    // 유저 이름 확인
    result = await conn.execute(
      "SELECT userName FROM users WHERE id = :token",
      {"token": token},
    );

    // 유저 이름 저장
    for (final row in result.rows) {
      userName = row.colAt(0);
    }

    // 메모 추가
    result = await conn.execute(
      "INSERT INTO vacation (userIndex, vDate, vTitle, vContent) VALUES (:userIndex, :vDate , :title, :content)",
      {"userIndex": token, "vDate": vDate, "title": title, "content": content},
    );
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
  print('add vacation');
  print(token);// 예외처리용 에러코드 '-1' 반환
  return '-1';
}

//휴가검색
Future<IResultSet?> selectVacationALL(String pDate) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  String y = pDate.substring(0,4);
  String m = pDate.substring(5,7);

  String TargetDate = "${y}-${m}%";

  print ("selectVacationALL : ${pDate}");

  // DB에 저장된 메모 리스트
  IResultSet result;

  // 유저의 모든 메모 보기
  try {
    // result = await conn.execute(
    //     "SELECT m.id, userIndex, u.userName, vTitle, vContent, vDate , createDate, updateDate FROM vacation AS m LEFT JOIN users AS u ON m.userIndex = u.id WHERE userIndex = :token and year =:year and month =:month",
    //     {"token": token, "year": y , "month" :m});
    result = await conn.execute(
        "SELECT m.id, userIndex, u.userName, vTitle, vContent, vDate , createDate, updateDate FROM vacation AS m LEFT JOIN users AS u ON m.userIndex = u.id WHERE userIndex = :token and vDate LIKE :pDate ",
        {"token": token, "pDate": TargetDate});
    await conn.execute("COMMIT;");
    print("업데이트 쿼리 실행결과 확인 : ${result.numOfRows}");
    if (result.numOfRows > 0) {

      print("쿼리성공?");
      print(result);
      return result;
    }
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
  // 메모가 없으면 null 값 반환
  return null;
}




// 휴가등록
Future<String?> updateListQuery(List dateList) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  // 쿼리 수행 결과 저장 변수
  IResultSet? result;

  //배열 만들어서 돌려야

  DateTime currentTime = DateTime.now();
  try {
    for(int i = 0 ; i < dateList.length ; i++) {

        // 데이터 확인
        String mDate = dateList[i].toString().split(" ")[0];
        String y = mDate.substring(0,4);
        String m = mDate.substring(5,7);
        String d = mDate.substring(8,10);

        result = await conn.execute(
          "SELECT * FROM mPlan WHERE userid = :token and visitdate =:visitdate",
          {"token": token, "visitdate": mDate},
        );
        // result 0보다  크면
        if (result.numOfRows > 0) {
            //값 있으면 아무것도  안함
          print(mDate);
        }else{
        //배열만큼 돌면서
        // plan 저장
          result = await conn.execute(
            "INSERT INTO mPlan (year , month , day , visitdate , plan , brand , userid , active) VALUES (:y, :m , :d, :visitdate , :plan , :brand , :token , :active)",
            {
              "y": y,
              "m": m,
              "d": d,
              "visitdate": mDate,
              "plan": "1",
              "brand": "",
              "token": token,
              "active": "1"
            },
          );

          print("매장방문계획 업데이트");
          print(result);
        };
        // plan 업데이트
        // result = await conn.execute(
        //     "UPDATE mPlan SET modidate='currentTime' where visitdate = :visitdate and userid = :token",
        //     {"visitdate": visitdate, "token": token, "currentTime": currentTime});

    }

  } catch (e) {
  print('Error : $e');
  } finally {
  await conn.close();
  }
  // 예외처리용 에러코드 '-1' 반환
  return '-1';
}


//plan검색
Future<IResultSet?> selectPlanALL(String pDate) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  String y = pDate.substring(0,4);
  String m = pDate.substring(5,7);

  // DB에 저장된 메모 리스트
  IResultSet result;
  print("검색기준연월 ${token}");
  print("날짜값  확인 ${pDate}");

  // 유저의 모든 메모 보기
  try {
    result = await conn.execute(
        "SELECT id , year , month , day , visitdate , userid , plan  FROM mPlan WHERE userid = :token and year =:year and month =:month" ,
        {"token": token , "year": y , "month" :m});
    print(result);
    if (result.numOfRows > 0) {

      print(result);
      return result;
    }
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
  // 메모가 없으면 null 값 반환
  return null;
}

//selectCallPlanALL


// 출근하기 : checkinFragment
Future<String?> setMyCheckinQuery(String vDate) async {

  // // 현재 위치 가져오기
  // Position position = await getCurrentLocation();

  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  // 쿼리 수행 결과 저장 변수
  IResultSet? result;

  // 유저의 아이디를 저장할 변수
  String? input_user;
  String? search_value;

  // double? lat = position.latitude;
  // double? lon = position.longitude;

  double? lat = 11;
  double? lon = 12;

  DateTime _toDay = DateTime.now();
  //출근 값 있는지 확인
  try {
    // 유저 이름 확인
    result = await conn.execute(
      "SELECT id , year , month , day , visitdate , plan , actual , starttime , endtime , inLat , inLon , brand , userid FROM mPlan WHERE userid = :token and visitdate = :visitdate",
      {"token": token , "visitdate" : vDate},
    );

    // 유저 이름 저장
    for (final row in result.rows) {
      input_user = row.colAt(0);
      search_value = row.colByName('id');
    }

    // 출근등록
    result = await conn.execute(
      "UPDATE  mPlan SET  starttime =:time_in, inLat =:inLat , inLon =:inLon , endtime =:time_out , actual =:actual where id =:search_value;",
      { "time_in": _toDay, "time_out": "" ,"inLat": lat , "inLon" : lon, "actual" : "1" ,"search_value" :search_value,},
    );

    //"UPDATE memo SET memoTitle = :title, memoContent = :content where id = :id and userIndex = :token",
    //         {"id": id, "token": token, "title": title, "content": content});
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }

  //값 있으면 값 있음 리턴(이미 출근)



  //값 없으면 출근

  print('save checkin');

  DateTime currentTime = DateTime.now();


}


// 출퇴근 데이터 불러오기 : checkinFragment
Future<String?> loadMyCheckinQuery(String vDate) async {

  // // 현재 위치 가져오기
  // Position position = await getCurrentLocation();

  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  // 쿼리 수행 결과 저장 변수
  IResultSet? result;

  // 유저의 아이디를 저장할 변수
  String? input_user;
  String? search_value;

  // double? lat = position.latitude;
  // double? lon = position.longitude;

  double? lat = 11;
  double? lon = 12;

  DateTime _toDay = DateTime.now();
  //출근 값 있는지 확인
  try {
    // 유저 이름 확인
    result = await conn.execute(
      "SELECT id , year , month , day , visitdate , plan , actual , starttime , endtime , inLat , inLon , brand , userid FROM mPlan WHERE userid = :token and visitdate = :visitdate",
      {"token": token , "visitdate" : vDate},
    );

  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
  //값 없으면 출근

  print('load checkin');

}


// 출근하기 : checkinFragment
Future<String?> addVisitStore(String title, String content , DateTime vDate) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  // 쿼리 수행 결과 저장 변수
  IResultSet? result;

  //배열 만들어서 돌려야

  print('save add store');

  DateTime currentTime = DateTime.now();

  // 유저의 아이디를 저장할 변수
  String? userName;
  // 메모 추가
  try {
    // 유저 이름 확인
    result = await conn.execute(
      "SELECT userName FROM users WHERE id = :token",
      {"token": token},
    );

    // 유저 이름 저장
    for (final row in result.rows) {
      userName = row.colAt(0);
    }

    // 메모 추가
    result = await conn.execute(
      "INSERT INTO vacation (userIndex, vDate, vTitle, vContent) VALUES (:userIndex, :vDate , :title, :content)",
      {"userIndex": token, "vDate": vDate, "title": title, "content": content},
    );
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
  print('add vacation');
  print(token);// 예외처리용 에러코드 '-1' 반환
  return '-1';

}

// 방문결과 입력 : checkin_detail

Future<String?> updateVisitResult(String task, String issue , List<XFile?> images , String storeName , String vDate , int indexno) async {
  // MySQL 접속 설정
  final conn = await dbConnector();

  // 유저 식별 정보 호출
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  // 쿼리 수행 결과 저장 변수
  IResultSet? result;

  //배열 만들어서 돌려야

  print('save add store');

  DateTime currentTime = DateTime.now();

  // 유저의 아이디를 저장할 변수
  String? userName;
  // 메모 추가
  try {
    // 유저 이름 확인
    result = await conn.execute(
      "SELECT userName FROM users WHERE id = :token",
      {"token": token},
    );

    // 유저 이름 저장
    for (final row in result.rows) {
      userName = row.colAt(0);
    }

    // 메모 추가
    // result = await conn.execute(
    //   "INSERT INTO vacation (userIndex, vDate, vTitle, vContent) VALUES (:userIndex, :vDate , :title, :content)",
    //   {"userIndex": token, "vDate": vDate, "title": title, "content": content},
    // );
  } catch (e) {
    print('Error : $e');
  } finally {
    await conn.close();
  }
  print('add vacation');
  print(token);// 예외처리용 에러코드 '-1' 반환
  return '-1';

}

