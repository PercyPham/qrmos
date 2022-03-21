import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/order/create_order.dart';
import 'package:qrmos/widgets/custom_button.dart';
import 'package:qrmos/widgets/input/quantity_input_section.dart';
import 'package:qrmos/widgets/tray_item.dart';

import 'widget/item_main_info.dart';
import 'widget/item_option_card.dart';

class EditTrayItemScreen extends StatefulWidget {
  final TrayItem trayItem;
  const EditTrayItemScreen(this.trayItem, {Key? key}) : super(key: key);

  @override
  State<EditTrayItemScreen> createState() => _EditTrayItemScreenState();
}

class _EditTrayItemScreenState extends State<EditTrayItemScreen> {
  CreateOrderItem _item = CreateOrderItem();

  @override
  void initState() {
    super.initState();

    _item = widget.trayItem.orderItem.clone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ItemMainInfo(widget.trayItem.menuItem),
            ..._optionCards(),
            const SizedBox(height: 10),
            _noteInput(),
            const SizedBox(height: 10),
            _quantityInput(),
            const SizedBox(height: 10),
            _addTrayButton(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _optionCards() {
    List<Widget> cards = [];
    var options = widget.trayItem.menuItem.options;
    for (var optName in options.keys) {
      var option = options[optName]!;
      if (option.isChoosable) {
        cards.add(const SizedBox(height: 15));
        cards.add(ItemOptionCard(
          optionName: optName,
          option: option,
          chosenChoices: _item.options[optName]!,
          onToggleChoice: (choice) {
            setState(() {
              _item.toggleOptionChoice(optName, choice);
            });
          },
        ));
      }
    }
    return cards;
  }

  _noteInput() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      width: double.infinity,
      child: TextFormField(
          initialValue: _item.note,
          decoration: const InputDecoration(label: Text('Ghi chú')),
          onChanged: (val) {
            _item.note = val;
          }),
    );
  }

  _quantityInput() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      child: QuantityInputSection(
          value: _item.quantity,
          onChanged: (val) {
            setState(() {
              _item.quantity = val;
            });
          }),
    );
  }

  Container _addTrayButton(BuildContext context) {
    var isValidInput = _validateInput();
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      width: double.infinity,
      child: Center(
        child: CustomButton(
          'Lưu thay đổi',
          isValidInput ? () => _onSaVe(context) : null,
          color: isValidInput ? Colors.brown : Colors.grey[300],
        ),
      ),
    );
  }

  _onSaVe(BuildContext context) {
    Navigator.of(context).pop<CreateOrderItem?>(_item);
  }

  bool _validateInput() {
    var options = widget.trayItem.menuItem.options;
    for (var optName in options.keys) {
      var menuOpt = options[optName]!;
      if (!menuOpt.available) continue;
      var orderOpt = _item.options[optName]!;
      if (orderOpt.length < menuOpt.minChoice) {
        return false;
      }
    }
    return true;
  }
}
