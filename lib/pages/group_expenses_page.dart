import 'package:inventory_management/widgets/bottom_total_amount_tile.dart';
import '../source.dart';

class GroupExpensesPage extends StatefulWidget {
  const GroupExpensesPage({this.group, Key? key}) : super(key: key);

  final Document? group;

  @override
  State<GroupExpensesPage> createState() => _GroupExpensesPageState();
}

class _GroupExpensesPageState extends State<GroupExpensesPage> {
  late final ExpensePagesBloc bloc;
  late final bool isEditing;
  //final _isActionActiveNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    isEditing = widget.group != null;
    final expensesService = getService<ExpensesService>(context);
    final categoriesService = getService<CategoriesService>(context);
    final salesService = getService<SalesService>(context);
    bloc = ExpensePagesBloc(expensesService, categoriesService, salesService);
  //  _initAppBarAction();
    bloc.init(Pages.group_expenses_page, null, widget.group?.form.id);
    super.initState();
  }

/*  _initAppBarAction() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _isActionActiveNotifier.value = widget.group == null;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpensePagesBloc, ExpensePagesState>(
      bloc: bloc,
      builder: (_, state) {
        return state.when(
          loading: _buildLoading,
          content: _buildContent,
          success: _buildContent,
        );
      },
    );
  }

  Widget _buildContent(ExpenseSupplements supp) {
    final id = supp.group.form.id;

    return Scaffold(
      appBar: _buildAppBar(id),
      body: _buildBody(supp),
      floatingActionButton: _buildAddButton(id),
      bottomNavigationBar: _buildBottomNavBar(id),
    );
  }

  _buildAppBar(String groupId) {
    final hasNoGroup = groupId.isEmpty;
    return AppBar(
        title: AppText('Expenses',
            size: 22.dw, style: Theme.of(context).appBarTheme.titleTextStyle!),
        actions: [
          hasNoGroup
              ? AppIconButton(
                  icon: Icons.done,
                  margin: EdgeInsets.only(right: 19.dw),
                  onPressed: bloc.saveGroup)
              : Container()
        ]);
  }

  Widget _buildLoading(ExpenseSupplements supp) => const AppLoadingIndicator();

  Widget _buildBody(ExpenseSupplements supp) {
    return ListView(
      children: [
        DateSelector(
            title: 'Date',
            onDateSelected: bloc.updateGroupDate,
            isEditable: true,
            date: supp.date),
        AppDivider(margin: EdgeInsets.only(bottom: 10.dh)),
        AppTextField(
            error: supp.errors['title'],
            text: supp.group.form.title,
            onChanged: bloc.updateGroupTitle,
            hintText: '',
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            label: 'TITLE'),
        _buildItems(supp),
      ],
    );
  }

  _buildItems(ExpenseSupplements supp) {
    final expenses = supp.expenses;
    if (supp.group.form.id.isEmpty) return _buildEmptyState(emptyGroupMessage);
    if (expenses.isEmpty) return _buildEmptyState(emptyExpensesMessage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 19.dw),
          child: const AppText('Expenses', weight: FontWeight.bold),
        ),
        ListView.separated(
          itemCount: expenses.length,
          separatorBuilder: (_, __) =>
              const AppDivider(margin: EdgeInsets.zero),
          itemBuilder: (_, i) {
            final expense = expenses[i];
            final category = bloc.getCategoryById(expense.categoryId);
            return ExpenseTile(expense, category: category);
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ],
    );
  }

  _buildEmptyState(String message) {
    return Container(
        height: 500.dh,
        alignment: Alignment.center,
        child: EmptyStateWidget(message: message));
  }

  _buildAddButton(String groupId) {
    final hasNoGroup = groupId.isEmpty;
    if (hasNoGroup) return Container();
    return AddButton(nextPage: ExpenseEditPage(groupId: groupId));
  }

  _buildBottomNavBar(String groupId) {
    final totalAmount = bloc.getAmountByGroup(groupId) ?? 0.0;
    if (totalAmount == 0) return Container(height: .0001);
    return BottomTotalAmountTile(totalAmount);
  }

  static const emptyExpensesMessage = 'No items have been added yet.';
  static const emptyGroupMessage = 'Start by creating a new group.';
}
