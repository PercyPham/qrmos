import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/menu/models.dart' show MenuItem;

import 'radius_container.dart';

class ItemMainInfo extends StatelessWidget {
  final MenuItem menuItem;

  const ItemMainInfo(
    this.menuItem, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.network(menuItem.image, fit: BoxFit.fitWidth),
        _menuItemOverview(),
      ],
    );
  }

  _menuItemOverview() {
    return BottomRadiusContainer(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    menuItem.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${menuItem.baseUnitPrice} vnđ',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const Text('Đơn giá', style: TextStyle(color: Colors.grey))
                    ],
                  ),
                ),
              ],
            ),
            if (menuItem.description != '') const SizedBox(height: 5),
            if (menuItem.description != '') Text(menuItem.description),
          ],
        ),
      ),
    );
  }
}
