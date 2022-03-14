import '../source.dart';

class CategoryEditPage extends StatefulWidget {
  const CategoryEditPage({Key? key, this.category, this.categoryType})
      : super(key: key);

  final Category? category;
  final CategoryType? categoryType;

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  late final CategoryPageBloc bloc;
  late final bool isEditing;

  @override
  void initState() {
    isEditing = widget.category != null;
    _initBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryPageBloc, CategoryPagesState>(
        bloc: bloc,
        listener: (_, state) {
          final isSuccess =
              state.maybeWhen(success: (_) => true, orElse: () => false);

          if (isSuccess) pop();
        },
        builder: (_, state) {
          return state.when(
              loading: _buildLoading,
              content: _buildContent,
              success: _buildContent);
        });
  }

  Widget _buildLoading(CategoryPageSupplements supp) {
    return const AppLoadingIndicator.withScaffold();
  }

  Widget _buildContent(CategoryPageSupplements supp) {
    return Scaffold(
      appBar: PageAppBar(
        title: '${!isEditing ? 'New' : 'Edit'} Category',
        actionCallbacks: isEditing ? [bloc.edit, bloc.delete] : [bloc.save],
        actionIcons:
            isEditing ? [Icons.check, Icons.delete_outline] : [Icons.check],
      ),
      body: _buildBody(supp),
    );
  }

  Widget _buildBody(CategoryPageSupplements supp) {
    return Column(
      children: [
        widget.categoryType != null
            ? Container()
            : ValueSelector(
                title: 'Type',
                value: supp.category.type,
                error: supp.errors['type'],
                isEditable: !isEditing,
                onPressed: () => push(ItemsSearchPage<CategoryType>(
                    categoryType: widget.categoryType)),
              ),
        AppDivider(margin: EdgeInsets.only(bottom: 10.dh)),
        AppTextField(
            text: supp.category.name,
            onChanged: bloc.updateName,
            hintText: '',
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            label: 'Name',
            error: supp.errors['name']),
        AppTextField(
          error: supp.errors['description'],
          text: supp.category.description,
          onChanged: bloc.updateDescription,
          hintText: '',
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          label: 'Description',
          maxLines: 3,
        ),
      ],
    );
  }

  _initBloc() {
    final categoriesService = getService<CategoriesService>(context);
    final itemsService = getService<ProductsService>(context);
    final typeService = getService<CategoryTypesService>(context);
    bloc = CategoryPageBloc(categoriesService, itemsService, typeService);
    bloc.init(widget.categoryType, widget.category);
  }
}
