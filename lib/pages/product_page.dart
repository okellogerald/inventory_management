import 'package:inventory_management/widgets/form_cell_item_picker.dart';

import '../source.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key, this.product}) : super(key: key);

  final Product? product;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  var bloc = ProductPagesBloc.empty();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _initBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductPagesBloc, ProductPageState>(
        bloc: bloc,
        listener: (_, state) {
          final isSaved =
              state.maybeWhen(success: (_) => true, orElse: () => false);
          if (isSaved) pop();

          final error = state.maybeWhen(
              failed: (_, e, showOnPage) => showOnPage ? null : e,
              orElse: () => null);
          if (error != null) showSnackBar(error, key: _scaffoldKey);
        },
        builder: (_, state) {
          return state.when(
              loading: _buildLoading,
              content: _buildContent,
              success: _buildContent,
              failed: _buildFailed);
        });
  }

  Widget _buildLoading(ProductPageSupplements supp) =>
      const AppLoadingIndicator.withScaffold();

  Widget _buildFailed(
      ProductPageSupplements supp, String? message, bool isShowOnPage) {
    if (!isShowOnPage) return _buildContent(supp);

    return OnScreenError(message: message!, tryAgainCallback: _tryInitAgain);
  }

  Widget _buildContent(ProductPageSupplements supp) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(supp),
      body: ListView(padding: EdgeInsets.zero, children: [
        _buildProductDetails(supp),
        _buildOpeningStockDetails(supp),
      ]),
    );
  }

  _buildAppBar(ProductPageSupplements supp) {
    final action = supp.action;

    return PageAppBar(
        title: action.isViewing
            ? supp.product.name
            : action.isAdding
                ? 'New Product'
                : 'Edit Product',
        actionIcons: action.isViewing
            ? [Icons.edit_outlined, Icons.delete_outlined]
            : [Icons.check],
        actionCallbacks: action.isViewing
            ? [() => bloc.updateAction(PageActions.editing), bloc.deleteProduct]
            : [action.isEditing ? bloc.editProduct : bloc.saveProduct]);
  }

  _buildProductDetails(ProductPageSupplements supp) {
    final errors = supp.errors;
    final product = supp.product;
    final action = supp.action;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        action.isAdding
            ? Padding(
                padding:
                    EdgeInsets.only(left: 19.dw, bottom: 10.dh, top: 10.dh),
                child: const AppText('PRODUCT DETAILS',
                    weight: FontWeight.bold, opacity: .7))
            : Container(),
        FormCellItemPicker(
          label: 'Category',
          valueText: bloc.getSelectedCategory?.name,
          errorText: supp.errors['category'],
          editable: !action.isViewing,
          onPressed: () => push(const ItemsSearchPage<Category>(
              categoryType: CategoryTypes.products)),
        ),
        AppDivider(margin: EdgeInsets.only(bottom: 10.dh)),
        !action.isViewing
            ? AppTextField(
                text: product.name,
                onChanged: (name) => bloc.updateAttributes(name: name),
                hintText: 'e.g. Clothes',
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                label: 'Name',
                error: errors['name'],
                isEnabled: !action.isViewing,
              )
            : Container(),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                text: product.unit,
                onChanged: (unit) => bloc.updateAttributes(unit: unit),
                hintText: 'ea.',
                keyboardType: TextInputType.name,
                shouldShowErrorText: false,
                label: 'Unit',
                error: errors['unit'],
                isEnabled: !action.isViewing,
              ),
            ),
            Expanded(
              child: AppTextField(
                text: supp.unitPrice,
                onChanged: (price) => bloc.updateAttributes(unitPrice: price),
                hintText: '0',
                keyboardType: TextInputType.number,
                shouldShowErrorText: false,
                label: 'Unit Price',
                error: errors['unitPrice'],
                isEnabled: !action.isViewing,
              ),
            ),
          ],
        ),
        _buildUnitTextFieldsErrors(errors),
        BarcodeField(
            error: supp.errors['code'],
            text: product.code,
            isEnabled: !action.isViewing,
            onChanged: (code) => bloc.updateAttributes(code: code)),
      ],
    );
  }

  _buildOpeningStockDetails(ProductPageSupplements supp) {
    if (!supp.action.isAdding) return Container();
    return ExpansionTile(
        title: const AppText('OPENING STOCK DETAILS',
            weight: FontWeight.bold, opacity: .7),
        children: _openingStockDetails(supp),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        tilePadding: EdgeInsets.symmetric(horizontal: 19.dw));
  }

  List<Widget> _openingStockDetails(ProductPageSupplements supp) {
    final errors = supp.errors;
    final action = supp.action;

    return [
      DateSelector(
          title: 'DATE',
          onDateSelected: (_) {},
          isEditable: false,
          date: supp.date),
      SizedBox(height: 8.dh),
      AppTextField(
        text: supp.quantity,
        onChanged: (quantity) => bloc.updateAttributes(quantity: quantity),
        hintText: '0',
        keyboardType: TextInputType.number,
        label: 'Quantity',
        isEnabled: !action.isViewing,
        error: errors['quantity'],
      ),
      AppTextField(
        text: supp.quantity,
        onChanged: (value) => bloc.updateAttributes(unitValue: value),
        hintText: '0',
        keyboardType: TextInputType.number,
        label: 'Unit Value',
        isEnabled: !action.isViewing,
        error: errors['unitValue'],
      ),
      _buildTotalOpeningValue(supp)
    ];
  }

  _buildTotalOpeningValue(ProductPageSupplements supp) {
    if (!supp.canCalculateTotalPrice) return Container();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 19.dw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('Product Value', opacity: .7),
          SizedBox(height: 8.dh),
          AppText(supp.getStockValue, weight: FontWeight.bold),
          SizedBox(height: 8.dh),
        ],
      ),
    );
  }

  _buildUnitTextFieldsErrors(Map<String, String?> errors) {
    final hasUnitError = errors['unit'] != null;
    final hasUnitPriceError = errors['unitPrice'] != null;

    return Padding(
      padding: EdgeInsets.only(left: 19.dw, right: 19.dw, bottom: 10.dh),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasUnitError) _buildErrorText(errors['unit']!),
          if (hasUnitPriceError) _buildErrorText(errors['unitPrice']!),
        ],
      ),
    );
  }

  _buildErrorText(String error) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.dh),
      child: AppText('* $error', color: AppColors.error),
    );
  }

  _initBloc([bool isFirstTimeInit = true]) {
    if (isFirstTimeInit) {
      final productsService = getService<ProductsService>(context);
      final categoriesService = getService<CategoriesService>(context);
      final openingStockItemsService =
          getService<OpeningStockItemsService>(context);
      bloc = ProductPagesBloc(
          productsService, categoriesService, openingStockItemsService);
    }
    final action =
        widget.product == null ? PageActions.adding : PageActions.viewing;
    bloc.init(Pages.product_page, product: widget.product, action: action);
  }

  _tryInitAgain() => _initBloc(false);
}
