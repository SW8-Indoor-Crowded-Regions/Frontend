import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/burger_menu.dart';
import '../widgets/path/line_path.dart'; 
import '../widgets/user_location_widget.dart';
import '../widgets/burger_drawer.dart';
import '../widgets/polygon_info_panel.dart';
import '../widgets/top_bar.dart';
import '../../services/api_service.dart';
import '../../services/gateway_service.dart';
import '../../services/polygon_service.dart';
import '../../models/polygon_area.dart';

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
  late GatewayService _gatewayService;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<UserLocationWidgetState> userLocationKey =
      GlobalKey<UserLocationWidgetState>();

  MapController mapController = MapController();
  UserLocationWidget? userLocationWidget;
  double _currentZoom = 18.0;
  int _currentFloor = 1;

  late Future<List<PolygonArea>> _polygonsFuture = Future.value([]);
  late List<PolygonArea> _polygons = [];
  PolygonArea? _selectedPolygon;
  bool _showInfoPanel = false;

  String? _fromRoomName;
  String? _toRoomName;
  String? _fromRoomId;
  String? _toRoomId;
  bool _showTopBar = false;
  bool _selectingFromRoom = false;
  bool _selectingToRoom = false;
  late Future<List<Map<String, dynamic>>> _edgesFuture;

  String highlightedCategory = "";

  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _gatewayService = widget.gatewayService ?? GatewayService();

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
      _edgesFuture = widget.loadGraphDataFn!("test_initial_load");
    } else {
      _edgesFuture = Future.value([]);
    }
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    mapController.dispose();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading map data for floor $floor.'),
            backgroundColor: Colors.redAccent,
          ),
        );
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
      _showInfoPanel = false;
    });
    Navigator.pop(context);
  }

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.isEmpty) return false;
    bool isInside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; j = i++) {
      bool latCheck = ((polygon[i].latitude > point.latitude) !=
          (polygon[j].latitude > point.latitude));
      double lngIntersect = (polygon[j].longitude - polygon[i].longitude) *
              (point.latitude - polygon[i].latitude) /
              (polygon[j].latitude - polygon[i].latitude) +
          polygon[i].longitude;
      if (latCheck && (point.longitude < lngIntersect)) {
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
      if (_selectingFromRoom && _showTopBar) {
        setState(() {
          _fromRoomName = tappedPolygon!.name;
          _fromRoomId = tappedPolygon.id;
          _selectingFromRoom = false;
          _showInfoPanel = false;
          _selectedPolygon = null;
        });
        return;
      }

      if (_selectingToRoom && _showTopBar) {
        setState(() {
          _toRoomName = tappedPolygon!.name;
          _toRoomId = tappedPolygon.id;
          _selectingToRoom = false;
          _showInfoPanel = false;
          _selectedPolygon = null;
        });
        return;
      }

      if (_selectedPolygon != null && _selectedPolygon!.id == tappedPolygon.id) {
        setState(() {
          _selectedPolygon = null;
          _showInfoPanel = false;
        });
      }
      else {
        setState(() {
          _selectedPolygon = tappedPolygon;
          _showInfoPanel = true;
          _selectingFromRoom = false;
          _selectingToRoom = false;
        });
        final polygonCenter = _calculatePolygonCenter(tappedPolygon.points);
        mapController.move(polygonCenter, mapController.camera.zoom);
      }
    }
    else {
      setState(() {
        _selectedPolygon = null;
        _showInfoPanel = false;
      });
    }
  }

  LatLng _calculatePolygonCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);
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

  void _handleShowRoute(String roomId) {
    final roomName = _selectedPolygon?.name ?? "Unknown Room";
    final confirmedRoomId = _selectedPolygon?.id;

    if (confirmedRoomId == null) {
      return;
    }

    setState(() {
      _toRoomName = roomName;
      _toRoomId = confirmedRoomId;
      _fromRoomName = null;
      _fromRoomId = null;
      _showTopBar = true;
      _showInfoPanel = false;
      _selectedPolygon = null;
      _edgesFuture = Future.value([]);
      _selectingFromRoom = true;
      _selectingToRoom = false;
    });
  }

  void _handleFromPressed() {
    setState(() {
      _selectingFromRoom = true;
      _selectingToRoom = false;
      _showInfoPanel = false;
      _selectedPolygon = null;
    });
  }

  void _handleToPressed() {
    setState(() {
      _selectingToRoom = true;
      _selectingFromRoom = false;
      _showInfoPanel = false;
      _selectedPolygon = null;
    });
  }

  void _closeTopBar() {
    setState(() {
      _showTopBar = false;
      _selectingFromRoom = false;
      _selectingToRoom = false;
      _fromRoomId = null;
      _toRoomId = null;
      _fromRoomName = null;
      _toRoomName = null;
      _selectedPolygon = null;
      _edgesFuture = Future.value([]);
    });
  }

  void _fetchRoute() {
    if (_fromRoomId != null && _toRoomId != null) {
      setState(() {
        _edgesFuture = _gatewayService.getFastestRouteWithCoordinates(
          _fromRoomId!,
          _toRoomId!,
        );
        _selectingFromRoom = false;
        _selectingToRoom = false;
      });

       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calculating route from ${_fromRoomName ?? 'Start'} to ${_toRoomName ?? 'End'}...'),
          backgroundColor: Colors.blueAccent,
          duration: const Duration(seconds: 2),
        ),
      );

      _edgesFuture.then((routeData) {
        if (routeData.isNotEmpty && mounted) {
        } else if (routeData.isEmpty && mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                content: Text('Could not find a route between the selected points.'),
                backgroundColor: Colors.orangeAccent,
                ),
            );
        }
      }).catchError((error) {
          if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                content: Text('Error calculating route: $error'),
                backgroundColor: Colors.redAccent,
                ),
            );
          }
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both a starting point and a destination on the map.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isTestMode && _pulseAnimationController.isAnimating) {
      _pulseAnimationController.stop();
    }

    final isSelectingOnMap = _selectingFromRoom || _selectingToRoom;

    return Scaffold(
      key: scaffoldKey,
      drawer: BurgerDrawer(highlightedCategory: highlightRooms),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: const LatLng(55.68875, 12.5783),
              minZoom: 17.5,
              maxZoom: 20.0,
              initialZoom: _currentZoom,
              initialCameraFit: CameraFit.bounds(
                bounds: LatLngBounds(
                  const LatLng(55.68838827, 12.576953),
                  const LatLng(55.689119, 12.57972968),
                ),
                padding: const EdgeInsets.all(30),
              ),
              onTap: _handleMapTap,
              onMapEvent: (MapEvent event) {
                if (event is MapEventMoveStart) {
                  userLocationKey.currentState?.updateAlteredMap(true);
                }
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && position.zoom != _currentZoom) {
                   setState(() {
                     _currentZoom = position.zoom;
                   });
                }
              },
            ),
            children: [
              TileLayer(
                tileProvider: AssetTileProvider(),
                urlTemplate: 'assets/tiles/$_currentFloor/{z}/{x}/{y}.png',
                errorImage: const AssetImage('assets/tiles/no_tile.png'),
                fallbackUrl: 'assets/tiles/no_tile.png',
                keepBuffer: 8,
              ),

              FutureBuilder<List<PolygonArea>>(
                future: _polygonsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _polygons.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Map Error', style: TextStyle(color: Colors.red.shade300)));
                  } else if (snapshot.hasData || _polygons.isNotEmpty) {
                    final floorPolygons = _polygons
                        .where((polygon) =>
                            polygon.additionalData?['floor'] == _currentFloor)
                        .toList();

                    return Stack(
                      children: [
                        PolygonLayer(
                          polygons: floorPolygons
                              .where((polygon) => _selectedPolygon == null || polygon.id != _selectedPolygon!.id)
                              .map((polygon) {
                                return Polygon(
                                  points: polygon.points,
                                  color: isSelectingOnMap
                                      ? Colors.blue.withOpacity(0.15)
                                      : Colors.green.withOpacity(0.1),
                                  borderColor: isSelectingOnMap
                                      ? Colors.blueAccent.withOpacity(0.8)
                                      : Colors.green.shade300.withOpacity(0.7),
                                  borderStrokeWidth: isSelectingOnMap ? 2.0 : 1.0,
                                );
                              }).toList(),
                        ),
                        if (_selectedPolygon != null && !isSelectingOnMap)
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
                                        0.4 + (_pulseAnimation.value * 0.3)),
                                    borderColor: Colors.deepOrange.shade400,
                                    borderStrokeWidth: 3.0,
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

              FutureBuilder<List<Map<String, dynamic>>>(
                future: _edgesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _showTopBar) {
                     return const SizedBox.shrink();
                  } else if (snapshot.hasError) {
                     return const SizedBox.shrink();
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
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: BurgerMenu(scaffoldKey: scaffoldKey),
          ),

          Positioned(
            bottom: 40,
            left: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                                ? Colors.orange.shade600
                                : Colors.black.withOpacity(0.5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            minimumSize: const Size(48, 48),
                            elevation: _currentFloor == floor ? 6 : 2,
                          ),
                          child: Text("$floor", style: const TextStyle(fontWeight: FontWeight.bold)),
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
                   color: Colors.black.withOpacity(0.5),
                   shadows: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))]
                 ),
                 child: IconButton(
                   icon: const Icon(Icons.my_location, size: 28, color: Colors.white),
                   padding: const EdgeInsets.all(14),
                   onPressed: () {
                      userLocationKey.currentState?.updateAlteredMap(false);
                      userLocationKey.currentState?.recenterLocation();
                   },
                   tooltip: 'Center on my location',
                 ),
               ),
            ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            bottom: _showInfoPanel ? 0 : -400,
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
                bottom: false,
                child: TopBar(
                  fromRoomName: _fromRoomName,
                  toRoomName: _toRoomName,
                  onClose: _closeTopBar,
                  onFromPressed: _handleFromPressed,
                  onToPressed: _handleToPressed,
                  onGetDirections: _fetchRoute,
                ),
              ),
            ),

          if (isSelectingOnMap)
            Positioned.fill(
              child: Stack(
                 children: [
                   IgnorePointer(
                     ignoring: true,
                     child: Container(
                       color: Colors.black.withOpacity(0.35),
                     ),
                   ),

                   Positioned(
                     top: MediaQuery.of(context).padding.top + 140,
                     left: 16,
                     right: 16,
                     child: IgnorePointer(
                       child: Center(
                         child: Material(
                           elevation: 6,
                           borderRadius: BorderRadius.circular(12),
                           color: Colors.white,
                           child: Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                             child: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Icon(
                                   _selectingFromRoom ? Icons.my_location : Icons.location_on,
                                   color: Colors.orange.shade700,
                                   size: 22,
                                 ),
                                 const SizedBox(width: 12),
                                 Flexible(
                                   child: Text(
                                     _selectingFromRoom
                                         ? "Tap your starting room on the map"
                                         : "Tap your destination room on the map",
                                     style: const TextStyle(
                                       fontSize: 15,
                                       fontWeight: FontWeight.w600,
                                       color: Colors.black87,
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

                   Positioned(
                     bottom: 40,
                     right: 16,
                     child: Material(
                       elevation: 6,
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
                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Icon(Icons.cancel_outlined, color: Colors.red.shade700, size: 20),
                               const SizedBox(width: 8),
                               Text(
                                 "Cancel Selection",
                                 style: TextStyle(
                                   color: Colors.red.shade800,
                                   fontWeight: FontWeight.bold,
                                   fontSize: 14,
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
            ),
        ],
      ),
    );
  }
}
