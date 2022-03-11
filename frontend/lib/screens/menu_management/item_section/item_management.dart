import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart';
import 'package:qrmos/widgets/screen_name.dart';

import 'widgets/item_table.dart';

class ItemManagementSection extends StatelessWidget {
  final bool isLoading;
  final List<MenuItem> items;
  final void Function(int, bool) onToggleItemAvailabilityPressed;
  final void Function() onCreateItemButtonPressed;

  const ItemManagementSection({
    Key? key,
    required this.isLoading,
    required this.items,
    required this.onToggleItemAvailabilityPressed,
    required this.onCreateItemButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScreenNameText("Quản lý món"),
        Container(height: 20),
        ItemTable(
          isLoading: isLoading,
          items: items,
          onToggleItemAvailabilityPressed: onToggleItemAvailabilityPressed,
          onItemDetailButtonPressed: (_) {},
        ),
        Container(height: 10),
        ElevatedButton(
          child: const Text("Tạo món"),
          onPressed: onCreateItemButtonPressed,
        ),
      ],
    );
  }
}
