import '../source.dart';

class AddCategoryPage extends StatelessWidget {
  const AddCategoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  _buildBody() {
    return ListView(
      children: [
        _buildTitle(),
        AppTextField(
            errors: const {},
            text: '',
            onChanged: (_) {},
            hintText: '',
            keyboardType: TextInputType.text,
            label: 'Category Title',
            errorName: ''),
        Padding(
          padding: EdgeInsets.only(left: 19.dw, bottom: 10.dh),
          child: AppText(
            'First Item'.toUpperCase(),
            color: AppColors.accent,
          ),
        ),
        AppTextField(
            errors: const {},
            text: '',
            onChanged: (_) {},
            hintText: '',
            keyboardType: TextInputType.text,
            label: 'Item Title',
            errorName: ''),
        AppTextField(
            errors: const {},
            text: '',
            onChanged: (_) {},
            hintText: '',
            keyboardType: TextInputType.text,
            label: 'Unit',
            errorName: ''),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                  errors: const {},
                  text: '',
                  onChanged: (_) {},
                  hintText: '',
                  keyboardType: TextInputType.text,
                  label: 'Unit Price',
                  errorName: ''),
            ),
            Expanded(
              child: AppTextField(
                  errors: const {},
                  text: '',
                  onChanged: (_) {},
                  hintText: '',
                  keyboardType: TextInputType.text,
                  label: 'In Stock',
                  errorName: ''),
            ),
          ],
        ),
        AppTextButton(
          onPressed: () {},
          alignment: Alignment.centerLeft,
          text: 'Add Item',
          textColor: AppColors.primaryVariant,
          isFilled: false,
          withIcon: true,
          icon: Icons.add,
          height: 45.dh,
          iconColor: AppColors.primaryVariant,
          padding: EdgeInsets.only(left: 19.dw)
        )
      ],
    );
  }

  _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 19.dw, vertical: 10.dh),
      child: AppText('Adding Category', size: 24.dw, weight: FontWeight.w500),
    );
  }

  _buildBottomNavBar() {
    return Builder(builder: (context) {
      return AppTextButton(
        onPressed: () => Navigator.pop(context),
        height: 50.dh,
        margin: EdgeInsets.only(left: 19.dw, right: 19.dw, bottom: 10.dw),
        text: 'Done',
        textColor: AppColors.onPrimary,
      );
    });
  }
}