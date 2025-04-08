import '../widgets/room.dart';
import '../widgets/burger_menu.dart';
import '../widgets/path/line_path.dart';
import '../widgets/user_location_widget.dart';
import '../widgets/burger_drawer.dart';
import '../../services/api_service.dart';
import '../../services/gateway_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  @visibleForTesting
  final Future<List<Map<String, dynamic>>> Function(dynamic)? loadGraphDataFn;
  @visibleForTesting
  final bool skipUserLocation;
  final GatewayService? gatewayService;
  
  const HomeScreen({
    super.key,
    this.loadGraphDataFn,
    this.skipUserLocation = false,
    this.gatewayService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final APIService apiService = APIService();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<UserLocationWidgetState> userLocationKey = GlobalKey<UserLocationWidgetState>();
  MapController mapController = MapController();
  UserLocationWidget? userLocationWidget;
  double _currentZoom = 18.0;
  int _currentFloor = 1;
  String highlightedCategory = "";
  late Future<List<Map<String, dynamic>>> _edgesFuture;

  @override
  void initState() {
    super.initState();
    if (!widget.skipUserLocation) {
      userLocationWidget = UserLocationWidget(
        key: userLocationKey,
        mapController: mapController,
      );
    }
    if (widget.loadGraphDataFn != null) {
      _edgesFuture = widget.loadGraphDataFn!("test");
    } else {
      final gatewayService = widget.gatewayService ?? GatewayService();
      _edgesFuture = gatewayService.getFastestRouteWithCoordinates(
        "67efbb220b23f5290bff707f",
        "67efbb220b23f5290bff7080",
      );
    }
  }

  @visibleForTesting
  void setZoom(double zoom) {
    setState(() {
      _currentZoom = zoom;
    });
  }

  void highlightRooms(String category) {
    setState(() {
      highlightedCategory = (highlightedCategory == category) ? "" : category;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: BurgerDrawer(highlightedCategory: highlightRooms),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              onMapEvent: (MapEvent event) {
                if (event is MapEventMoveStart) {
                  userLocationKey.currentState?.updateAlteredMap(true);
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
                urlTemplate: 'assets/tiles/$_currentFloor/{z}/{x}/{y}.png',
                errorImage: const AssetImage('assets/tiles/no_tile.png'),
                fallbackUrl: 'assets/tiles/no_tile.png',
              ),
              MarkerLayer(
                markers: rooms.where((room) => _currentZoom >= room.minZoomThreshold).map((room) {
                  bool highlighted = highlightedCategory.isNotEmpty && room.name.contains(highlightedCategory);
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
                      child: Icon(
                        room.icon,
                        size: _currentZoom * 1.75,
                        color: highlighted ? Colors.blue : room.color,
                      ),
                    ),
                  );
                }).toList(),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _edgesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return LinePath(pathCoordinates: snapshot.data!);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              if (userLocationWidget != null) userLocationWidget!,
            ],
          ),
          Positioned(
            top: 40,
            left: 16,
            child: BurgerMenu(scaffoldKey: scaffoldKey),
          ),
          Positioned(
            bottom: 40,
            left: 16,
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentFloor = 3;
                    });
                  },
                  style: TextButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Text("Floor 3"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentFloor = 2;
                    });
                  },
                  style: TextButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Text("Floor 2"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentFloor = 1;
                    });
                  },
                  style: TextButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Text("Floor 1"),
                ),
              ],
            ),
          ),
          if (!widget.skipUserLocation)
            Positioned(
              bottom: 40,
              right: 16,
              child: Container(
                decoration: ShapeDecoration(
                  shape: const CircleBorder(),
                  color: Colors.black.withAlpha(80),
                ),
                child: IconButton(
                  icon: const Icon(Icons.my_location, size: 45, color: Colors.white),
                  onPressed: () {
                    userLocationKey.currentState?.updateAlteredMap(false);
                    userLocationKey.currentState?.recenterLocation();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}