// ignore_for_file: constant_identifier_names
import '../source.dart';

enum Pages {
  sales_page,
  dashboard,
  reports_page,
  categories_page,
  purchases_page,
  expenses_page,
  stock_adjustment_page,
  items_page
}

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar(
      {Key? key, required this.title, required this.showDrawerCallback})
      : super(key: key);

  final VoidCallback showDrawerCallback;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        appBarTheme: Theme.of(context)
            .appBarTheme
            .copyWith(titleTextStyle: TextStyle(fontSize: 18.dw)),
      ),
      child: AppBar(
          elevation: 0, title: const Text('INVENTORY MANAGEMENT SYSTEM')),
    );
  }

  static final _appBar = AppBar();

  @override
  Size get preferredSize => _appBar.preferredSize;
}
