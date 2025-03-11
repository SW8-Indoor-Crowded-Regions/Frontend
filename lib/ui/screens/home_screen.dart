import '../widgets/path/edge_segment.dart';
import '../widgets/room.dart';
import '../widgets/burger_menu.dart';
import '../../data/models/graph_models.dart';
import '../widgets/path/line_path.dart';
import '../../utils/path/load_graph_data.dart';

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  @visibleForTesting
  final Future<Map<String, dynamic>> Function()? loadGraphDataFn;
  @visibleForTesting
  final bool skipUserLocation;
  
  const HomeScreen({
    super.key,
    this.loadGraphDataFn,
    this.skipUserLocation = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  MapController mapController = MapController();
  Location location = Location();
  late bool _serviceEnabled = false;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  double _currentZoom = 18.0;
  List<EdgeModel> _edges = [];
  Map<int, NodeModel> _nodeMap = {};

  @override
  void initState() {
    super.initState();
    if (!widget.skipUserLocation) {
      initLocation();
    }
    final fn = widget.loadGraphDataFn ?? loadGraphData;
    fn().then((graphData) {
      setState(() {
        _edges = graphData['edges'];
        _nodeMap = graphData['nodeMap'];
      });
    });
  }

  Future<void> initLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      log(_locationData.toString());
    });
  }

  @visibleForTesting
  void setZoom(double zoom) {
    setState(() {
      _currentZoom = zoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<EdgeSegment> segments = createEdgeSegments(_edges, _nodeMap);

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
                markers: rooms
                    .where((room) => _currentZoom >= room.minZoomThreshold)
                    .map((room) {
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
                        color: room.color,
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (segments.isNotEmpty) LinePath(segments: segments),
            ],
          ),
        ],
      ),
    );
  }
}
