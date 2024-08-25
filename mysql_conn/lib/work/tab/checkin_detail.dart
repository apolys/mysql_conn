import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:mysql_conn/memoPage/memoDB.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'vo_checkin.dart'; // Checkin 클래스 import
import 'package:http/http.dart' as http; // HTTP 요청을 위한 패키지

class CheckinDetailPage extends StatefulWidget {
  final Checkin checkin;

  CheckinDetailPage({required this.checkin});

  @override
  _CheckinDetailPageState createState() => _CheckinDetailPageState();
}

class _CheckinDetailPageState extends State<CheckinDetailPage> {
  final TextEditingController _tasksController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();
  final List<XFile?> _images = [null, null, null]; // 3장의 이미지를 저장
  final ImagePicker _picker = ImagePicker();
  bool _hasCheckedIn = false; // 출근 여부를 관리할 상태 변수
  String _checkinTime = ''; // 출근 시간 저장 변수

  late DateTime _selectedDay;
  late String pDate;

  String contentType = ''; // 이미지 파일의 타입
  bool isImageUpdated = false; // 이미지 업로드 여부


  final bucketUrl = "https://marketpro-file.s3.ap-northeast-2.amazonaws.com";
//marketpro-file
//arn:aws:s3:::marketpro-file
  String objectKey = ''; // Presigned URL 생성 시 filename 저장 예정

  @override
  void initState() {
    super.initState();
    _loadCheckinData();

    _selectedDay = DateTime.now();
    pDate = _selectedDay.toString().split(" ")[0];
  }

  Future<void> _loadCheckinData() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCheckedIn = prefs.getBool('hasCheckedIn_${widget.checkin.name}') ?? false;
    final checkinTime = prefs.getString('checkinTime_${widget.checkin.name}') ?? '';

    setState(() {
      _hasCheckedIn = hasCheckedIn;
      _checkinTime = checkinTime;
    });
  }

  Future<void> _saveCheckinData(bool hasCheckedIn, String checkinTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCheckedIn_${widget.checkin.name}', hasCheckedIn);
    await prefs.setString('checkinTime_${widget.checkin.name}', checkinTime);
  }

  Future<void> _pickImage(int index) async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _images[index] = pickedImage;
      });
    }
  }

  void _startCheckin() {
    setState(() {
      _hasCheckedIn = true;
      _checkinTime = DateTime.now().toLocal().toString();
    });
    _saveCheckinData(true, _checkinTime);
  }

  void _submit() {
    // 등록 버튼 클릭 시 동작할 코드
    // 예: 서버에 데이터를 전송하거나 로컬에 저장

    // 임시로 콘솔에 출력
    print('Tasks: ${_tasksController.text}');
    print('Issue: ${_issueController.text}');
    _images.forEach((image) {
      if (image != null) {
        print('Image Path: ${image.path}');
      }
    });

    uploadMultipleImagesToS3(_images);

    int indexno = 1;

    updateVisitResult(_tasksController.text,_issueController.text,_images,widget.checkin.name,pDate,indexno);

    // 성공 메시지나 에러 처리를 추가할 수 있습니다.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('등록되었습니다.')),
    );

    // 페이지를 닫을 수 있습니다.
    Navigator.pop(context);
  }


  Future<void> uploadMultipleImagesToS3(List<XFile?> images) async {
    for (var image in images) {
      if (image != null) {
        try {
          // MIME 타입 가져오기
          String contentType = lookupMimeType(image.path) ?? 'application/octet-stream';

          // 유니크한 파일명 생성 (UUID + 확장자)
          var uuid = Uuid();
          DateTime now = DateTime.now();
          String year = DateFormat('yyyy').format(now); // 예: "2024"
          String monthDay = DateFormat('MMdd').format(now); // 예: "0822"
          final String uniqueFilename = '${uuid.v4()}.${image.path.split('.').last}';
          final String objectKey = '$year/$monthDay/$uniqueFilename';
          final String objectKey2 = 'dailyPhoto/$year/$monthDay/';
          final String objectKey3 = '$uniqueFilename';
          final String filename = Uri.encodeComponent(objectKey3);

          // 각 이미지에 대해 Presigned URL 요청
          // final url = Uri.parse(
          //     'https://toel6t9v7d.execute-api.ap-northeast-2.amazonaws.com/dev/getPresignedUrl?filename=$filename&contentType=$contentType');

          final url = Uri.parse(
              'https://toel6t9v7d.execute-api.ap-northeast-2.amazonaws.com/dev/getPresignedUrl?filename=$objectKey2$filename&contentType=$contentType');
          final response = await http.get(url);

          print ("objectKey : ${objectKey}");
          print ("url : ${url}");

          final Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData['statusCode'] == 200) {
            final Map<String, dynamic> bodyData = json.decode(responseData['body']);
            final String presignedUrl = bodyData['url'];

            // 이미지 파일을 바이트로 읽기
            final bytes = await image.readAsBytes();

            // S3에 이미지 업로드
            final uploadImageResponse = await http.put(
              Uri.parse(presignedUrl),
              headers: {
                'Content-Type': contentType,
              },
              body: bytes,
            );

            if (uploadImageResponse.statusCode == 200) {
              final String objectUrl = '$bucketUrl/$objectKey';

              //await _createOrUpdateData(objectUrl); // 업로드된 파일 정보 처리

              print('Image uploaded successfully: $objectUrl');
            } else {
              print('Failed to upload image: ${uploadImageResponse.body}');
            }
          } else {
            print('Failed to get presigned URL: ${response.body}');
          }
        } catch (e) {
          print('Failed to upload image: $e');
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.checkin.storeCode),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(widget.checkin.stockImagePath, width: 50,),
              SizedBox(height: 16),
              Text(
                'Store Name: ${widget.checkin.name}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _startCheckin,
                    child: Text('매장업무 시작'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 퇴근 버튼 클릭 시 동작
                      print('Check-in Ended');
                    },
                    child: Text('매장업무 종료'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // 출근 시작 버튼 클릭 전 안내 메시지와 이미지
              if (!_hasCheckedIn) ...[
                Center(
                  child: Column(
                    children: [
                      //Image.asset('assets/images/checkin_info.png', height: 150), // 안내 이미지
                      SizedBox(height: 16),
                      Text(
                        '출근 시작을 누른 후 업무 결과를 작성할 수 있습니다.',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
              // 출근 시작 상태와 시간 표시
              if (_hasCheckedIn) ...[
                Text(
                  '출근 시작 시간: ${_checkinTime.substring(0,16)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  '주요 업무',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _tasksController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '주요 업무를 입력하세요',
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '매장 사진 3장',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _images[index] != null
                            ? Image.file(
                          File(_images[index]!.path),
                          height: 100,
                          fit: BoxFit.cover,
                        )
                            : ElevatedButton(
                          onPressed: () => _pickImage(index),
                          child: Text('사진 추가 ${index + 1}'),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 16),
                Text(
                  '매장이슈',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _issueController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '매장이슈를 입력하세요',
                  ),
                ),
                SizedBox(height: 16),
              ],
              // 등록 버튼 추가
              Center(
                child: ElevatedButton(
                  onPressed: _hasCheckedIn ? _submit : null, // 출근 시작 후만 활성화
                  child: Text('등록'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20), backgroundColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
