import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrmos/models/auth_model.dart';

import '../cus_info_input/cus_info_input.dart';

class CusMenuScreen extends StatefulWidget {
  static const String routeName = "/menu";

  const CusMenuScreen({Key? key}) : super(key: key);

  @override
  State<CusMenuScreen> createState() => _CusMenuScreenState();
}

class _CusMenuScreenState extends State<CusMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthModel>(
      builder: (ctx, auth, _) => auth.userType != UserType.customer
          ? const CusInfoInputScreen()
          : Scaffold(
              appBar: AppBar(
                title: const Text('Menu', style: TextStyle(color: Colors.black)),
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
              ),
              body: Container(),
            ),
    );
  }
}
