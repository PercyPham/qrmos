import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart';
import 'package:qrmos/widgets/screen_name.dart';

import 'widgets/category_table.dart';

class CategoryManagementSection extends StatelessWidget {
  final bool isLoading;
  final List<MenuCategory> categories;
  final void Function(int) onDeleteCatButtonPressed;
  final void Function() onCreateNewCatPressed;

  const CategoryManagementSection({
    Key? key,
    required this.isLoading,
    required this.categories,
    required this.onDeleteCatButtonPressed,
    required this.onCreateNewCatPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScreenNameText("Quản lý danh mục"),
        Container(height: 20),
        CategoryTable(
          isLoading: isLoading,
          categories: categories,
          onDeleteCatButtonPressed: onDeleteCatButtonPressed,
        ),
        Container(height: 10),
        ElevatedButton(
          child: const Text("Tạo danh mục"),
          onPressed: onCreateNewCatPressed,
        ),
      ],
    );
  }
}
