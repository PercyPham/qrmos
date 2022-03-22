import 'package:flutter/material.dart';

class PageNav extends StatelessWidget {
  final int currentPage;
  final int totalPageCount;
  final void Function(int) onPageChanged;

  const PageNav({
    Key? key,
    required this.currentPage,
    required this.totalPageCount,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var hasPrevPage = currentPage > 1;
    var hasNextPage = currentPage < totalPageCount;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _smallButton("<", hasPrevPage ? () => onPageChanged(currentPage - 1) : null),
            Container(width: 10),
            Text('$currentPage', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Container(width: 10),
            _smallButton(">", hasNextPage ? () => onPageChanged(currentPage + 1) : null),
          ],
        ),
        const SizedBox(height: 10),
        Text('Số trang: $totalPageCount'),
      ],
    );
  }

  _smallButton(String char, void Function()? onPressed) {
    return ElevatedButton(
      child: Text(char,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.brown)),
      onPressed: onPressed,
      style: onPressed == null
          ? null
          : ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
            ),
    );
  }
}
