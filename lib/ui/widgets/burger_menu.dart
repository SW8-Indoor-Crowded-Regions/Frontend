import 'package:flutter/material.dart';

class BurgerMenu extends StatelessWidget {

  final GlobalKey<ScaffoldState> scaffoldKey;
  const BurgerMenu({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        scaffoldKey.currentState?.openDrawer();
      },
    );
  }

}