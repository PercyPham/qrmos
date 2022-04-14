import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/providers/auth_model.dart';
import 'package:qrmos/services/local/get_dest_info.dart';
import 'package:qrmos/services/qrmos/error_msg_translation.dart';
import 'package:qrmos/services/qrmos/menu/menu.dart';
import 'package:qrmos/services/qrmos/order/create_order.dart';
import 'package:qrmos/widgets/error_message.dart';
import 'package:qrmos/widgets/tray_item.dart';

import '../cus_menu_item/cus_menu_item.dart';
import '../cus_info_input/cus_info_input.dart';
import '../cus_order_history/cus_order_history.dart';
import '../cus_tray/cus_tray.dart';
import 'widgets/category_card.dart';

class CusMenuScreen extends StatefulWidget {
  static const String routeName = "/menu";

  const CusMenuScreen({Key? key}) : super(key: key);

  @override
  State<CusMenuScreen> createState() => _CusMenuScreenState();
}

class _CusMenuScreenState extends State<CusMenuScreen> {
  bool _isLoading = false;
  Menu? _menu;
  String _errMsg = '';

  final List<TrayItem> _trayItems = [];

  @override
  void initState() {
    super.initState();
    Provider.of<AuthModel>(context, listen: false).loadAccessTokenFromLocal();
    _loadContent();
  }

  _loadContent() {
    if (_checkSavedDestInfo()) {
      _loadMenu();
    }
  }

  _loadMenu() async {
    if (!_checkSavedDestInfo()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errMsg = '';
    });

    var resp = await getMenu();
    if (resp.error != null) {
      setState(() {
        _isLoading = false;
        _errMsg = translateErrMsg(resp.error);
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _menu = resp.data;
    });
  }

  bool _checkSavedDestInfo() {
    final destInfo = getDestInfo();
    if (destInfo == null) {
      setState(() {
        _errMsg = 'Vui lòng quét mã QR tại quán';
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(
      builder: (ctx, auth, _) => auth.userType != UserType.customer
          ? CusInfoInputScreen(onDone: _loadContent)
          : Scaffold(
              appBar: _appBar('FlyWithCodeX Coffee', context),
              floatingActionButton: _floatingTrayButton(context),
              body: _errMsg != ""
                  ? Center(child: ErrorMessage(_errMsg))
                  : _isLoading
                      ? const Center(child: Text('Loading...'))
                      : _menuSection(context),
            ),
    );
  }

  _menuSection(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            ..._categorizedMenuItemsCards(context),
            ..._uncategorizedMenuItemsCards(context),
            const SizedBox(height: 20),
            _refreshMenuButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  _refreshMenuButton() {
    return Center(
      child: IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: _loadContent,
        iconSize: 30,
      ),
    );
  }

  _appBar(String title, BuildContext context) {
    return AppBar(
      centerTitle: false,
      leadingWidth: 0,
      title: Text(title),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.brown,
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () => _onHistoryButtonPressed(context),
        ),
      ],
    );
  }

  _onHistoryButtonPressed(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const CusOrderHistoryScreen()));
  }

  _categorizedMenuItemsCards(BuildContext context) {
    var categories = _menu!.categories;
    categories.sort((a, b) => a.name.compareTo(b.name));

    List<CategoryCard> cards = [];
    for (var cat in categories) {
      var menuItems = _getMenuItemsOfCategory(cat.id);
      if (menuItems.isNotEmpty) {
        cards.add(CategoryCard(
          category: cat,
          menuItems: menuItems,
          onMenuItemTap: (mItem) => _onMenuItemTap(context, mItem),
        ));
      }
    }

    return cards;
  }

  List<MenuItem> _getMenuItemsOfCategory(int catId) {
    final associations = _menu!.associations.where((a) => a.catId == catId).toList();
    Map<int, MenuItem> m = {};
    for (var menuItem in _menu!.items) {
      m[menuItem.id] = menuItem;
    }
    List<MenuItem> menuItems = [];
    for (var a in associations) {
      menuItems.add(m[a.itemId]!);
    }
    menuItems.sort((a, b) => a.id.compareTo(b.id));
    return menuItems;
  }

  _uncategorizedMenuItemsCards(BuildContext context) {
    List<CategoryCard> result = [];
    var menuItems = _getUncategorizedMenuItems();
    if (menuItems.isNotEmpty) {
      result.add(CategoryCard(
        category: MenuCategory(0, 'Ngoài danh mục', ''),
        menuItems: menuItems,
        onMenuItemTap: (mItem) => _onMenuItemTap(context, mItem),
      ));
    }
    return result;
  }

  List<MenuItem> _getUncategorizedMenuItems() {
    Map<int, bool> m = {};
    for (var a in _menu!.associations) {
      m[a.itemId] = true;
    }
    List<MenuItem> menuItems = [];
    for (var menuItem in _menu!.items) {
      if (m[menuItem.id] != true) {
        menuItems.add(menuItem);
      }
    }
    menuItems.sort((a, b) => a.id.compareTo(b.id));
    return menuItems;
  }

  _onMenuItemTap(BuildContext context, MenuItem mItem) async {
    var result = await Navigator.of(context)
        .push<CreateOrderItem>(MaterialPageRoute(builder: (context) => CusMenuItemScreen(mItem)));
    if (result != null) {
      setState(() {
        _trayItems.add(TrayItem(
          menuItem: mItem,
          orderItem: result,
        ));
      });
    }
  }

  _floatingTrayButton(BuildContext context) {
    var count = _trayItems.isEmpty
        ? 0
        : _trayItems.map((i) => i.orderItem.quantity).reduce((v, e) => v + e);
    return FloatingActionButton(
      backgroundColor: Colors.brown,
      child: Stack(children: [
        const Center(child: Icon(Icons.shopping_cart_checkout)),
        if (count != 0)
          Container(
            alignment: Alignment.topRight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.circle, color: Colors.red),
                Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
      ]),
      onPressed: () => _onTrayButtonPressed(context),
    );
  }

  _onTrayButtonPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => CusTrayScreen(
                trayItems: _trayItems,
                onUpdateOrderItem: _onUpdateOrderItem,
                onDeleteTrayItem: _onDeleteTrayItem,
                onOrderCreated: _onOrderCreated,
              )),
    );
  }

  _onUpdateOrderItem(TrayItem trayItem, CreateOrderItem orderItem) {
    setState(() {
      final foundIdx = _trayItems.indexWhere((i) => i.key == trayItem.key);
      _trayItems[foundIdx] = TrayItem(
        menuItem: trayItem.menuItem,
        orderItem: orderItem,
      );
    });
  }

  _onDeleteTrayItem(TrayItem trayItem) {
    setState(() {
      _trayItems.remove(trayItem);
    });
  }

  void _onOrderCreated() {
    setState(() {
      _trayItems.clear();
    });
  }
}
