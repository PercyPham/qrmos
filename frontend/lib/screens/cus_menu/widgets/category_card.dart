import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/menu/menu.dart';

import 'item_card.dart';

class CategoryCard extends StatelessWidget {
  final MenuCategory category;
  final List<MenuItem> menuItems;
  final void Function(MenuItem)? onMenuItemTap;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.menuItems,
    required this.onMenuItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[300],
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _categoryName(),
            const SizedBox(height: 5),
            if (category.description != '') _categoryDescription(),
            if (category.description != '') const SizedBox(height: 5),
            ...menuItems
                .map((mItem) => ItemCard(
                      menuItem: mItem,
                      onTap: onMenuItemTap == null ? null : () => onMenuItemTap!(mItem),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  _categoryName() {
    return Text(category.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ));
  }

  _categoryDescription() {
    return Text(category.name, style: const TextStyle(fontSize: 13));
  }
}
