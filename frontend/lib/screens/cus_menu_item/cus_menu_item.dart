import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/menu/menu.dart';
import 'package:qrmos/services/qrmos/order/create_order.dart';
import 'package:qrmos/widgets/custom_button.dart';
import 'package:qrmos/widgets/input/quantity_input_section.dart';

import 'widget/item_main_info.dart';
import 'widget/item_option_card.dart';

class CusMenuItemScreen extends StatefulWidget {
  final MenuItem menuItem;
  const CusMenuItemScreen(this.menuItem, {Key? key}) : super(key: key);

  @override
  State<CusMenuItemScreen> createState() => _CusMenuItemScreenState();
}

class _CusMenuItemScreenState extends State<CusMenuItemScreen> {
  final CreateOrderItem _item = CreateOrderItem();

  @override
  void initState() {
    super.initState();
    _item.itemId = widget.menuItem.id;
    _item.options = {};
    for (var optName in widget.menuItem.options.keys) {
      var option = widget.menuItem.options[optName]!;
      if (option.isChoosable) _item.options[optName] = [];
    }
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
            ItemMainInfo(widget.menuItem),
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
    for (var optName in widget.menuItem.options.keys) {
      var option = widget.menuItem.options[optName]!;
      if (option.isChoosable) {
        cards.add(const SizedBox(height: 15));
        cards.add(ItemOptionCard(
          optionName: optName,
          option: option,
          chosenChoices: _item.options[optName]!,
          onToggleChoice: (choice) {
            var isAdding = !_item.options[optName]!.contains(choice);
            if (isAdding) {
              var currChoiceNum = _item.options[optName]!.length;
              var option = widget.menuItem.options[optName]!;
              if (currChoiceNum < option.maxChoice) {
                setState(() {
                  _item.addOptionChoice(optName, choice);
                });
              }
              return;
            }
            setState(() {
              _item.removeOptionChoice(optName, choice);
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
          'Thêm Vào Khay',
          isValidInput ? () => _onAddTray(context) : null,
          color: isValidInput ? Colors.brown : Colors.grey[300],
        ),
      ),
    );
  }

  _onAddTray(BuildContext context) {
    Navigator.of(context).pop<CreateOrderItem?>(_item);
  }

  bool _validateInput() {
    for (var optName in widget.menuItem.options.keys) {
      var menuOpt = widget.menuItem.options[optName]!;
      if (!menuOpt.available) continue;
      var orderOpt = _item.options[optName]!;
      if (orderOpt.length < menuOpt.minChoice) {
        return false;
      }
    }
    return true;
  }
}
