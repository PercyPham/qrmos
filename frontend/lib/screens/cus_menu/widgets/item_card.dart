import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/menu/menu.dart';
import 'package:qrmos/widgets/wrap_text.dart';

class ItemCard extends StatelessWidget {
  final bool isChoosable;
  final MenuItem menuItem;
  final void Function()? onTap;

  const ItemCard({
    Key? key,
    required this.isChoosable,
    required this.menuItem,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isChoosable ? onTap : null,
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
    return Stack(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Image.network(
            menuItem.image,
            fit: BoxFit.cover,
          ),
        ),
        if (!isChoosable)
          Container(
            width: 50,
            height: 50,
            color: Colors.white.withOpacity(0.7),
            child: Center(
              child: Text(
                'Tạm\nhết',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
            ),
          ),
      ],
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isChoosable ? null : Colors.grey,
            ),
          ),
          if (menuItem.description != '') const SizedBox(height: 5),
          if (menuItem.description != '')
            WrapText(
              menuItem.description,
              width: width,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isChoosable ? null : Colors.grey,
              ),
            ),
        ]);
  }
}
