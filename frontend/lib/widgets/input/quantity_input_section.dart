import 'package:flutter/material.dart';

class QuantityInputSection extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;

  const QuantityInputSection({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.brown);
    var reducable = value > 1;
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Số lượng: ', style: textStyle),
          const SizedBox(width: 5),
          _customButton(
            '-',
            backgroundColor: reducable ? Colors.white : Colors.grey.shade200,
            onPressed: reducable ? () => onChanged(value - 1) : null,
          ),
          const SizedBox(width: 5),
          Text('$value', style: textStyle),
          const SizedBox(width: 5),
          _customButton('+', onPressed: () => onChanged(value + 1)),
        ],
      ),
    );
  }

  _customButton(
    String sign, {
    Color backgroundColor = Colors.white,
    void Function()? onPressed,
  }) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(backgroundColor),
      ),
      child: Text(sign,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.brown,
          )),
      onPressed: onPressed,
    );
  }
}
