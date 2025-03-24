import 'package:flutter/material.dart';
import 'exhibits_menu.dart';

class BurgerDrawer extends StatefulWidget {
  final void Function(String category) highlightedCategory;

  const BurgerDrawer({super.key, required this.highlightedCategory});

  @override
  State<BurgerDrawer> createState() => BurgerDrawerState();
}

class BurgerDrawerState extends State<BurgerDrawer> {

  bool showExhibitsMenu = false;

  void highlightedCategory(String category) {
    widget.highlightedCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: showExhibitsMenu ? const ExhibitsMenu() :
              ListView(
                shrinkWrap: true,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.wc_rounded),
                    title: const Text('Bathrooms'),
                    onTap: () => highlightedCategory("Bathroom"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.shopping_cart_outlined),
                    title: Text('Shops'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.food_bank_outlined),
                    title: const Text('Food'),
                    onTap: () => highlightedCategory("Cafeteria"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Exhibits'),
                    onTap: () => setState(() {
                      showExhibitsMenu = true;
                    }),
                  ),
                  const ListTile(
                    leading: Icon(Icons.web),
                    title: Text('Website'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}