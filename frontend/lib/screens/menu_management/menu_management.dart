import 'package:flutter/material.dart';
import 'package:qrmos/services/qrmos/qrmos.dart';
import 'package:qrmos/widgets/screen_name.dart';

import 'widgets/category_table.dart';
import 'widgets/create_menu_cat_dialog.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({Key? key}) : super(key: key);

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  bool _isLoading = false;
  List<MenuCategory> _categories = [];
  List<MenuItem> _items = [];
  List<MenuAssociation> _associations = [];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  _loadMenu() async {
    setState(() {
      _isLoading = true;
      _categories = [];
      _items = [];
      _associations = [];
    });

    var apiResp = await getMenu();
    if (apiResp.error != null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    var menu = apiResp.data!;
    setState(() {
      _isLoading = false;
      _categories = menu.categories;
      _items = menu.items;
      _associations = menu.associations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenNameText("Quản lý danh mục"),
          Container(height: 20),
          CategoryTable(
            isLoading: _isLoading,
            categories: _categories,
            onCatDeleteButtonPressed: (catId) {
              _onCatDeleteButtonPressed(catId);
            },
          ),
          Container(height: 10),
          ElevatedButton(
            child: const Text("Tạo danh mục"),
            onPressed: () {
              _onCreateNewCatPressed(context);
            },
          ),
        ],
      ),
    );
  }

  void _onCatDeleteButtonPressed(int catId) async {
    var apiResp = await deleteMenuCat(catId);
    if (apiResp.error != null) {
      // ignore: avoid_print
      print(apiResp.error!.message);
      return;
    }
    _loadMenu();
  }

  void _onCreateNewCatPressed(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (_) => const CreateMenuCatDialog(),
    );
    if (result == true) await _loadMenu();
  }
}
