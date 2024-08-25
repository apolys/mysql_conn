import 'package:mysql_conn/work/tab/vo_simple_stock.dart';
import 'package:mysql_conn/work/tab/stock_percentage_data_provider.dart';

class PopularCheckin extends SimpleStock with StockPercentageDataProvider{
  @override
  final int yesterdayClosePrice;
  @override
  final int currentPrice;
  final String thisdate;
  final String lastdate;
  final String storeCode;

  PopularCheckin(
      {required String stockName, required  this.storeCode, required  this.yesterdayClosePrice, required this.currentPrice,required this.thisdate,required this.lastdate, })
      : super(stockName);
}
