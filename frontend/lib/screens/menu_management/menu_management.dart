import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/providers/auth_model.dart';
import 'package:qrmos/services/qrmos/qrmos.dart';
import 'package:qrmos/widgets/big_screen.dart';

import 'association_section/association_management.dart';
import 'cat_section/cat_management.dart';
import 'association_section/widgets/create_association_dialog.dart';
import 'cat_section/widgets/create_menu_cat_dialog.dart';
import 'item_section/create_item.dart';
import 'item_section/item_detail.dart';
import 'item_section/item_management.dart';

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
      menu.categories.sort((a, b) => a.name.compareTo(b.name));
      _categories = menu.categories;
      _items = menu.items;
      _associations = menu.associations;
    });
  }

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthModel>(context).staffRole;
    var isManager = auth == StaffRole.manager;

    return BigScreen(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemManagementSection(
            isLoading: _isLoading,
            items: _items,
            onItemDetailButtonPressed: (itemId) {
              _openItemDetailScreen(context, itemId);
            },
            onToggleItemAvailabilityPressed: _setItemAvailability,
            onCreateItemButtonPressed: _openCreateItemScreen(context),
          ),
          if (isManager) Container(height: 50),
          if (isManager)
            CategoryManagementSection(
              isLoading: _isLoading,
              categories: _categories,
              onDeleteCatButtonPressed: _onDeleteCatButtonPressed,
              onCreateNewCatPressed: _onCreateNewCatPressed(context),
            ),
          if (isManager) Container(height: 50),
          if (isManager)
            AssociationManagementSection(
              isLoading: _isLoading,
              categories: _categories,
              items: _items,
              associations: _associations,
              onDeleteAssociationButtonPressed: _onDeleteAssociationButtonPressed,
              onCreateNewAssociationPressed: _onCreateNewAssociationPressed,
            ),
        ],
      ),
    );
  }

  void _setItemAvailability(int itemId, bool available) async {
    var resp = await setItemAvailable(itemId, available);
    if (resp.error != null) {
      // ignore: avoid_print
      print(resp.error);
      return;
    }
    _loadMenu();
  }

  _openItemDetailScreen(BuildContext context, int itemId) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => MenuItemDetailScreen(itemId)));
    _loadMenu();
  }

  _openCreateItemScreen(BuildContext context) {
    return () async {
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const CreateMenuItemScreen()));
      _loadMenu();
    };
  }

  void _onDeleteCatButtonPressed(int catId) async {
    var apiResp = await deleteMenuCat(catId);
    if (apiResp.error != null) {
      // ignore: avoid_print
      print(apiResp.error!.message);
      return;
    }
    _loadMenu();
  }

  _onCreateNewCatPressed(BuildContext context) {
    return () async {
      bool? result = await showDialog<bool>(
        context: context,
        builder: (_) => const CreateMenuCatDialog(),
      );
      if (result == true) await _loadMenu();
    };
  }

  void _onDeleteAssociationButtonPressed(int catId, int itemId) async {
    var apiResp = await deleteMenuAssociation(catId, itemId);
    if (apiResp.error != null) {
      // ignore: avoid_print
      print(apiResp.error!.message);
      return;
    }
    _loadMenu();
  }

  void _onCreateNewAssociationPressed(int catId) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (_) => CreateAssociationDialog(
        catId: catId,
        items: _items.where((item) => !_checkIfAlreadyAssociated(catId, item.id)).toList(),
      ),
    );
    if (result == true) await _loadMenu();
  }

  bool _checkIfAlreadyAssociated(int catId, int itemId) {
    for (var a in _associations) {
      if (a.catId == catId && a.itemId == itemId) {
        return true;
      }
    }
    return false;
  }
}
