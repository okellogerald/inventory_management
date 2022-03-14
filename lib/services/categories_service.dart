import '../source.dart';
import 'constants.dart';
import 'network_service.dart';
import 'package:http/http.dart' as http;

class CategoriesService extends NetworkService<Category> {
  static bool _isExpenses = false;

  static initType(bool isExpenses) {
    _isExpenses = isExpenses;
    log('isExpenses: $isExpenses');
  }

  ///Gets all categories from the server
  Future<void> init() async => await getAll();

  @override
  Future<List<Category>> getAll([bool isRefreshing = false]) async {
    if (super.getList.isNotEmpty) return super.getList;

    const expenseCategoriesUrl = root + 'expenseCategory';
    const productCategoriesUrl = root + 'category';
    final response1 = await http.get(Uri.parse(expenseCategoriesUrl));
    final response2 = await http.get(Uri.parse(productCategoriesUrl));

    final result1 = json.decode(response1.body);
    final result2 = json.decode(response2.body);
    final categories1 = _addCategoriesFrom(result1, 'Expenses');
    final categories2 = _addCategoriesFrom(result2, 'Products');

    categories1.addAll(categories2);
    super.updateAttributes(categories1);
    return categories1;
  }

  @override
  Future<void> add(var item) async {
    final url = root + (_isExpenses ? 'expenseCategory' : 'category');
    final response = await http.post(Uri.parse(url),
        body: json.encode(item.createJson()), headers: headers);

    log('response body')
;
    log(response.body.toString());
    final jsonCategory = json.decode(response.body);
    final type = _isExpenses ? 'Expenses' : 'Products';

    final list = super.getList;
    list.add(Category.fromJson(jsonCategory, type));
    super.updateAttributes(list, currentId: item.id);
    notifyListeners();
  }

  @override
  Future<void> edit(var item, [String? url]) async {
    final url = root + (_isExpenses ? 'expenseCategory' : 'category');
    await super.edit(item, url);
  }

  @override
  Future<void> delete(String id, [String? url]) async {
    final url = root + (_isExpenses ? 'expenseCategory' : 'category');
    await super.delete(id, url);
  }

  List<Category> _addCategoriesFrom(var result, String type) {
    final list = <Category>[];
    for (var item in result) {
      final index = list.indexWhere((e) => e.id == item['id']);
      if (index == -1) {
        list.add(Category.fromJson(item, type));
      }
    }
    return list;
  }
}
