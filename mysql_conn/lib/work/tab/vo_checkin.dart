import 'package:mysql_conn/work/tab/vo_popular_checkin.dart';

class Checkin extends PopularCheckin {
  final String stockImagePath;

  Checkin(
      {required this.stockImagePath,
        required super.yesterdayClosePrice,
        required super.currentPrice,
        required super.stockName,
        required super.storeCode,
        required super.thisdate,
        required super.lastdate
      });
//
// double get todayPercentage => ((currentPrice - yesterdayClosePrice)/ yesterdayClosePrice*100).toPrecision(2);
//
// String get todayPercentageString =>"$sysbol$todayPercentage%";
//
// bool get isPlus => currentPrice > yesterdayClosePrice;
// bool get isSame => currentPrice == yesterdayClosePrice;
// bool get isMinus => currentPrice < yesterdayClosePrice;
//
// String get sysbol => isSame ? "" : isPlus ? "+" : "-";
//
// Color getPriceColor(BuildContext context) => isSame ? context.appColors.lessImportantText : isPlus ? context.appColors.plus : context.appColors.minus;
}