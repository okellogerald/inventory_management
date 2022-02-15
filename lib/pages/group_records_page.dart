import '../source.dart';

class GroupRecordsPage extends StatefulWidget {
  const GroupRecordsPage(this.group, {Key? key}) : super(key: key);

  final Group group;

  @override
  State<GroupRecordsPage> createState() => _GroupGroupPagesState();
}

class _GroupGroupPagesState extends State<GroupRecordsPage> {
  late final GroupPagesBloc bloc;

  @override
  void initState() {
    final recordsService = Provider.of<RecordsService>(context, listen: false);
    final groupsService = Provider.of<GroupsService>(context, listen: false);
    final itemsService = Provider.of<ItemsService>(context, listen: false);
    bloc = GroupPagesBloc(groupsService, recordsService, itemsService);
    bloc.init(group: widget.group);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildAddItemButton(),
    );
  }

  _buildAppBar() {
    return PageAppBar(
      title: widget.group.title + ' Sales',
      actionIcon: Icons.edit_outlined,
      actionCallback: _navigateToGroupEditPage,
    );
  }

  void _navigateToGroupEditPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => GroupEditPage(group: widget.group)));
  }

  Widget _buildLoading(GroupSupplements supp) {
    return const Center(child: CircularProgressIndicator());
  }

  _buildBody() {
    return BlocBuilder<GroupPagesBloc, GroupPagesState>(
        bloc: bloc,
        builder: (_, state) {
          return state.when(
              loading: _buildLoading,
              content: _buildContent,
              success: _buildContent);
        });
  }

  Widget _buildContent(GroupSupplements supp) {
    final recordList = supp.getSpecificGroupRecords;
    final totalAmount = Utils.convertToMoneyFormat(bloc.getGroupTotalAmount);

    return bloc.isItemListEmpty
        ? _buildEmptyItemState()
        : supp.recordList.isEmpty
            ? _buildEmptyRecordState()
            : ListView(
                children: [
                  ListView.separated(
                    separatorBuilder: (_, index) =>
                        const AppDivider(margin: EdgeInsets.zero),
                    itemCount: recordList.length,
                    itemBuilder: (_, index) => RecordTile(recordList[index]),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  AppDivider(
                    height: 2,
                    color: AppColors.secondary,
                    margin: EdgeInsets.only(bottom: 8.dh),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 19.dw),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText('Total Amount'.toUpperCase(),
                            weight: FontWeight.w500),
                        AppText(totalAmount,
                            weight: FontWeight.bold, size: 20.dw),
                      ],
                    ),
                  )
                ],
              );
  }

  _buildEmptyItemState() => _buildEmptyState(true);

  _buildEmptyRecordState() => _buildEmptyState(false);

  _buildAddItemButton() {
    return BlocBuilder<GroupPagesBloc, GroupPagesState>(
        bloc: bloc,
        builder: (_, state) {
          final supp = state.supplements;

          return bloc.isItemListEmpty
              ? Container()
              : FloatingActionButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => RecordEditPage(groupId: supp.id))),
                  child: const Icon(Icons.add, color: AppColors.onPrimary),
                );
        });
  }

  _buildEmptyState(bool isItemListEmpty) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /*   Image.network(
          Constants.kEmptySalesImage,
          height: 100.dh,
          fit: BoxFit.contain,
        ), */
        Icon(Icons.hourglass_empty, size: 45.dw, color: AppColors.onBackground),
        SizedBox(height: 20.dh),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 19.dw),
          child: AppText(
              isItemListEmpty ? emptyItemMessage : emptyRecordMessage,
              alignment: TextAlign.center),
        ),
        isItemListEmpty
            ? Builder(builder: (context) {
                return AppTextButton(
                  onPressed: () => ItemEditPage.navigateTo(context),
                  height: 40.dh,
                  text: 'Add Item',
                  margin:
                      EdgeInsets.only(left: 19.dw, right: 19.dw, top: 40.dh),
                );
              })
            : Container()
      ],
    );
  }

  static const emptyItemMessage =
      'No item has been added yet. Create one by clicking on the below button.';
  static const emptyRecordMessage =
      'No records in this group yet. Create one by clicking on the Add Button on the bottom-right corner.';
}
