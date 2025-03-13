import 'package:flutter/material.dart';

class BurgerDrawer extends StatelessWidget {
  final void Function(String category) highlightedCategory;

  const BurgerDrawer({super.key, required this.highlightedCategory});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ListView(
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
                  const ListTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text('Highlights'),
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
