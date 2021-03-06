import 'package:inventory_management/blocs/dashboard/dashboard_bloc.dart';
import 'package:inventory_management/source.dart';
import 'package:inventory_management/widgets/report_title.dart';

class ProfitLossReport extends StatelessWidget {
  const ProfitLossReport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profitData = BlocProvider.of<DashBoardBloc>(context).state.profitData;
    return Column(
      children: [
        const ReportTitle(title1: 'component', title2: 'amount'),
        _buildValue('Sales', profitData.sales),
        _buildValue('Cost of Goods Sold', profitData.costOfSales,
            isOutflow: true),
        const AppDivider.zeroMargin(
            color: AppColors.onBackground2, height: 1.5),
        _buildValue('Gross Profit', profitData.grossProfit),
        _buildValue('Less Expenses', profitData.expenses, isOutflow: true),
        _buildValue('Less Stock Write-off costs', profitData.stockWriteOffs,
            isOutflow: true),
        const AppDivider.zeroMargin(color: AppColors.onBackground2, height: 2),
        _buildValue('NET PROFIT', profitData.getProfit, isTotal: true),
      ],
    );
  }

  _buildValue(String title, double value,
      {bool isTotal = false, bool isOutflow = false}) {
    final amount = Utils.convertToMoneyFormat(value);
    return SizedBox(
      height: 40.dh,
      child: Row(
        children: [
          Expanded(
              child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15.dw),
                  child: AppText(title, size: 15.dw))),
          Expanded(
              child: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 15.dw),
                  child: AppText(isOutflow ? '( $amount )' : amount,
                      size: 14.dw,
                      weight: isTotal ? FontWeight.bold : FontWeight.w500))),
        ],
      ),
    );
  }
}
