import 'package:flutter/material.dart';
import 'package:indoor_crowded_regions_frontend/ui/components/error_toast.dart';
import 'exhibits_menu.dart';
import 'filter_page.dart';

class BurgerDrawer extends StatefulWidget {
  final void Function(String category) highlightedCategory;
  const BurgerDrawer(
      {super.key, this.highlightedCategory = _defaultHighlightedCategory});
  static void _defaultHighlightedCategory(String category) {}
  @override
  State<BurgerDrawer> createState() => BurgerDrawerState();
}

class BurgerDrawerState extends State<BurgerDrawer> {
  bool showExhibitsMenu = false;

  void highlightedCategory(String category) {
    widget.highlightedCategory(category);
  }

  void showExhibitsMenuFunc(bool show) {
    setState(() {
      showExhibitsMenu = show;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background for drawer
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: showExhibitsMenu
                  ? ExhibitsMenu(showExhibitsMenu: showExhibitsMenuFunc)
                  : ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.wc_rounded,
                              color: Color(
                                  0xFFFF7D00)), // Brighter orange for dark mode
                          title: const Text('Bathrooms',
                              style: TextStyle(
                                  color: Colors
                                      .white)), // Light text for dark mode
                          onTap: () => highlightedCategory("Bathroom"),
                        ),
                        ListTile(
                          leading: const Icon(Icons.shopping_cart_outlined,
                              color: Color(
                                  0xFFFF7D00)), // Brighter orange for dark mode
                          title: const Text('Shops',
                              style: TextStyle(
                                  color: Colors
                                      .white)), // Light text for dark mode
                          onTap: () => ErrorToast.show(
                              'Shop is currently not available.'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.food_bank_outlined,
                              color: Color(
                                  0xFFFF7D00)), // Brighter orange for dark mode
                          title: const Text('Food',
                              style: TextStyle(
                                  color: Colors
                                      .white)), // Light text for dark mode
                          onTap: () => highlightedCategory("Cafeteria"),
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on_outlined,
                              color: Color(
                                  0xFFFF7D00)), // Brighter orange for dark mode
                          title: const Text('Exhibits',
                              style: TextStyle(
                                  color: Colors
                                      .white)), // Light text for dark mode
                          onTap: () => setState(() {
                            showExhibitsMenu = true;
                          }),
                        ),
                        ListTile(
                          leading: const Icon(Icons.web,
                              color: Color(
                                  0xFFFF7D00)), // Brighter orange for dark mode
                          title: const Text('Website',
                              style: TextStyle(
                                  color: Colors
                                      .white)), // Light text for dark mode
                          onTap: () => ErrorToast.show(
                              'Website is currently not available.'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on_outlined, 
                              color: Color(
                                  0xFFFF7D00)), // Brighter orange for dark mode
                          title: const Text('Filter Search',
                              style: TextStyle(
                                  color: Colors
                                      .white)), // Light text for dark mode
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FilterPage(),
                            ),
                          ),
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
