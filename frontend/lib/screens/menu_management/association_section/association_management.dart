import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart';
import 'package:qrmos/widgets/screen_name.dart';

import 'widgets/association_table.dart';

class AssociationManagementSection extends StatelessWidget {
  final bool isLoading;
  final List<MenuCategory> categories;
  final List<MenuItem> items;
  final List<MenuAssociation> associations;
  final void Function(int, int) onDeleteAssociationButtonPressed;
  final void Function(int) onCreateNewAssociationPressed;

  const AssociationManagementSection({
    Key? key,
    required this.isLoading,
    required this.categories,
    required this.items,
    required this.associations,
    required this.onDeleteAssociationButtonPressed,
    required this.onCreateNewAssociationPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScreenNameText("Quản lý món trong danh mục"),
        Container(height: 20),
        AssociationTable(
          isLoading: isLoading,
          categories: categories,
          items: items,
          associations: associations,
          onDeleteButtonPressed: onDeleteAssociationButtonPressed,
          onCreateButtonPressed: onCreateNewAssociationPressed,
        ),
      ],
    );
  }
}
