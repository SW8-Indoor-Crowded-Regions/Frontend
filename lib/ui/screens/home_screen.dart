import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Contains MapController, MapPosition, MapEvent classes
import 'package:latlong2/latlong.dart';

import '../widgets/burger_menu.dart';
import '../widgets/user_location_widget.dart';
import '../widgets/burger_drawer.dart';
import '../widgets/polygon_info_panel.dart';
import '../widgets/top_bar.dart';
import '../widgets/map/map_widget.dart';
import '../widgets/floor_selector_widget.dart';
import '../widgets/location_button_widget.dart';
import '../widgets/route_selection_overlay_widget.dart';
import '../../services/api_service.dart';
import '../../services/gateway_service.dart';
import '../../services/polygon_service.dart';
import '../../models/polygon_area.dart';

class Room {
  final String? id;
  final String? name;

  Room({
    required this.id,
    required this.name,
  });
}

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

  late Future<List<PolygonArea>> _polygonsFuture = Future.value([]);
  late List<PolygonArea> _polygons = [];
  PolygonArea? _selectedPolygon;
  bool _showInfoPanel = false;

  Room? _fromRoom;
  Room? _toRoom;
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

    // If no polygon was tapped, reset the selected polygon and hide the info panel
    if (tappedPolygon == null) {
      setState(() {
        _selectedPolygon = null;
        _showInfoPanel = false;
      });
      return;
    }


    if (_selectingFromRoom) {
      setState(() {
        _fromRoom = Room(
          id: tappedPolygon?.id,
          name: tappedPolygon?.name ?? "Unknown Room",
        );
        _selectingFromRoom = false;
        _showInfoPanel = false;
        _selectedPolygon = null;
      });
      return;
    }

    if (_selectingToRoom) {
      setState(() {
        _toRoom = Room(
          id: tappedPolygon?.id,
          name: tappedPolygon?.name ?? "Unknown Room",
        );
        _selectingToRoom = false;
        _showInfoPanel = false;
        _selectedPolygon = null;
      });
      return;
    }

    if (_selectedPolygon?.id == tappedPolygon.id) {
      setState(() {
        _selectedPolygon = null;
        _showInfoPanel = false;
      });
    } else {
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
    final confirmedRoomId = _selectedPolygon?.id;

    if (confirmedRoomId == null) {
      return;
    }

    setState(() {
      _toRoom = Room(
        id: confirmedRoomId,
        name: _selectedPolygon?.name ?? "Unknown Room",
      );
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
      _fromRoom = null;
      _toRoom = null;
      _selectedPolygon = null;
      _edgesFuture = Future.value([]);
    });
  }

  void _handleMapEvent(MapEvent event) {
    if (event is MapEventMoveStart) {
      userLocationKey.currentState?.updateAlteredMap(true);
    }
  }

  void _handlePositionChanged(MapCamera position, bool hasGesture) {
    if (hasGesture && position.zoom != _currentZoom) {
      setState(() {
        _currentZoom = position.zoom;
      });
    }
  }

  void _handleLocationButtonPressed() {
    userLocationKey.currentState?.updateAlteredMap(false);
    userLocationKey.currentState?.recenterLocation();
  }

  void _handleFloorChanged(int floor) {
    setState(() {
      _currentFloor = floor;
    });
    _loadPolygons(floor);
  }

  void _cancelSelection() {
    setState(() {
      _selectingFromRoom = false;
      _selectingToRoom = false;
    });
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
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _edgesFuture,
            builder: (context, snapshot) {
              return MapWidget(
                mapController: mapController,
                currentFloor: _currentFloor,
                polygons: _polygons,
                selectedPolygon: _selectedPolygon,
                pulseAnimation: _pulseAnimation,
                isSelectingOnMap: isSelectingOnMap,
                onTap: _handleMapTap,
                pathData: snapshot.hasData && snapshot.data!.isNotEmpty
                    ? snapshot.data
                    : null,
                userLocationWidget: userLocationWidget,
                onMapEvent: _handleMapEvent,
                onPositionChanged: _handlePositionChanged,
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: BurgerMenu(scaffoldKey: scaffoldKey),
          ),
          Positioned(
            bottom: 40,
            left: 16,
            child: FloorSelector(
              currentFloor: _currentFloor,
              onFloorChanged: _handleFloorChanged,
            ),
          ),
          if (!widget.skipUserLocation)
            Positioned(
              bottom: 40,
              right: 16,
              child: LocationButton(
                onPressed: _handleLocationButtonPressed,
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
                  toRoom: _toRoom,
                  fromRoom: _fromRoom,
                  gatewayService: widget.gatewayService,
                  onClose: _closeTopBar,
                  onFromPressed: _handleFromPressed,
                  onToPressed: _handleToPressed,
                  setEdgesFuture: (future) {
                    setState(() {
                      _edgesFuture = future;
                      _selectingFromRoom = false;
                      _selectingToRoom = false;
                    });
                  },
                ),
              ),
            ),
          if (isSelectingOnMap)
            RouteSelectionOverlay(
              selectingFromRoom: _selectingFromRoom,
              onCancel: _cancelSelection,
            ),
        ],
      ),
    );
  }
}
