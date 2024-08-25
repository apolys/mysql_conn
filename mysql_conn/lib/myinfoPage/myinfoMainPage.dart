// 메모 페이지
// 앱의 상태를 변경해야하므로 StatefulWidget 상속
// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mysql_conn/memoPage/memoDB.dart';
import 'package:mysql_conn/memoPage/memoListProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:settings_ui/settings_ui.dart';

class MyInfoPage extends StatefulWidget {
  const MyInfoPage({super.key});

  @override
  MyInfoState createState() => MyInfoState();
}

class MyInfoState extends State<MyInfoPage> {
  // 검색어
  String searchText = '';
  String? _uName;
  bool vibration = false;


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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white70,
      body:
      SafeArea(
        child: SettingsList(

            // lightTheme: SettingsThemeData(
            //   settingsListBackground: Theme.of(context).scaffoldBackgroundColor,
            //     settingsTileTextColor: Colors.black,
            //     tileDescriptionTextColor: Colors.red,
            //
            // ),
            // darkTheme: SettingsThemeData(
            //   settingsListBackground: Theme.of(context).scaffoldBackgroundColor,
            //   settingsTileTextColor: Colors.black,
            //   tileDescriptionTextColor: Colors.red,
            //
            // ),
            applicationType: ApplicationType.both,
            //출처: https://devfart.tistory.com/entry/Flutter-Setting-화면-만들기-UI-코드-SettingUI-커스텀-하여-사용하기-switch [방구개발:티스토리]
        
          sections: [
            SettingsSection(
              title: Text('사용자 아이디 : ${_uName}' ,style:TextStyle(fontSize: 25)),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (context) {},
                  title: Text('비밀번호 변경'),
                  leading: Icon(CupertinoIcons.wrench),
                  //value: Text('Standard'),
                  description: Text(
                    '비밀번호는 문자와 숫자의 조합으로 8자리 이상입니다 '
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text('내 정보'),
              tiles: [
                SettingsTile.navigation(
                  onPressed: (context) {},
                  title: Text('내 매장관리'),
                  leading: Icon(Icons.storefront_outlined),
                  value: Text('총40개'),
                ),
                SettingsTile.navigation(
                  onPressed: (context) {},
                  title: Text('연차관리'),
                  leading: Icon(Icons.date_range_rounded),
                  value: Text('발생:15 , 사용:8 , 잔여:7'),

                ),
                SettingsTile.navigation(
                  onPressed: (context) {},
                  title: Text('근무기간'),
                  leading: Icon(Icons.timer),
                  value: Text('시작:2021.1.2 (재직중)'),

                ),
                SettingsTile.navigation(
                  onPressed: (context) {},
                  title: Text('근무형태'),
                  leading: Icon(Icons.type_specimen_outlined),
                  value: Text('정규직 FM'),

                ),
                SettingsTile.navigation(
                  onPressed: (context) {},
                  title: Text('담당업체 정보'),
                  leading: Icon(Icons.info_outline),
                  value: Text('로레알'),

                ),
              ],
            ),
            // SettingsSection(
            //   title: Text('IAD DEVELOPER APP TESTING'),
            //   tiles: [
            //     SettingsTile.navigation(
            //       title: Text('Fill Rate'),
            //     ),
            //     SettingsTile.navigation(
            //       title: Text('Add Refresh Rate'),
            //     ),
            //     SettingsTile.switchTile(
            //       onToggle: (_) {},
            //       initialValue: false,
            //       title: Text('Unlimited Ad Presentation'),
            //     ),
            //   ],
            // ),
            // SettingsSection(
            //   title: Text('STATE RESTORATION TESTING'),
            //   tiles: [
            //     SettingsTile.switchTile(
            //       onToggle: (_) {},
            //       initialValue: false,
            //       title: Text(
            //         'Fast App Termination',
            //       ),
            //       description: Text(
            //         'Terminate instead of suspending apps when backgrounded to '
            //             'force apps to be relaunched when tray '
            //             'are foregrounded.',
            //       ),
            //     ),
            //   ],
            // ),
            // SettingsSection(
            //   title: Text('General'),
            //   tiles: [
            //     SettingsTile.navigation(
            //       title: Text('Abstract settings screen'),
            //       leading: Icon(CupertinoIcons.wrench),
            //       description:
            //       Text('UI created to show plugin\'s possibilities'),
            //       onPressed: (context) {
            //         Navigator.push(
            //           context,
            //           CupertinoPageRoute(
            //             builder: (_) => Container(),
            //           ),
            //         );
            //       },
            //     )
            //   ],
            // ),
            // // SettingsSection(
            // //   title: Text('APPEARANCE'),
            // //   tiles: [
            // //     SettingsTile.switchTile(
            // //       onToggle: (value) {
            // //         setState(() {
            // //           darkTheme = value;
            // //         });
            // //       },
            // //       initialValue: darkTheme,
            // //       title: Text('Dark Appearance'),
            // //     ),
            // //   ],
            // // ),
            // SettingsSection(
            //   title: Text('Common'),
            //   tiles: <SettingsTile>[
            //     SettingsTile.navigation(
            //       leading: Icon(Icons.language),
            //       title: Text('Language'),
            //       value: Text('English'),
            //     ),
            //     SettingsTile.switchTile(
            //       onToggle: (value) {},
            //       initialValue: true,
            //       leading: Icon(Icons.format_paint),
            //       title: Text('Enable custom theme'),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
        //출처: https://devfart.tistory.com/entry/Flutter-Setting-화면-만들기-UI-코드-settingsui [방구개발:티스토리]
    );
  }
}
