import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../widgets/burger_menu.dart';
import '../widgets/user_location_widget.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  MapController mapController = MapController();
  late UserLocationWidget userLocationWidget;
  bool hasAlteredMap = false;

  void onMapEvent(MapEvent event) {
    if (event is MapEventMove) {
      print("MAP EVENT OCCURRED");
      setState(() {
        hasAlteredMap = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    userLocationWidget = UserLocationWidget(mapController: mapController);
  }

  @override
  Widget build(BuildContext context) {
    print(hasAlteredMap);
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
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(55.68884226230179, 12.578320553437063),
              initialZoom: 17.5,
              onMapEvent: (MapEvent event) {
                if (event is MapEventMoveStart) {
                  print("User moved the map!");
                  userLocationWidget.updateAlteredMap(true);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              userLocationWidget,
            ],
          ),
        ],
      ),
    );
  }
}
