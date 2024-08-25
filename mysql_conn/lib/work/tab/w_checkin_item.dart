
import 'package:flutter/material.dart';
import 'package:mysql_conn/common/extension/context_extension.dart';
import 'package:mysql_conn/work/tab/checkin_detail.dart';
import 'package:mysql_conn/work/tab/vo_checkin.dart';

import '../../../../../common/common.dart';
import '../../common/widget/w_empty_expanded.dart';

class CheckinItem extends StatelessWidget {
  final Checkin checkin;
  const CheckinItem(this.checkin,{super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: (){
          // 클릭 시 새로운 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckinDetailPage(checkin: checkin),
            ),
          );
        },
        child: Row(
          children: [
            Image.asset(checkin.stockImagePath, width: 50,),
            width20,
            (checkin.name).text.size(18).bold.make(),
            emptyExpanded,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
        //(오늘의 가격 - 전날의 가격) %
                //checkin.todayPercentageString.text.color(checkin.getPriceColor(context)).make(),
                //"${checkin.currentPrice.toComma()}원".text.color(context.appColors.lessImportantText).make(),
                checkin.thisdate.text.make(),
                "3회".text.make(),
                checkin.lastdate.text.make(),
                //"3회".text.color(context.appColors.lessImportantText).make(),
                //checkin.lastdate.text.color(context.appColors.lessImportantText).make(),
              ],
            )
          ],
        ),
      ),);
  }
}
