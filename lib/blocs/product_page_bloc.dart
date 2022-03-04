import '../source.dart';

class ProductPageBloc extends Cubit<ProductPageState> with ServicesInitializer {
  ProductPageBloc(this.productsService, this.categoriesService,
      this.openingStockItemsService)
      : super(ProductPageState.initial()) {
    productsService.addListener(() => _handleproductUpdates());
    categoriesService.addListener(() => _handleCategoryUpdates());
  }

  final ProductsService productsService;
  final CategoriesService categoriesService;
  final OpeningStockItemsService openingStockItemsService;

  Category? get getSelectedCategory {
    final id = state.supplements.categoryId;
    final category = categoriesService.getById(id);
    return category;
  }

  void init({Product? product, String? categoryId}) async {
    var supp = state.supplements;
    emit(ProductPageState.loading(supp));
    await initServices(
        productsService: productsService,
        categoriesService: categoriesService,
        openingStockItemsService: openingStockItemsService);
    var productList = productsService.getList;
    final categories = categoriesService.getList;

    if (categoryId != null) {
      productList =
          productList.where((e) => e.categoryId == categoryId).toList();
      supp = supp.copyWith(categoryId: categoryId);
    }

    supp = supp.copyWith(productList: productList, categoryList: categories);

    if (product != null) {
      final openingStockItem =
          openingStockItemsService.getByProductId(product.id);
      supp = supp.copyWith(
          unit: product.unit,
          unitPrice: product.unitPrice.toString(),
          name: product.name,
          categoryId: product.categoryId,
          id: product.id,
          barcode: product.barcode,
          openingStockItem: openingStockItem ?? supp.openingStockItem,
          unitValue: openingStockItem?.unitValue.toString() ?? supp.unitValue,
          quantity: openingStockItem?.quantity.toString() ?? supp.quantity);
    }
    emit(ProductPageState.content(supp));
  }

  void updateAttributes(
      {String? name,
      String? categoryId,
      String? unit,
      String? barcode,
      String? unitValue,
      DateTime? date,
      String? unitPrice,
      String? quantity}) {
    var supp = state.supplements;
    emit(ProductPageState.loading(supp));

    supp = supp.copyWith(
        name: name?.trim() ?? supp.name,
        unit: unit?.trim() ?? supp.unit,
        categoryId: categoryId ?? supp.categoryId,
        unitValue: unitValue?.trim() ?? supp.unitValue,
        openingStockItem: supp.openingStockItem.copyWith(date: date),
        unitPrice: unitPrice?.trim() ?? supp.unitPrice,
        quantity: quantity?.trim() ?? supp.quantity,
        barcode: barcode?.trim() ?? supp.barcode);
    emit(ProductPageState.content(supp));
  }

  void saveProduct() async {
    _validate();

    var supp = state.supplements;
    final hasErrors = InputValidation.checkErrors(supp.errors);
    if (hasErrors) return;

    final product = Product(
        id: Utils.getRandomId(),
        categoryId: supp.categoryId,
        unit: supp.unit,
        name: supp.name,
        barcode: supp.barcode,
        unitPrice: double.parse(supp.unitPrice));
    await productsService.addProduct(product);

    if (supp.hasAddedOpeningStockDetails) {
      final openingStockItem = OpeningStockItem(
          id: Utils.getRandomId(),
          date: supp.openingStockItem.date,
          product: product,
          unitValue: double.parse(supp.unitValue),
          quantity: double.parse(supp.quantity));
      await openingStockItemsService.add(openingStockItem);
    }
    emit(ProductPageState.success(supp));
  }

  void editProduct() async {
    _validate();

    var supp = state.supplements;
    final hasErrors = InputValidation.checkErrors(supp.errors);
    if (hasErrors) return;

    final product = Product(
        id: supp.id,
        categoryId: supp.categoryId,
        unit: supp.unit,
        name: supp.name,
        barcode: supp.barcode,
        unitPrice: double.parse(supp.unitPrice));
    await productsService.edit(product);
    emit(ProductPageState.success(supp));
  }

  _validate() {
    var supp = state.supplements;
    final errors = <String, String?>{};

    emit(ProductPageState.loading(supp));
    errors['name'] = InputValidation.validateText(supp.name, 'name');
    errors['unit'] = InputValidation.validateText(supp.unit, 'Unit');
    errors['category'] =
        InputValidation.validateText(supp.categoryId, 'Category');
    errors['unitPrice'] =
        InputValidation.validateNumber(supp.unitPrice, 'Unit Price');

    if (supp.hasAddedOpeningStockDetails) {
      errors['unitValue'] =
          InputValidation.validateNumber(supp.unitValue, 'Unit Value');
      errors['quantity'] =
          InputValidation.validateNumber(supp.quantity, 'Quantity');
    }

    supp = supp.copyWith(errors: errors);
    emit(ProductPageState.content(supp));
  }

  _handleproductUpdates() {
    var supp = state.supplements;
    emit(ProductPageState.loading(supp));
    final products = productsService.getList;
    supp = supp.copyWith(productList: products);
    emit(ProductPageState.content(supp));
  }

  _handleCategoryUpdates() {
    var supp = state.supplements;
    emit(ProductPageState.loading(supp));
    final id = categoriesService.getSelectedCategoryId;
    supp = supp.copyWith(categoryId: id);
    emit(ProductPageState.content(supp));
  }
}
