import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/menu/menu.dart';

class ItemOptionCard extends StatelessWidget {
  final String optionName;
  final MenuItemOption option;
  final List<String> chosenChoices;
  final void Function(String) onToggleChoice;

  const ItemOptionCard({
    Key? key,
    required this.optionName,
    required this.option,
    required this.chosenChoices,
    required this.onToggleChoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(optionName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 5),
          Text('(chọn ít nhất ${option.minChoice}, nhiều nhất ${option.maxChoice})'),
          const SizedBox(height: 5),
          ..._choices(),
        ],
      ),
    );
  }

  _choices() {
    var choices = [];
    for (var choiceName in option.choices.keys) {
      var choice = option.choices[choiceName]!;
      var isChosen = chosenChoices.contains(choiceName);
      choices.add(const SizedBox(height: 10));
      choices.add(InkWell(
        onTap: choice.available ? () => onToggleChoice(choiceName) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            choice.available
                ? isChosen
                    ? const Icon(Icons.check_box)
                    : const Icon(Icons.check_box_outline_blank)
                : const Icon(Icons.check_box_outline_blank, color: Colors.grey),
            const SizedBox(width: 5),
            Text(
              '$choiceName (${choice.price}đ)${choice.available ? '' : ' (tạm hết)'}',
              style: choice.available ? null : const TextStyle(color: Colors.grey),
            )
          ],
        ),
      ));
    }
    return choices;
  }
}
