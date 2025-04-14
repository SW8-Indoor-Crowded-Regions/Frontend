import '../widgets/room.dart';
import '../widgets/burger_menu.dart';
import '../widgets/path/line_path.dart';
import '../widgets/user_location_widget.dart';
import '../widgets/burger_drawer.dart';
import '../widgets/polygon_layer.dart';
import '../widgets/polygon_info_panel.dart';
import '../../services/api_service.dart';
import '../../services/gateway_service.dart';
import '../../services/polygon_service.dart';
import '../../models/polygon_area.dart';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final APIService apiService = APIService();
  final PolygonService polygonService = PolygonService();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<UserLocationWidgetState> userLocationKey =
      GlobalKey<UserLocationWidgetState>();
  MapController mapController = MapController();
  UserLocationWidget? userLocationWidget;
  double _currentZoom = 18.0;
  int _currentFloor = 1;
  String highlightedCategory = "";
  late Future<List<Map<String, dynamic>>> _edgesFuture;
  late Future<List<PolygonArea>> _polygonsFuture =
      Future.value([]); // Initialize with an empty Future
  late List<PolygonArea> _polygons = [];
  PolygonArea? _selectedPolygon;
  bool _showInfoPanel = false;
  static const double _panelWidthFraction = 0.7;
  static const double _maxPanelWidth = 350.0;

  @override
  void initState() {
    super.initState();

    _loadPolygons(_currentFloor);

    if (!widget.skipUserLocation) {
      userLocationWidget = UserLocationWidget(
        key: userLocationKey,
        mapController: mapController,
      );
    }
  }

  void _loadPolygons(int floor) {
    setState(() {
      if (floor == 1) {
        _polygonsFuture = Future.value(polygonService.getPolygons());
      } else {
        _polygonsFuture = polygonService.getPolygons(floor: floor);
      }
      _selectedPolygon = null;
      _showInfoPanel = false;
    });
    _polygonsFuture.then((data) {
      if (mounted) {
        setState(() {
          _polygons = data;
        });
      }
    }).catchError((error) {
      print("Error loading polygons: $error");
      if (mounted) {
        setState(() {
          _polygons = [];
        });
      }
    });

    // Uncomment this code if you need to load graph data
    // if (widget.loadGraphDataFn != null) {
    //   _edgesFuture = widget.loadGraphDataFn!("test");
    // } else {
    //   final gatewayService = widget.gatewayService ?? GatewayService();
    //   _edgesFuture = gatewayService.getFastestRouteWithCoordinates(
    //     "67efbb220b23f5290bff707f",
    //     "67efbb220b23f5290bff7080",
    //   );
    // }
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
      _selectedPolygon = null;
    });
    Navigator.pop(context);
  }

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.isEmpty) return false;
    bool isInside = false;
    int j = polygon.length - 1;
    // ray-casting algorithm
    for (int i = 0; i < polygon.length; j = i++) {
      if (((polygon[i].latitude > point.latitude) !=
              (polygon[j].latitude > point.latitude)) &&
          (point.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude)) {
        isInside = !isInside;
      }
      // Removed redundant j = i assignment as it's already handled in the loop
    }
    return isInside;
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    PolygonArea? tappedPolygon;
    for (var polygon in _polygons) {
      if (isPointInPolygon(point, polygon.points)) {
        tappedPolygon = polygon;
        break;
      }
    }
    setState(() {
      _selectedPolygon = tappedPolygon;
      _showInfoPanel =
          tappedPolygon != null; // Show panel if a polygon is selected
    });
  }

  void _closePolygonPanel() {
    setState(() {
      _selectedPolygon = null;
      _showInfoPanel = false; // Hide the panel when closed
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth * _panelWidthFraction > _maxPanelWidth
        ? _maxPanelWidth
        : screenWidth * _panelWidthFraction;
    return Scaffold(
      key: scaffoldKey,
      drawer: BurgerDrawer(highlightedCategory: highlightRooms),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              onTap: _handleMapTap,
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
              FutureBuilder<List<PolygonArea>>(
                future: _polygonsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    _polygons = snapshot.data!;
                    return PolygonLayer(
                      polygons: _polygons.map((polygon) {
                        final isSelected = _selectedPolygon?.id == polygon.id;
                        return Polygon(
                          points: polygon.points,
                          color: isSelected
                              ? Colors.blue.withOpacity(0.6) // Highlight color
                              : Colors.green.withOpacity(0.3), // Default color
                          borderColor: isSelected ? Colors.blue : Colors.green,
                          borderStrokeWidth: isSelected ? 3.0 : 1.5,
                        );
                      }).toList(),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              MarkerLayer(
                markers: rooms
                    .where((room) => _currentZoom >= room.minZoomThreshold)
                    .map((room) {
                  bool highlighted = highlightedCategory.isNotEmpty &&
                      room.name.contains(highlightedCategory);
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
              // Removed duplicate FutureBuilder with undefined InteractivePolygonLayer
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
              children: [1, 2, 3]
                  .map((floor) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextButton(
                          onPressed: () {
                            if (_currentFloor != floor) {
                              setState(() {
                                _currentFloor = floor;
                              });
                              _loadPolygons(floor);
                            }
                          },
                          style: TextButton.styleFrom(
                              shape: const CircleBorder(),
                              backgroundColor: _currentFloor == floor
                                  ? Colors.blueAccent
                                  : Colors.blue.withOpacity(0.7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(18),
                              minimumSize: Size(50, 50)),
                          child: Text("$floor"),
                        ),
                      ))
                  .toList()
                  .reversed
                  .toList(),
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
                  icon: const Icon(Icons.my_location,
                      size: 30, color: Colors.white),
                  padding: EdgeInsets.all(15),
                  onPressed: () {
                    userLocationKey.currentState?.updateAlteredMap(false);
                    userLocationKey.currentState?.recenterLocation();
                  },
                  tooltip: 'Recenter Map',
                ),
              ),
            ),
          // Bottom sliding panel for polygon info
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showInfoPanel ? 0 : -350, // Slide up from below the screen
            left: 0,
            right: 0,
            child: _selectedPolygon != null
                ? PolygonInfoPanel(
                    polygon: _selectedPolygon!,
                    onClose: _closePolygonPanel,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
