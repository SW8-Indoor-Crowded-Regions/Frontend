import 'package:flutter/material.dart';

class BurgerDrawer extends StatelessWidget {
  const BurgerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: const <Widget>[
                  ListTile(
                    leading: Icon(Icons.wc_rounded),
                    title: Text('Bathrooms'),
                  ),
                  ListTile(
                    leading: Icon(Icons.shopping_cart_outlined),
                    title: Text('Shops'),
                  ),
                  ListTile(
                    leading: Icon(Icons.food_bank_outlined),
                    title: Text('Food'),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text('Highlights'),
                  ),
                  ListTile(
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
