import 'package:flutter/material.dart';
import '../widgets/burger_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BurgerMenu(scaffoldKey: scaffoldKey),
      ),
      drawer: Drawer(
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
