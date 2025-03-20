import '../widgets/path/edge_segment.dart';
import '../widgets/room.dart';
import '../widgets/burger_menu.dart';
import '../../data/models/graph_models.dart';
import '../widgets/path/line_path.dart';
import '../../utils/path/load_graph_data.dart';
import '../widgets/user_location_widget.dart';
import '../widgets/burger_drawer.dart';
import '../widgets/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
  final APIService apiService = APIService(); 
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<UserLocationWidgetState> userLocationKey = GlobalKey<UserLocationWidgetState>();
  MapController mapController = MapController();
  UserLocationWidget? userLocationWidget;
  double _currentZoom = 18.0;
  List<EdgeModel> _edges = [];
  Map<int, NodeModel> _nodeMap = {};

  String highlightedCategory = "";

  @override
  void initState() {
    super.initState();
    if (!widget.skipUserLocation) {
      userLocationWidget = UserLocationWidget(
        key: userLocationKey,
        mapController: mapController,
      );
    }
    final fn = widget.loadGraphDataFn ?? loadGraphData;
    fn().then((graphData) {
      setState(() {
        _edges = graphData['edges'];
        _nodeMap = graphData['nodeMap'];
      });
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
    });
    Navigator.pop(context);
  }

  Future<String> fetchArtwork(String query) async {
    try {
      final response = await apiService.searchArtwork(query);
      return response.data.toString();
    } catch (e) {
      throw Exception("Failed to fetch artwork");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<EdgeSegment> segments = createEdgeSegments(_edges, _nodeMap);

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
                urlTemplate: 'assets/tiles/{z}/{x}/{y}.png',
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
                            content: FutureBuilder<String>(
                              future: fetchArtwork("minimumsbetragtning"), 
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text("Error: ${snapshot.error}");
                                } else {
                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(snapshot.data ?? "No data available"),
                                    ),
                                  );
                                }
                              },
                            ),
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
                        color: highlighted ? Colors.blue : room.color
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (segments.isNotEmpty) LinePath(segments: segments),
              if (userLocationWidget != null) userLocationWidget!,
            ],
          ),
          Positioned(
            top: 40,
            left: 16,
            child: BurgerMenu(scaffoldKey: scaffoldKey),
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
