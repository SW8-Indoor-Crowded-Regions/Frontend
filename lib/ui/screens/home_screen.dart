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
import '../widgets/top_bar.dart';

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
  String? _fromRoomName;
  String? _toRoomName;
  bool _showRoutePanel = false;
  bool _showTopBar = false;
  bool _selectingFromRoom = false;
  bool _selectingToRoom = false;

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
      _pulseAnimationController.value = 0.85;
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
        "67efbb210b23f5290bff703d",
        "67efbb1f0b23f5290bff6ffa",
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
      _showTopBar = false;
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
      _showTopBar = false;
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
    print(
        "Map tapped at: ${point.latitude}, ${point.longitude}"); // Debug print

    final floorPolygons = _polygons
        .where((p) => p.additionalData?['floor'] == _currentFloor)
        .toList();

    PolygonArea? tappedPolygon;
    for (var polygon in floorPolygons) {
      if (isPointInPolygon(point, polygon.points)) {
        tappedPolygon = polygon;
        print("Tapped on polygon: ${polygon.name}"); // Debug print
        break;
      }
    }

    if (tappedPolygon != null) {
      // If we're in "selecting from" mode
      if (_selectingFromRoom && _showTopBar) {
        print("Setting from room to: ${tappedPolygon.name}"); // Debug print
        setState(() {
          _fromRoomName = tappedPolygon!.name;
          _selectingFromRoom = false;
          _showInfoPanel = false;
        });
        return;
      }

      // If we're in "selecting to" mode
      if (_selectingToRoom && _showTopBar) {
        print("Setting to room to: ${tappedPolygon.name}"); // Debug print
        setState(() {
          _toRoomName = tappedPolygon!.name;
          _selectingToRoom = false;
          _showInfoPanel = false;
        });
        return;
      }

      // Normal room selection behavior
      if (_selectedPolygon != null &&
          _selectedPolygon!.id == tappedPolygon.id) {
        setState(() {
          _selectedPolygon = null;
          _showInfoPanel = false;
          _showTopBar = false;
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
        if (!_showTopBar) {
          _selectingFromRoom = false;
          _selectingToRoom = false;
        }
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
      _showTopBar = false;
    });
  }

  void _handleShowRoute(String roomId) {
    // Find the room name from the ID
    final roomName = _selectedPolygon?.name ?? "Unknown Room";

    setState(() {
      _toRoomName = roomName; // Save destination room name
      _showRoutePanel = true; // Show the top panel
      _showTopBar = true; // Show the top bar for route planning
      _showInfoPanel = false; // Hide the bottom info panel
    });
  }

  void _handleRouteChanged(String? from, String? to) {
    setState(() {
      _fromRoomName = from;
      _toRoomName = to;
    });
  }

  void _handleFromPressed() {
    print("From pressed"); // Debug print
    setState(() {
      _selectingFromRoom = true;
      _selectingToRoom = false;
      _showInfoPanel = false; // Hide the bottom info panel
    });
  }

  void _handleToPressed() {
    print("To pressed"); // Debug print
    setState(() {
      _selectingToRoom = true;
      _selectingFromRoom = false;
      _showInfoPanel = false; // Hide the bottom info panel
    });
  }

  void _closeTopBar() {
    setState(() {
      _showTopBar = false;
      _showRoutePanel = false;
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
                              .map((polygon) {
                            // Use a different color for polygons when in selection mode
                            final isSelectionMode =
                                _selectingFromRoom || _selectingToRoom;
                            return Polygon(
                              points: polygon.points,
                              // The withValues fix does not work BTW, so i have ignored. If it gives troubles later, i will fix.
                              // ignore: deprecated_member_use
                              color: isSelectionMode
                                  ? Colors.blue.withOpacity(0.15)
                                  : Colors.green.withOpacity(0.15),
                              borderColor:
                                  isSelectionMode ? Colors.blue : Colors.green,
                              borderStrokeWidth: isSelectionMode ? 2.0 : 1.5,
                            );
                          }).toList(),
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
                                    // The withValues fix does not work BTW, so i have ignored. If it gives troubles later, i will fix.
                                    // ignore: deprecated_member_use
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
                                  // The withValues fix does not work BTW, so i have ignored. If it gives troubles later, i will fix.
                                  // ignore: deprecated_member_use
                                  : Colors.grey.withOpacity(0.7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(18),
                              minimumSize: const Size(50, 50),
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
                    onShowRoute: (roomId) => _handleShowRoute(roomId),
                  )
                : const SizedBox.shrink(),
          ),
          if (_showTopBar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: TopBar(
                  title: "Route Planner",
                  fromRoomName: _fromRoomName,
                  toRoomName: _toRoomName,
                  onRouteChanged: _handleRouteChanged,
                  onClose: _closeTopBar,
                  onFromPressed: _handleFromPressed,
                  onToPressed: _handleToPressed,
                ),
              ),
            ),
          // Selection mode overlay
          if (_selectingFromRoom || _selectingToRoom)
            Stack(
              children: [
                // Semi-transparent overlay that allows taps to pass through
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                ),
                // Top tooltip (positioned to not interfere with map taps)
                Positioned(
                  top: 80, // Position below the TopBar
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _selectingFromRoom
                                    ? Icons.my_location
                                    : Icons.location_on,
                                color: Colors.orange.shade800,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  _selectingFromRoom
                                      ? "Tap on a room to set as your starting point"
                                      : "Tap on a room to set as your destination",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom cancel button (not ignoring pointer events so it can be tapped)
                Positioned(
                  bottom:
                      120, // Position higher to avoid interfering with map taps on rooms
                  right: 16,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectingFromRoom = false;
                          _selectingToRoom = false;
                        });
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cancel, color: Colors.red.shade800),
                            const SizedBox(width: 8),
                            Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
