// 메모 페이지
// 앱의 상태를 변경해야하므로 StatefulWidget 상속
// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mysql_conn/memoPage/memoDB.dart';
import 'package:mysql_conn/memoPage/memoListProvider.dart';
import 'package:mysql_conn/work/checkinFragment.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../memoPage/memoDetailPage.dart';

class CheckinPage extends StatefulWidget {
  const CheckinPage({super.key});

  @override
  CheckinState createState() => CheckinState();
}

class CheckinState extends State<CheckinPage> with SingleTickerProviderStateMixin {
  // 검색어
  String searchText = '';
  String? _uName;
  late final tabController = TabController(length: 2, vsync: this);
  int currentIndex = 0;

  // 플로팅 액션 버튼을 이용하여 항목을 추가할 제목과 내용
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  // 메모 리스트 저장 변수
  List items = [];

  // 당일방문계획 저장 변수
  List itemsStore = [];

  // 메모 리스트 출력

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _uName = prefs.getString('uName');
    });
    print('로딩');
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

  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child:
      Container(//컨테이너 넣어서 백그라운드 컬러 강제적용
        color: Colors.white,//지금 바탕 화이트라 해놔야함 , 다크모드로 되면 안써도 됨
        child: Column(children: [
          title,
          //tabBar,
          if(currentIndex == 0)
            const Checkinfragment()
          else
          //const TodaysDiscoveryFragment()
            const Placeholder()

            //Placeholder();

        ],),
      ),
      ),
    ]);
  }


  Widget get title => Container(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Column(
              children: [
                Text('안녕하세요 : ${_uName}' ,style:TextStyle(fontSize: 25)),
                //height10,
                Row(
                  children: [
                    Text('담당매장 | 46개'),

                  ],
                ),
              ],
            ),
            SizedBox(width: 20,),
            Column(
              children: [
                Text('진행율 65%'),
              ],
            )
          ],
        ),

      ],
    ),
  );



}