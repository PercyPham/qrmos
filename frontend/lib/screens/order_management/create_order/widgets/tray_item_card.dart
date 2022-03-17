import 'package:flutter/material.dart';

import '../models/tray_item.dart';

class TrayItemCard extends StatelessWidget {
  final TrayItem trayItem;
  final void Function() onTap;

  const TrayItemCard({
    Key? key,
    required this.trayItem,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: null,
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
              Text(trayItem.menuItem.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
