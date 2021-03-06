import '../source.dart';
import '../widgets/bottom_total_amount_tile.dart';

class DocumentSalesPage extends StatefulWidget {
  const DocumentSalesPage(
      {this.document, this.fromQuickActions = false, Key? key})
      : super(key: key);

  final Document? document;
  final bool fromQuickActions;

  @override
  State<DocumentSalesPage> createState() => _DocumentSalesPageState();
}

class _DocumentSalesPageState extends State<DocumentSalesPage> {
  var bloc = SalesPagesBloc.empty();

  @override
  void initState() {
    _initBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handlePop,
      child: Scaffold(
        body: BlocConsumer<SalesPagesBloc, SalesDocumentsPageState>(
            bloc: bloc,
            listener: (_, state) {
              final isSuccessful =
                  state.maybeWhen(success: (_) => true, orElse: () => false);

              if (isSuccessful) {
                final message =
                    widget.fromQuickActions || state.supplements.action.isAdding
                        ? 'Sales document was added successfully'
                        : state.supplements.action.isEditing
                            ? 'Sales document was editted successfully'
                            : 'Sales document was deleted successfully';
                showSnackBar(message, context: _, isError: false);
                pop();
              }

              final error = state.maybeWhen(
                  failed: (_, e, showOnPage) => showOnPage ? null : e,
                  orElse: () => null);
              if (error != null) showSnackBar(error, context: _);
            },
            builder: (_, state) {
              return state.when(
                  loading: _buildLoading,
                  content: _buildContent,
                  success: _buildContent,
                  failed: _buildFailed);
            }),
      ),
    );
  }

  Widget _buildLoading(SalesDocumentSupplements supp) =>
      const AppLoadingIndicator.withScaffold();

  Widget _buildFailed(
      SalesDocumentSupplements supp, String? message, bool isShowOnPage) {
    if (!isShowOnPage) return _buildContent(supp);

    return OnScreenError(message: message!, tryAgainCallback: _tryInitAgain);
  }

  Widget _buildContent(SalesDocumentSupplements supp) {
    return Scaffold(
        appBar: _buildAppBar(supp),
        body: _buildGroupDetails(supp),
        floatingActionButton:
            widget.fromQuickActions ? _emptyWidget() : _buildActionButton(supp),
        bottomNavigationBar: widget.fromQuickActions
            ? _emptyWidget()
            : _buildBottomNavBar(supp));
  }

  Widget _emptyWidget() => const SizedBox(height: .004, width: .0004);

  _buildAppBar(SalesDocumentSupplements supp) {
    final action = supp.action;
    final title = action.isViewing
        ? supp.document.form.title
        : action.isEditing
            ? 'Edit Sales Document'
            : 'New Sales Document';

    return PageAppBar.onDocumentPage(
        title: title,
        action: action,
        updateActionCallback: () => bloc.updateAction(PageActions.editing),
        deleteDocumentCallback: bloc.deleteDocument,
        saveDocumentCallback: () => bloc.saveDocument(widget.fromQuickActions),
        editDocumentCallback: bloc.editDocument);
  }

  Widget _buildGroupDetails(SalesDocumentSupplements supp) {
    final action = supp.action;

    return ListView(
      children: [
        action.isEditing || action.isAdding
            ? DateSelector(
                title: 'Date',
                onDateSelected: bloc.updateDate,
                date: supp.date,
                isEditable: /*!hasDocument*/ false,
              )
            : Container(),
        const AppDivider(margin: EdgeInsets.zero),
        _buildGroupTitle(supp),
        widget.fromQuickActions ? _emptyWidget() : _buildItems(supp)
      ],
    );
  }

  _buildGroupTitle(SalesDocumentSupplements supp) {
    return supp.action.isViewing
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckBox(supp),
              supp.isDateAsTitle
                  ? Container()
                  : AppTextField(
                      text: supp.document.form.title,
                      onChanged: bloc.updateTitle,
                      hintText: '',
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      label: 'Title',
                      error: supp.errors['title']),
            ],
          );
  }

  _buildCheckBox(SalesDocumentSupplements supp) {
    final text =
        supp.isDateAsTitle ? 'Date used as title' : 'Use date as title';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.dw),
      child: Row(
        children: [
          Checkbox(
              value: supp.isDateAsTitle, onChanged: bloc.updateDateAsTitle),
          SizedBox(width: 5.dw),
          AppText(text),
        ],
      ),
    );
  }

  _buildItems(SalesDocumentSupplements supp) {
    final salesList = supp.getSalesList;
    if (salesList.isEmpty) return _buildEmptyState(emptyExpensesMessage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        supp.action.isViewing
            ? Container()
            : Padding(
                padding: EdgeInsets.only(left: 19.dw),
                child: const AppText('Sales', weight: FontWeight.bold),
              ),
        ListView.separated(
          itemCount: salesList.length,
          separatorBuilder: (_, __) => AppDivider.onDocumentPage(),
          itemBuilder: (_, i) {
            final sales = salesList[i];
            final product = bloc.getProductById(sales.productId);
            return RecordTile<Sales>(sales,
                product: product, documentPageAction: supp.action);
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  _buildEmptyState(String message) {
    return Container(
        height: 600.dh,
        alignment: Alignment.center,
        child: EmptyStateWidget(message: message));
  }

  _buildActionButton(SalesDocumentSupplements supp) {
    return supp.action.isViewing
        ? Container()
        : const AddButton(nextPage: SalesPage(PageActions.adding));
  }

  _buildBottomNavBar(SalesDocumentSupplements supp) {
    return supp.action.isViewing
        ? BottomTotalAmountTile(supp.document.form.total)
        : const SizedBox(height: .00001);
  }

  _initBloc([bool isFirstTimeInit = true]) {
    if (isFirstTimeInit) {
      final salesService = getService<SalesService>(context);
      final productsService = getService<ProductsService>(context);
      bloc = SalesPagesBloc(salesService, productsService);
    }
    bloc.init(Pages.document_sales_page, document: widget.document);
  }

  _tryInitAgain() => _initBloc(false);

  Future<bool> _handlePop() async {
    final hasUnSavedSales = bloc.documentHasUnsavedChanges;
    if (hasUnSavedSales) {
      showDialog(
          context: context,
          builder: (_) => DocumentAlertDialog(
                isEditing: widget.document != null,
                editDocumentCallback: bloc.editDocument,
                saveDocumentCallback: bloc.saveDocument,
                clearChangesCallback: bloc.clearChanges,
              ));
    }
    return true;
  }

  static const emptyExpensesMessage =
      'No sales have been added in this document yet.';
}
