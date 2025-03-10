import 'dart:developer';
import '../widgets/burger_menu.dart';
import '../widgets/user_location_widget.dart';
import '../widgets/burger_drawer.dart';
import '../widgets/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
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
  double _currentZoom = 18.0;

  @override
  void initState() {
    super.initState();
    userLocationWidget = UserLocationWidget(
      key: userLocationKey,
      mapController: mapController, 
    );
  }

  @visibleForTesting
  void setZoom(double zoom) {
    setState(() {
      _currentZoom = zoom;
    });
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
              onMapEvent: (MapEvent event) {
                if (event is MapEventMoveStart) {
                  userLocationWidget.updateAlteredMap(true);
                }
              },
              initialCenter: const LatLng(55.68875, 12.5783),
              minZoom: 17.5,
              maxZoom: 20,
              initialCameraFit: CameraFit.bounds(
                bounds: LatLngBounds(
                  const LatLng(55.68838827, 12.576953),
                  const LatLng(55.689119, 12.57972968),
                ),
                padding: const EdgeInsets.all(20),
              ),
              onPositionChanged: (position, hasGesture) {
                setState(() {
                  _currentZoom = position.zoom;
                });
              },
            ),
            children: [
              TileLayer(
                tileProvider: AssetTileProvider(),
                urlTemplate: 'assets/tiles/{z}/{x}/{y}.png',
                errorImage: const AssetImage('assets/tiles/no_tile.png'),
                fallbackUrl: 'assets/tiles/no_tile.png',
              ),
              MarkerLayer(
                markers: rooms.where((room) => _currentZoom >= room.minZoomThreshold).map((room) {
                  return Marker(
                    point: room.location,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(room.name),
                            content: Text(room.description),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Icon(room.icon, size: _currentZoom * 1.75, color: room.color),
                    ),
                  );
                }).toList(),
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
