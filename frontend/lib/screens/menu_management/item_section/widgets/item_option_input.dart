import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart';
import 'package:qrmos/widgets/input/number_input_field.dart';
import 'package:qrmos/widgets/table/table.dart';

class ItemOptionInput extends StatefulWidget {
  final String optionName;
  final MenuItemOption option;
  final void Function(String, MenuItemOption) onChanged;
  final void Function() onDeleteOptionPressed;
  final bool isModifying;
  final void Function(bool) onModifyingChanged;

  const ItemOptionInput({
    Key? key,
    required this.optionName,
    required this.option,
    required this.onChanged,
    required this.onDeleteOptionPressed,
    required this.isModifying,
    required this.onModifyingChanged,
  }) : super(key: key);

  @override
  State<ItemOptionInput> createState() => _ItemOptionInputState();
}

class _ItemOptionInputState extends State<ItemOptionInput> {
  String _optName = "";
  MenuItemOption _option = MenuItemOption();

  final List<_ItemOptionChoice> _choices = [];

  String _errMsg = "";

  @override
  void initState() {
    super.initState();
    _optName = widget.optionName;
    _option = widget.option;
    _choices.addAll(widget.option.choices.keys
        .map((choiceName) => _ItemOptionChoice(
              choiceName,
              widget.option.choices[choiceName]!,
            ))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomTable(
                columnWidths: const {
                  0: FixedColumnWidth(200),
                  1: FixedColumnWidth(150),
                  2: FixedColumnWidth(150),
                  3: FixedColumnWidth(400),
                },
                children: [
                  widget.isModifying ? _modifyTable() : _showInfoTable(),
                ],
              ),
              const SizedBox(width: 5, height: 5),
              Column(children: [
                widget.isModifying
                    ? ElevatedButton(
                        child: const Text("Ch???nh xong"),
                        onPressed: _onDoneButtonPressed,
                      )
                    : ElevatedButton(
                        child: const Text("Ch???nh"),
                        onPressed: () {
                          widget.onModifyingChanged(true);
                        },
                      ),
                const SizedBox(width: 5, height: 5),
                ElevatedButton(
                  child: const Text("Xo??"),
                  onPressed: widget.onDeleteOptionPressed,
                ),
              ]),
              const SizedBox(width: 5, height: 5),
            ],
          ),
          Text(_errMsg, style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  _onDoneButtonPressed() {
    if (!_validateInputs()) {
      return;
    }
    setState(() {
      _errMsg = "";
    });
    _option.choices = {};
    for (var choice in _choices) {
      _option.choices[choice.name] = choice.choice;
    }
    widget.onChanged(_optName, _option);
    widget.onModifyingChanged(false);
  }

  bool _validateInputs() {
    if (_optName == "") {
      _setErrMsg("T??n tu??? ch???n kh??ng ???????c ????? r???ng");
      return false;
    }
    if (_option.maxChoice < _option.minChoice) {
      _setErrMsg("??i???u ki???n t???i thi???u ph???i nh??? h??n ho???c b???ng ??i???u ki???n t???i ??a");
      return false;
    }
    if (_choices.length < _option.minChoice) {
      _setErrMsg("S??? l?????ng l???a ch???n ??t h??n ??i???u ki???n t???i thi???u");
      return false;
    }
    Map<String, bool> m = {};
    for (var choice in _choices) {
      if (choice.name == "") {
        _setErrMsg("T??n l???a ch???n kh??ng ???????c r???ng");
        return false;
      }
      if (m[choice.name] == true) {
        _setErrMsg("L???a ch???n '${choice.name}' b??? tr??ng l???p");
        return false;
      }
      m[choice.name] = true;
    }
    return true;
  }

  _setErrMsg(String msg) {
    setState(() {
      _errMsg = msg;
    });
  }

  TableRow _modifyTable() {
    return TableRow(
      children: [
        _nameInput(),
        _availableInput(),
        _choiceConstraintsInput(),
        _choiceListTableInput(),
      ],
    );
  }

  _nameInput() {
    return Container(
      padding: const EdgeInsets.all(5),
      child: TextFormField(
        initialValue: widget.optionName,
        decoration: const InputDecoration(
          labelText: "T??n tu??? ch???n",
        ),
        onChanged: (val) {
          setState(() {
            _optName = val;
            _errMsg = "";
          });
        },
      ),
    );
  }

  _availableInput() {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          const Text("C??n h??ng:"),
          const SizedBox(width: 5, height: 5),
          Switch(
              value: _option.available,
              onChanged: (val) {
                setState(() {
                  _option.available = val;
                  _errMsg = "";
                });
              }),
        ],
      ),
    );
  }

  _choiceConstraintsInput() {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _smallNumberField(
              label: "??t nh???t: ",
              initialValue: _option.minChoice,
              value: _option.minChoice,
              onChanged: (val) {
                setState(() {
                  _option.minChoice = val;
                  _errMsg = "";
                });
              }),
          _smallNumberField(
              label: "Nhi???u nh???t: ",
              initialValue: _option.maxChoice,
              value: _option.maxChoice,
              onChanged: (val) {
                setState(() {
                  _option.maxChoice = val;
                  _errMsg = "";
                });
              }),
        ],
      ),
    );
  }

  _choiceListTableInput() {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FixedColumnWidth(150),
              1: FixedColumnWidth(80),
              2: FixedColumnWidth(80),
              3: FixedColumnWidth(80),
            },
            children: [
              ..._choices.map((itemChoice) => _choiceInputRow(itemChoice)).toList(),
            ],
          ),
          const SizedBox(width: 5, height: 5),
          ElevatedButton(
            child: const Text("Th??m"),
            onPressed: _onAddChoiceButtonPressed,
          ),
        ],
      ),
    );
  }

  _choiceInputRow(_ItemOptionChoice itemChoice) {
    return TableRow(
      key: itemChoice.uniqueKey,
      children: [
        _choiceNameInputField(itemChoice),
        _choicePriceInputField(itemChoice),
        _choiceAvailableInputField(itemChoice),
        Center(
            child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _onDeleteChoice(itemChoice);
                  _errMsg = "";
                })),
      ],
    );
  }

  _choiceNameInputField(_ItemOptionChoice itemChoice) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
      child: TextFormField(
          initialValue: itemChoice.name,
          decoration: const InputDecoration(
            label: Text("T??n l???a ch???n"),
          ),
          onChanged: (val) {
            setState(() {
              itemChoice.name = val;
              _errMsg = "";
            });
          }),
    );
  }

  _choicePriceInputField(_ItemOptionChoice itemChoice) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: NumberInputField(
        decoration: const InputDecoration(
          label: Text("Gi??"),
        ),
        initialValue: itemChoice.choice.price,
        onChanged: (val) {
          setState(() {
            itemChoice.choice.price = val;
            _errMsg = "";
          });
        },
      ),
    );
  }

  _choiceAvailableInputField(_ItemOptionChoice itemChoice) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("C??n h??ng: "),
          Switch(
              value: itemChoice.choice.available,
              onChanged: (val) {
                setState(() {
                  itemChoice.choice.available = val;
                  _errMsg = "";
                });
              }),
        ],
      ),
    );
  }

  void _onDeleteChoice(_ItemOptionChoice itemChoice) {
    setState(() {
      _choices.remove(itemChoice);
      _errMsg = "";
    });
  }

  _onAddChoiceButtonPressed() {
    setState(() {
      _choices.add(_ItemOptionChoice("", MenuItemOptionChoice()));
      _errMsg = "";
    });
  }

  Widget _smallNumberField({
    required String label,
    required int initialValue,
    required int value,
    required void Function(int) onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: NumberInputField(
            initialValue: initialValue,
            decoration: InputDecoration(label: Text(label)),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  TableRow _showInfoTable() {
    return TableRow(
      children: [
        _rowText('Tu??? ch???n: $_optName'),
        _rowText('C??n h??ng: ${_option.available ? "C??n" : "Kh??ng"}'),
        _rowText('??i???u ki???n:\n+ ??t nh???t ${_option.minChoice}\n+ nhi???u nh???t ${_option.maxChoice}'),
        Table(
          children: [
            ..._option.choices.keys
                .map((choiceName) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text('L???a ch???n: $choiceName'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text('Gi??: ${_option.choices[choiceName]!.price}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                              _option.choices[choiceName]!.available ? "C??n h??ng" : "H???t h??ng"),
                        ),
                      ],
                    ))
                .toList(),
          ],
        ),
      ],
    );
  }

  _rowText(String text) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ItemOptionChoice {
  UniqueKey uniqueKey;
  String name;
  MenuItemOptionChoice choice;

  _ItemOptionChoice(this.name, this.choice) : uniqueKey = UniqueKey();
}
