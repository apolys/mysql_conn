import 'package:flutter/material.dart';

import 'package:mysql_conn/common/extension/snackbar_context_extension.dart';
import 'package:mysql_conn/work/tab/w_daily_list.dart';
import 'package:velocity_x/velocity_x.dart';

import '../common/common.dart';
import '../common/widget/w_empty_expanded.dart';
import '../memoPage/memoDB.dart';
class Checkinfragment extends StatefulWidget {
  const Checkinfragment({super.key});

  @override
  State<Checkinfragment> createState() => _CheckinfragmentState();
}

class _CheckinfragmentState extends State<Checkinfragment> {

  late DateTime _selectedDay;
  late String pDate;

  //Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    pDate = _selectedDay.toString().split(" ")[0];
    load_checkin_info();
  }

  @override

  Future<void> setMyCheckin() async {

    List vList = [];
    // DB에서 메모 정보 호출
    //   var result = await selectMemoALL();
    print('gps , daily table , 출근시간 저장 ${pDate}');
    var result = await setMyCheckinQuery(pDate);

    //print(result?.numOfRows);
  }

  Future<void> load_checkin_info() async {

    print('출퇴근시간 불러오기 ${pDate}');
    var result = await loadMyCheckinQuery(pDate);

    //print(result?.numOfRows);
  }


  Widget build(BuildContext context) {
    return Column(
      children: [
        getMyCheckin(context),
        height20,

        // getMytodayList(context),
        // height20,
        // getMyCheckinResult(context),
      ],
    );
  }

  Widget getMyCheckin(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    color: Colors.white70,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        height20,
        Line(
          color: Colors.orange,
        ),
        height10,
        '상태'.text.make(),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Column(
                children: [
                  '출근완료'.text.size(24).bold.make(),
                  '10:00'.text.size(20).bold.make(),
                ],
              ),
            ),
            SizedBox(width: 30,),
            '>'.text.size(24).bold.make(),
            emptyExpanded,
            ElevatedButton(
              onPressed: () {
                print('submit'); // ElevatedButton 클릭 시 콘솔에 'submit' 출력
                //context.showSnackbar("출근완료");
                //여기서 데이터 저장로직 적용
                //_getCurrentLocation();
                setMyCheckin();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("출근완료")),
                );

              },
              child: const Text('출근하기',
                  style: TextStyle(
                    fontSize: 30,
                  )),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16.0),
                foregroundColor: Colors.white,
                backgroundColor: Colors.greenAccent,
                // button의 모서리 둥근 정도를 바꿀 수 있음
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 0.0,
              ),
              // 버튼에 표시될 텍스트 설정
            ),
          ],
        ),
        height30,
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Column(
                children: [
                  '업무중'.text.size(24).bold.make(),
                  '--:--'.text.size(20).bold.make(),
                ],
              ),
            ),
            SizedBox(width: 30,),
            '>'.text.size(24).bold.make(),
            emptyExpanded,
            ElevatedButton(
              onPressed: () {
                print('submit'); // ElevatedButton 클릭 시 콘솔에 'submit' 출력
                //context.showSnackbar("출근완료");
              },
              child: const Text('퇴근하기',
                  style: TextStyle(
                    fontSize: 30,
                  )),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16.0),
                foregroundColor: Colors.white,
                backgroundColor: Colors.purpleAccent,
                // button의 모서리 둥근 정도를 바꿀 수 있음
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 0.0,
              ),
              // 버튼에 표시될 텍스트 설정
            ),
          ],
        ),
        height30,
        Line(
          color: Colors.orange,
        ),
        height10,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              DataTable(
                columns: const [
                  DataColumn(label: Text('일')),
                  DataColumn(label: Text('월')),
                  DataColumn(label: Text('화')),
                  DataColumn(label: Text('수')),
                  DataColumn(label: Text('목')),
                  DataColumn(label: Text('금')),
                  DataColumn(label: Text('토')),
                ],
                rows: const [
                  DataRow(cells: [
                    DataCell(Text('9')),
                    DataCell(Text('10')),
                    DataCell(Text('11')),
                    DataCell(Text('12')),
                    DataCell(Text('13')),
                    DataCell(Text('14')),
                    DataCell(Text('')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('')),
                    DataCell(Text('출근')),
                    DataCell(Text('출근')),
                    DataCell(Text('출근')),
                    DataCell(Text('출근')),
                    DataCell(Text('연차')),
                    DataCell(Text('')),
                  ]),
                ],
              )
            ],
          ),
        ),
        height10,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            '오늘방문예정'.text.size(24).bold.make(),
            emptyExpanded,
          ],
        ),
        height10,
        // SingleChildScrollView(
        //   scrollDirection: Axis.vertical,
        //   child: Row(
        //     children: [
        //       DataTable(
        //         columns: const [
        //         DataColumn(label: Text('no')),
        //         DataColumn(label: Text('매장명')),
        //         DataColumn(label: Text('방문시간')),
        //       ],
        //         rows: const [
        //         DataRow(cells: [
        //           DataCell(Text('1')),
        //           DataCell(Text('이마트 가양점')),
        //           DataCell(Text('방문전')),
        //         ]),
        //           DataRow(cells: [
        //             DataCell(Text('2')),
        //             DataCell(Text('이마트 가양점')),
        //             DataCell(Text('방문전')),
        //           ]),
        //           DataRow(cells: [
        //             DataCell(Text('3')),
        //             DataCell(Text('이마트 가양점')),
        //             DataCell(Text('방문전')),
        //           ]),
        //       ],
        //       )
        //     ],
        //   ),
        // ),
        //DailyList().pSymmetric(h: 20, v: 30),
        DailyList(),
      ],
    ),
  );

  // Future<void> _getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   print('location');
  //
  //   // 위치 서비스 활성화 확인
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // 위치 서비스가 비활성화된 경우
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("위치 서비스를 활성화해주세요.")),
  //     );
  //     return;
  //   }
  //
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // 위치 권한이 거부된 경우
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("위치 권한을 허용해주세요.")),
  //       );
  //       return;
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     // 위치 권한이 영구적으로 거부된 경우
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("위치 권한이 영구적으로 거부되었습니다.")),
  //     );
  //     return;
  //   }
  //
  //   // 위치 가져오기
  //   Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   setState(() {
  //     _currentPosition = position;
  //     _currentAddress = "${position.latitude}, ${position.longitude}";
  //   });
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("현재 위치: $_currentAddress")),
  //   );
  // }


}
