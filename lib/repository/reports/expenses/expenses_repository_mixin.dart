import 'package:intl/intl.dart';
import 'package:inventory_management/source.dart';

import '../../../blocs/filter/query_options.dart';
import '../../../blocs/report/models/annotation.dart';

class ExpensesRepositoryMixin {
  List<String> getItems(GroupBy groupBy, List<Map<String, dynamic>> data) {
    /*   if (groupBy == GroupBy.product) {
      return data.map((e) => (e['Product.name']) as String).toList();
    } */
    if (groupBy == GroupBy.category) {
      return data.map((e) => (e['ExpenseCategory.name']) as String).toList();
    }
    if (groupBy == GroupBy.day) {
      return data.map((e) {
        final date = e['ExpensesDocument.date.day'] as String;
        return FormatUtils.formatWithCustomFormatter(
            date, DateFormat('yyyy-MM-dd'));
      }).toList();
    }
    if (groupBy == GroupBy.month) {
      return data.map((e) {
        final date = e['ExpensesDocument.date.month'] as String;
        return FormatUtils.formatWithCustomFormatter(
            date, DateFormat('MMMM, yyyy'));
      }).toList();
    }
    if (groupBy == GroupBy.quarter) {
      return data.map((e) {
        final date = e['ExpensesDocument.date.quarter'] as String;
        return FormatUtils.formatToQuarters(date);
      }).toList();
    }
    if (groupBy == GroupBy.year) {
      return data.map((e) {
        final date = e['ExpensesDocument.date.year'] as String;
        return FormatUtils.formatWithCustomFormatter(date, DateFormat('yyyy'));
      }).toList();
    }
    return [];
  }

  Annotation getDimension(GroupBy groupBy, Map<String, dynamic> dimensionMap) {
    late final String dimensionKey;
    switch (groupBy) {
      case GroupBy.category:
        dimensionKey = 'ExpenseCategory.name';
        break;
      case GroupBy.product:
        throw "There is no GroupBy.product for expenses";
      case GroupBy.day:
        dimensionKey = 'ExpensesDocument.date.day';
        break;
      case GroupBy.month:
        dimensionKey = 'ExpensesDocument.date.month';
        break;
      case GroupBy.quarter:
        dimensionKey = 'ExpensesDocument.date.quarter';
        break;
      case GroupBy.year:
        dimensionKey = 'ExpensesDocument.date.year';
        break;
      default:
        throw 'Unknown groupBy';
    }

    return Annotation.fromMap(dimensionMap[dimensionKey]);
  }
}
