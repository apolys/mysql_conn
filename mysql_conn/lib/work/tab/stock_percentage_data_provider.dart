
import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:mysql_conn/common/extension/context_extension.dart';

abstract mixin class StockPercentageDataProvider{

  int get currentPrice;
  int get yesterdayClosePrice;

  double get todayPercentage => ((currentPrice - yesterdayClosePrice)/ yesterdayClosePrice*100).toPrecision(2);

  String get todayPercentageString =>"$sysbol$todayPercentage%";

  bool get isPlus => currentPrice > yesterdayClosePrice;
  bool get isSame => currentPrice == yesterdayClosePrice;
  bool get isMinus => currentPrice < yesterdayClosePrice;

  String get sysbol => isSame ? "" : isPlus ? "+" : "-";

  Color getPriceColor(BuildContext context) => isSame ? context.appColors.lessImportantText : isPlus ? context.appColors.plus : context.appColors.minus;
}