import '../source.dart';

class SearchPageBloc<T> extends Cubit<SearchPageState<T>> {
  SearchPageBloc(this.itemsService, this.categoriesService)
      : super(SearchPageState<T>.initial()) {
    itemsService.addListener(() => _handleItemUpdates());
    categoriesService.addListener(() => _handleCategoryUpdates());
  }

  final ItemsService itemsService;
  final CategoriesService categoriesService;

  var _options = [];

  void init() {
    var supp = state.supplements;
    emit(SearchPageState.loading(supp));
    if (T == Item) _options = itemsService.getAll();
    if (T == Category) _options = categoriesService.getAll();
    final options = _options.whereType<T>().toList();
    supp = supp.copyWith(options: options);
    emit(SearchPageState.content(supp));
  }

  void updateSearchQuery(String query) {
    var supp = state.supplements;
    emit(SearchPageState.loading(supp));
    final list = _options
        .where((e) => e.name.toLowerCase().startsWith(query.toLowerCase()))
        .whereType<T>()
        .toList();
    supp = supp.copyWith(options: list, query: query);
    emit(SearchPageState.content(supp));
  }

  void clearQuery() {
    var supp = state.supplements;
    emit(SearchPageState.loading(supp));
    final list = _options.whereType<T>().toList();
    supp = supp.copyWith(options: list, query: '');
    emit(SearchPageState.content(supp));
  }

  void updateId(String id) {
    var supp = state.supplements;
    emit(SearchPageState.loading(supp));
    if (T == Item) itemsService.updateId(id);
    if (T == Category) categoriesService.updateId(id);
    emit(SearchPageState.success(supp));
  }

  _handleItemUpdates() {
    var supp = state.supplements;
    emit(SearchPageState.loading(supp));
    final items = itemsService.getItemList.whereType<T>().toList();
    supp = supp.copyWith(options: items);
    emit(SearchPageState.content(supp));
  }

  _handleCategoryUpdates() {
    var supp = state.supplements;
    emit(SearchPageState.loading(supp));
    final categories =
        categoriesService.getCategoryList.whereType<T>().toList();
    supp = supp.copyWith(options: categories);
    emit(SearchPageState.content(supp));
  }
}
