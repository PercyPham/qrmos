import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart';
import 'package:qrmos/widgets/input/number_input_field.dart';

import 'widgets/item_option_input.dart';

class CreateMenuItemScreen extends StatefulWidget {
  const CreateMenuItemScreen({Key? key}) : super(key: key);

  @override
  State<CreateMenuItemScreen> createState() => _CreateMenuItemScreenState();
}

class _CreateMenuItemScreenState extends State<CreateMenuItemScreen> {
  String _name = "";
  String _description = "";
  bool _available = false;
  PlatformFile? _image;
  int _baseUnitPrice = 0;

  final List<_ItemOption> _itemOptions = [];

  String _errMsg = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo món mới"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _textInputRow(
              label: "Tên món: ",
              autofocus: true,
              onChanged: (val) {
                setState(() {
                  _name = val;
                  _errMsg = "";
                });
              },
            ),
            _textInputRow(
              label: "Mô tả: ",
              isMultipleLines: true,
              onChanged: (val) {
                setState(() {
                  _description = val;
                  _errMsg = "";
                });
              },
            ),
            _switchInputRow(
              label: "Còn hàng: ",
              value: _available,
              onChanged: (val) {
                setState(() {
                  _available = val;
                  _errMsg = "";
                });
              },
            ),
            _imagePicker(),
            _numInputRow(
              label: "Giá cơ bản: ",
              onChanged: (val) {
                setState(() {
                  _baseUnitPrice = val;
                  _errMsg = "";
                });
              },
            ),
            Container(height: 10),
            const Text("Tuỳ chọn:"),
            ..._optionInputRows(),
            Container(height: 10),
            ElevatedButton(
              child: const Text("Thêm tuỳ chọn"),
              onPressed: _onAddOptionButtonPressed,
            ),
            Container(height: 10),
            Text(_errMsg, style: const TextStyle(color: Colors.red)),
            Container(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  child: const Text("Huỷ"),
                  onPressed: _onCancelButtonPressed(context),
                ),
                const SizedBox(height: 10, width: 10),
                ElevatedButton(
                  child: const Text("Tạo"),
                  onPressed: _errMsg != "" ? null : _onCreateButtonPressed(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row _textInputRow({
    required String label,
    bool autofocus = false,
    bool isMultipleLines = false,
    required void Function(String) onChanged,
  }) {
    return Row(
      children: [
        Text(label),
        Container(width: 20),
        SizedBox(
          width: 200,
          child: TextFormField(
            autofocus: autofocus,
            maxLines: isMultipleLines ? null : 1,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _imagePicker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text("Hình:"),
          Container(width: 20),
          ElevatedButton(
              child: const Text("Chọn"),
              onPressed: () async {
                var picked = await FilePicker.platform.pickFiles(type: FileType.image);
                if (picked != null) {
                  setState(() {
                    _image = picked.files.first;
                    _errMsg = "";
                  });
                }
              }),
          if (_image != null) Container(width: 10),
          if (_image != null) Text(_image!.name),
        ]),
        if (_image != null)
          Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(5),
            child: Image.memory(_image!.bytes!, fit: BoxFit.cover),
          ),
      ],
    );
  }

  Row _numInputRow({
    required String label,
    required void Function(int) onChanged,
  }) {
    return Row(
      children: [
        Text(label),
        Container(width: 20),
        SizedBox(
          width: 200,
          child: NumberInputField(
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Row _switchInputRow({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Text(label),
        Container(width: 20),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }

  _onCancelButtonPressed(BuildContext context) {
    return () {
      Navigator.of(context).pop<bool>(false);
    };
  }

  _onCreateButtonPressed(BuildContext context) {
    return () async {
      if (!_inputValid()) {
        return;
      }

      var imgResp = await uploadImage(_image!);
      if (imgResp.error != null) {
        _setErrMsg(translateErrMsg(imgResp.error));
        return;
      }
      var imageLink = imgResp.data!;

      Map<String, MenuItemOption> options = {};
      for (var itemOpt in _itemOptions) {
        options[itemOpt.name] = itemOpt.option;
      }

      var menuItem = MenuItem(
        id: 0,
        name: _name,
        description: _description,
        available: _available,
        baseUnitPrice: _baseUnitPrice,
        image: imageLink,
        options: options,
      );

      var resp = await createMenuItem(menuItem);
      if (resp.error != null) {
        setState(() {
          _errMsg = translateErrMsg(resp.error);
        });
        return;
      }

      Navigator.of(context).pop<bool>(true);
    };
  }

  bool _inputValid() {
    if (_name == "") {
      _setErrMsg("Tên món không được để trống");
      return false;
    }
    if (_image == null) {
      _setErrMsg("Hình không được để trống");
      return false;
    }
    if (_baseUnitPrice <= 0) {
      _setErrMsg("Giá cơ bản phải lớn hơn 0");
      return false;
    }
    Map<String, bool> m = {};
    for (var itemOpt in _itemOptions) {
      if (itemOpt.isModifying == true) {
        _setErrMsg("Vẫn còn có tuỳ chọn đang chỉnh sửa");
        return false;
      }
      if (m[itemOpt.name] == true) {
        _setErrMsg("Tuỳ chọn '${itemOpt.name}' bị trùng");
        return false;
      }
      m[itemOpt.name] = true;
    }
    return true;
  }

  _setErrMsg(String msg) {
    setState(() {
      _errMsg = msg;
    });
  }

  _optionInputRows() {
    List<ItemOptionInput> result = [];
    for (var i = 0; i < _itemOptions.length; i++) {
      var itemOpt = _itemOptions[i];
      result.add(ItemOptionInput(
        key: itemOpt.uniqueKey,
        optionName: itemOpt.name,
        option: itemOpt.option,
        isModifying: itemOpt.isModifying,
        onModifyingChanged: (val) {
          setState(() {
            itemOpt.isModifying = val;
          });
        },
        onChanged: (optName, option) {
          setState(() {
            itemOpt.name = optName;
            itemOpt.option = option;
            _errMsg = "";
          });
        },
        onDeleteOptionPressed: () {
          setState(() {
            _itemOptions.removeAt(i);
            _errMsg = "";
          });
        },
      ));
    }
    return result;
  }

  _onAddOptionButtonPressed() {
    setState(() {
      _itemOptions.add(_ItemOption("", MenuItemOption(), true));
      _errMsg = "";
    });
  }
}

class _ItemOption {
  UniqueKey uniqueKey;
  String name;
  MenuItemOption option;
  bool isModifying;

  _ItemOption(this.name, this.option, this.isModifying) : uniqueKey = UniqueKey();
}
