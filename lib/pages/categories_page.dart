import '../source.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage(this.categoryType, {Key? key}) : super(key: key);

  final CategoryTypes categoryType;

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  var bloc = CategoryPageBloc.empty();
  late final bool isProductsCategory;

  @override
  void initState() {
    isProductsCategory = widget.categoryType == CategoryTypes.products;
    _initBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageAppBar(
          title: '${isProductsCategory ? 'Products' : 'Expenses'} Categories'),
      body: _buildBody(),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  _buildBody() {
    return BlocConsumer<CategoryPageBloc, CategoryPagesState>(
        bloc: bloc,
        listener: (_, state) {
          final error = state.maybeWhen(
              failed: (_, e, showOnPage) => showOnPage ? null : e,
              orElse: () => null);
          if (error != null) showSnackBar(error, context: context);
        },
        builder: (_, state) {
          return state.when(
              loading: _buildLoading,
              content: _buildContent,
              success: _buildContent,
              failed: _buildFailed);
        });
  }

  Widget _buildLoading(CategoryPageSupplements supp) {
    return const AppLoadingIndicator();
  }

  Widget _buildFailed(
      CategoryPageSupplements supp, String? message, bool isShowOnPage) {
    if (!isShowOnPage) return _buildContent(supp);

    return OnScreenError(message: message!, tryAgainCallback: _tryInitAgain);
  }

  Widget _buildContent(CategoryPageSupplements supp) {
    final categories = supp.categoryList;
    if (categories.isEmpty) {
      return EmptyStateWidget(message: _emptyCategoriesMessage());
    }

    return Column(
      children: [
        ListView.separated(
          separatorBuilder: (_, __) => Container(
            height: 1.5.dw,
            color: AppColors.divider,
          ),
          itemCount: categories.length,
          itemBuilder: (_, index) {
            final category = categories[index];
            return CategoryTile(category: category);
          },
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
        ),
      ],
    );
  }

  _buildFloatingButton() {
    return BlocBuilder<CategoryPageBloc, CategoryPagesState>(
        bloc: bloc,
        builder: (_, state) {
          final shouldShowButton = state.maybeWhen(
              content: (_) => true,
              failed: (_, __, showOnPage) => !showOnPage,
              orElse: () => false);
          if (!shouldShowButton) return Container();
          return AddButton(
              nextPage: CategoryEditPage(categoryType: widget.categoryType));
        });
  }

  _emptyCategoriesMessage() =>
      'No ${isProductsCategory ? 'products' : 'expenses'} categories found. Start creating categories by clicking on the bottom-right corner add button.';

  _initBloc([bool isFirstTimeInit = true]) {
    if (isFirstTimeInit) {
      final categoriesService = getService<CategoriesService>(context);
      final itemsService = getService<ProductsService>(context);
      bloc = CategoryPageBloc(categoriesService, itemsService);
    }
    bloc.init(Pages.categories_page, type: widget.categoryType);
  }

  _tryInitAgain() => _initBloc(false);
}
