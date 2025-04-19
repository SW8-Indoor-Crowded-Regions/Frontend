import '../widgets/room.dart';
import '../widgets/burger_menu.dart';
import '../widgets/path/line_path.dart';
import '../widgets/user_location_widget.dart';
import '../widgets/burger_drawer.dart';
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
  @visibleForTesting
  final bool isTestMode;
  final GatewayService? gatewayService;

  const HomeScreen({
    super.key,
    this.loadGraphDataFn,
    this.skipUserLocation = false,
    this.isTestMode = false,
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
  late Future<List<PolygonArea>> _polygonsFuture = Future.value([]);
  late List<PolygonArea> _polygons = [];
  PolygonArea? _selectedPolygon;
  bool _showInfoPanel = false;
  //static const double _panelWidthFraction = 0.7;
  //static const double _maxPanelWidth = 350.0;

  // Animation controller for selected polygon
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _loadPolygons(_currentFloor);

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isTestMode) {
      // In test mode, don't animate to avoid pumpAndSettle timeouts
      _pulseAnimationController.value = 0.85; // Set to middle value
    } else {
      _pulseAnimationController.repeat(reverse: true);
    }

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

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @visibleForTesting
  void stopAnimations() {
    _pulseAnimationController.stop();
  }

  void _loadPolygons(int floor) {
    setState(() {
      _polygonsFuture = polygonService.getPolygons(floor: floor);
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
      if (mounted) {
        setState(() {
          _polygons = [];
        });
      }
    });
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
    }
    return isInside;
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    final floorPolygons = _polygons
        .where((p) => p.additionalData?['floor'] == _currentFloor)
        .toList();

    PolygonArea? tappedPolygon;
    for (var polygon in floorPolygons) {
      if (isPointInPolygon(point, polygon.points)) {
        tappedPolygon = polygon;
        break;
      }
    }

    if (tappedPolygon != null) {
      if (_selectedPolygon != null &&
          _selectedPolygon!.id == tappedPolygon.id) {
        setState(() {
          _selectedPolygon = null;
          _showInfoPanel = false;
        });
      } else {
        setState(() {
          _selectedPolygon = tappedPolygon;
          _showInfoPanel = true;
        });

        final polygonCenter = _calculatePolygonCenter(tappedPolygon.points);
        mapController.move(polygonCenter, mapController.camera.zoom);
      }
    } else {
      setState(() {
        _selectedPolygon = null;
        _showInfoPanel = false;
      });
    }
  }

  LatLng _calculatePolygonCenter(List<LatLng> points) {
    double lat = 0;
    double lng = 0;
    for (var point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  void _closePolygonPanel() {
    setState(() {
      _selectedPolygon = null;
      _showInfoPanel = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If in test mode, ensure animations are completed quickly
    if (widget.isTestMode && _pulseAnimationController.isAnimating) {
      _pulseAnimationController.stop();
    }

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
                    final floorPolygons = snapshot.data!
                        .where((polygon) =>
                            polygon.additionalData?['floor'] == _currentFloor)
                        .toList();

                    return Stack(
                      children: [
                        PolygonLayer(
                          polygons: floorPolygons
                              .where((polygon) =>
                                  _selectedPolygon == null ||
                                  polygon.id != _selectedPolygon!.id)
                              .map((polygon) => Polygon(
                                    points: polygon.points,
                                    color: Colors.green.withOpacity(0.15),
                                    borderColor: Colors.green,
                                    borderStrokeWidth: 1.5,
                                  ))
                              .toList(),
                        ),
                        if (_selectedPolygon != null)
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              if (_selectedPolygon!.points.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return PolygonLayer(
                                polygons: [
                                  Polygon(
                                    points: _selectedPolygon!.points,
                                    color: Colors.orange.withOpacity(
                                        0.5 + (_pulseAnimation.value * 0.3)),
                                    borderColor: Colors.deepOrange,
                                    borderStrokeWidth: 4.0,
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
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
                                  ? Colors.orange
                                  : Colors.grey.withOpacity(0.7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(18),
                              minimumSize: Size(50, 50),
                              elevation: _currentFloor == floor ? 8 : 2),
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
                  padding: const EdgeInsets.all(15),
                  onPressed: () {
                    userLocationKey.currentState?.updateAlteredMap(false);
                    userLocationKey.currentState?.recenterLocation();
                  },
                  tooltip: 'Recenter Map',
                ),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showInfoPanel ? 0 : -350,
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
