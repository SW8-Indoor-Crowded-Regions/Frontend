import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../widgets/burger_menu.dart';
import '../widgets/user_location_widget.dart';
import '../widgets/burger_drawer.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<UserLocationWidgetState> userLocationKey = GlobalKey<UserLocationWidgetState>();
  MapController mapController = MapController();
  late UserLocationWidget userLocationWidget;

  @override
  void initState() {
    super.initState();
    userLocationWidget = UserLocationWidget(
      key: userLocationKey,
      mapController: mapController, 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const BurgerDrawer(),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(55.68884226230179, 12.578320553437063),
              initialZoom: 17.5,
              onMapEvent: (MapEvent event) {
                if (event is MapEventMoveStart) {
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
          Positioned(
            top: 40,
            left: 16,
            child: BurgerMenu(scaffoldKey: scaffoldKey),
          ),
          Positioned(
            bottom: 40, 
            right: 16, 
            child: Container(
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: IconButton(
                icon: const Icon(Icons.my_location, size: 45, color: Colors.white),
                onPressed: () {
                  userLocationWidget.updateAlteredMap(false);
                  userLocationKey.currentState?.recenterLocation();
                },
              ),
            )
          ),
        ],
      ),        
    );
  }
}
