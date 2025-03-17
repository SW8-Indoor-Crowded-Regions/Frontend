import 'package:flutter/material.dart';

class BurgerMenu extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const BurgerMenu({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3), 
        borderRadius: BorderRadius.circular(12), 
      ),
      child: IconButton(
        icon: const Icon(Icons.menu, size: 40, color: Colors.white),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
    );
  }
}
