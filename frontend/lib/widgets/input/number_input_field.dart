import 'package:flutter/material.dart';

class NumberInputField extends StatefulWidget {
  final InputDecoration decoration;
  final void Function(int) onChanged;
  const NumberInputField({
    Key? key,
    required this.onChanged,
    this.decoration = const InputDecoration(),
  }) : super(key: key);

  @override
  State<NumberInputField> createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  int _currNumVal = 0;
  String _currVal = "0";
  final TextEditingController _controler = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controler.text = _currVal;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: widget.decoration,
      controller: _controler,
      onChanged: (val) {
        if (val == "") {
          val = "0";
          _controler.text = _currVal;
          _controler.selection = TextSelection.fromPosition(const TextPosition(offset: 1));
        }

        if (val == _currVal) {
          return;
        }

        if (int.tryParse(val) == null) {
          _controler.text = _currVal;
          _controler.selection = TextSelection.fromPosition(TextPosition(offset: _currVal.length));
          return;
        }

        setState(() {
          _currNumVal = int.parse(val);
          _currVal = '$_currNumVal';
        });

        _controler.text = _currVal;
        _controler.selection = TextSelection.fromPosition(TextPosition(offset: _currVal.length));
        widget.onChanged(_currNumVal);
      },
    );
  }
}
