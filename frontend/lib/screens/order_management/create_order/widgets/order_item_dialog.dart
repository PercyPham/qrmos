import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/menu/models.dart';
import 'package:qrmos/services/qrmos/order/create_order.dart';
import 'package:qrmos/widgets/custom_button.dart';
import 'package:qrmos/widgets/error_message.dart';

class OrderItemDialog extends StatefulWidget {
  final MenuItem menuItem;

  const OrderItemDialog({
    Key? key,
    required this.menuItem,
  }) : super(key: key);

  @override
  State<OrderItemDialog> createState() => _OrderItemDialogState();
}

class _OrderItemDialogState extends State<OrderItemDialog> {
  final CreateOrderItem _item = CreateOrderItem();
  String _errMsg = '';

  @override
  void initState() {
    super.initState();
    _item.itemId = widget.menuItem.id;
    _item.options = {};
    for (var optName in widget.menuItem.options.keys) {
      _item.options[optName] = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(15),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _itemIntro(),
            const SizedBox(height: 10),
            ..._optionList(),
            _noteInput(),
            _quantityInput(),
            ErrorMessage(_errMsg),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  _itemIntro() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                flex: 1,
                child: Text(
                  widget.menuItem.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left,
                )),
            Text(
              'Đơn giá: ${widget.menuItem.baseUnitPrice} vnđ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Text(widget.menuItem.description),
        ),
      ],
    );
  }

  List<Widget> _optionList() {
    return widget.menuItem.options.keys
        .map((optName) => _optionInput(
              optName,
              widget.menuItem.options[optName]!,
            ))
        .toList();
  }

  Widget _optionInput(String optName, MenuItemOption menuItemOption) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Text(optName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: menuItemOption.available ? null : Colors.grey[300],
            )),
        const SizedBox(height: 5),
        Text(
          '(chọn ít nhất ${menuItemOption.minChoice}, nhiều nhất ${menuItemOption.maxChoice})',
          style: TextStyle(color: menuItemOption.available ? null : Colors.grey[300]),
        ),
        const SizedBox(height: 10),
        ...menuItemOption.choices.keys
            .map((choiceName) => _optionInputChoice(
                  isDisabled:
                      !menuItemOption.available || !menuItemOption.choices[choiceName]!.available,
                  choiceName: choiceName,
                  choice: menuItemOption.choices[choiceName]!,
                  isChosen: _item.hasOptionChoice(optName, choiceName),
                  onToggled: (val) {
                    if (val) {
                      if (_item.options[optName]!.length < menuItemOption.maxChoice) {
                        setState(() {
                          _item.addOptionChoice(optName, choiceName);
                          _errMsg = "";
                        });
                      }
                    } else {
                      setState(() {
                        _item.removeOptionChoice(optName, choiceName);
                        _errMsg = "";
                      });
                    }
                  },
                ))
            .toList(),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _optionInputChoice({
    required bool isDisabled,
    required String choiceName,
    required MenuItemOptionChoice choice,
    required bool isChosen,
    required void Function(bool) onToggled,
  }) {
    return InkWell(
      key: Key(choiceName),
      onTap: isDisabled ? null : () => onToggled(!isChosen),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 5, 0, 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            isDisabled
                ? Icon(Icons.indeterminate_check_box_rounded, color: Colors.grey[300])
                : isChosen
                    ? const Icon(Icons.check_box)
                    : const Icon(Icons.check_box_outline_blank),
            const SizedBox(width: 5),
            Text(
              '$choiceName (giá: ${choice.price})${choice.available ? '' : ' (hết)'}',
              style: TextStyle(color: isDisabled ? Colors.grey[300] : null),
            )
          ],
        ),
      ),
    );
  }

  _noteInput() {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
          decoration: const InputDecoration(
            label: Text('Ghi chú'),
          ),
          onChanged: (val) {
            setState(() {
              _item.note = val;
              _errMsg = "";
            });
          }),
    );
  }

  _quantityInput() {
    const textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
    var reducable = _item.quantity > 1;
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Số lượng: ', style: textStyle),
          const SizedBox(width: 5),
          CustomButton(
            '-',
            reducable
                ? () {
                    setState(() {
                      _item.quantity--;
                      _errMsg = "";
                    });
                  }
                : null,
            color: reducable ? Colors.red : null,
          ),
          const SizedBox(width: 5),
          Text('${_item.quantity}', style: textStyle),
          const SizedBox(width: 5),
          CustomButton('+', () {
            setState(() {
              _item.quantity++;
              _errMsg = "";
            });
          }, color: Colors.green),
        ],
      ),
    );
  }

  _actionButtons() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomButton('Huỷ', () => _onCancel(context)),
          const SizedBox(width: 15),
          CustomButton('Thêm', () => _onAdd(context)),
        ],
      ),
    );
  }

  _onCancel(BuildContext context) {
    Navigator.of(context).pop<CreateOrderItem?>(null);
  }

  _onAdd(BuildContext context) {
    if (!_validateInput()) return;
    Navigator.of(context).pop<CreateOrderItem?>(_item);
  }

  bool _validateInput() {
    for (var optName in widget.menuItem.options.keys) {
      var menuOpt = widget.menuItem.options[optName]!;
      if (!menuOpt.available) continue;
      var orderOpt = _item.options[optName]!;
      if (orderOpt.length < menuOpt.minChoice) {
        setState(() {
          _errMsg = 'Tuỳ chọn "$optName" chưa đạt đủ điều kiện';
        });
        return false;
      }
    }
    return true;
  }
}
