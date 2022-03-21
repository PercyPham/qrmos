import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/menu/menu.dart';
import 'package:qrmos/widgets/wrap_text.dart';

class ItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final void Function()? onTap;

  const ItemCard({
    Key? key,
    required this.menuItem,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _itemImage(),
              const SizedBox(width: 5),
              _itemInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  _itemImage() {
    return SizedBox(
      width: 50,
      height: 50,
      child: Image.network(
        menuItem.image,
        fit: BoxFit.cover,
      ),
    );
  }

  _itemInfo(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 150;
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WrapText(
            menuItem.name,
            width: width,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (menuItem.description != '') const SizedBox(height: 5),
          if (menuItem.description != '')
            WrapText(
              menuItem.name,
              width: width,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ]);
  }
}
