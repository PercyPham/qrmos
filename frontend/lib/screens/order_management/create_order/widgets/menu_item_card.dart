import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/menu/menu.dart' show MenuItem;

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final void Function() onTap;

  const MenuItemCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var color = item.isChoosable ? null : Colors.grey;
    return InkWell(
      onTap: item.isChoosable ? onTap : null,
      child: Card(
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          width: 400,
          height: 50,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.add_box_rounded, color: color),
              const SizedBox(width: 10),
              Text('${item.name}${item.isChoosable ? '' : ' ( không chọn được )'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: color,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
