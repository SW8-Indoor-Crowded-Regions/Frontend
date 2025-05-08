import 'package:flutter/material.dart';
import 'package:indoor_crowded_regions_frontend/services/api_service.dart';
import 'package:indoor_crowded_regions_frontend/ui/components/error_toast.dart';
import '../../models/polygon_area.dart';
import '../components/exhibit_card.dart';
import '../components/exhibit_detail_dialog.dart';

class PolygonInfoPanel extends StatefulWidget {
  final PolygonArea polygon;
  final VoidCallback onClose;
  final void Function(String roomId)? onShowRoute;

  const PolygonInfoPanel({
    super.key,
    required this.polygon,
    required this.onClose,
    required this.onShowRoute,
  });

  @override
  PolygonInfoPanelState createState() => PolygonInfoPanelState();
}

class PolygonInfoPanelState extends State<PolygonInfoPanel> {
  late Future<List<dynamic>> _exhibitFuture;
  late String _lastPolygonId;

  @override
  void initState() {
    super.initState();
    _lastPolygonId = widget.polygon.id;
    _exhibitFuture = _fetchExhibits(_lastPolygonId);
  }

  @override
  void didUpdateWidget(covariant PolygonInfoPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.polygon.id != _lastPolygonId) {
      _lastPolygonId = widget.polygon.id;
      _exhibitFuture = _fetchExhibits(_lastPolygonId);
    }
  }

  final APIService apiService = APIService();

  Future<List<dynamic>> _fetchExhibits(String roomId) async {
    try {
      final response = await apiService.getArtwork(roomId, roomIdQuery: true);
      return response.data['items'] as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load exhibits: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Use 50% of screen height for the panel
    final panelHeight = screenSize.height * 0.5;
    return Container(
      width: double.infinity,
      height: panelHeight.toDouble(),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E), // Dark background for panel
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border(
            top: BorderSide(
                color: Color(0xFFFF7D00), width: 3)), // Brighter orange
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Room details directly at the top with no padding
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
            height: 40, // Fixed height to ensure consistent positioning
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Room information on a single row
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        widget.polygon.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF7D00), // Brighter orange
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.polygon.type} • Floor ${widget.polygon.additionalData?['floor']?.toString() ?? 'N/A'}',
                        style: TextStyle(
                          color: Colors
                              .grey.shade400, // Lighter gray for visibility
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: Color(0xFFFF7D00)), // Brighter orange
                  onPressed: widget.onClose,
                  tooltip: 'Close Panel',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Show Route button
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 0.0),
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onShowRoute!(widget.polygon.id);
              },
              icon: const Icon(Icons.alt_route),
              label: const Text("Show Route"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFFF7D00), // Brighter orange
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const Divider(height: 4, color: Color(0xFF3D3D3D)), // Dark divider

          // Exhibits section
          Flexible(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exhibits',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF7D00), // Brighter orange
                        ),
                  ),
                  // Use SizedBox with zero height to eliminate any default spacing
                  const SizedBox(height: 0),
                  FutureBuilder<List<dynamic>>(
                    future: _fetchExhibits(widget.polygon.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Fetching exhibits...',
                          style: TextStyle(
                              fontSize: 16,
                              color:
                                  Colors.white70), // Light text for dark mode
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(
                              color: Colors.red.shade300), // Error text color
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text(
                          'No exhibits on display.',
                          style: TextStyle(
                              color:
                                  Colors.white70), // Light text for dark mode
                        );
                      } else {
                        final exhibits = snapshot.data!;
                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 8.0,
                            // Slightly adjust the aspect ratio to fix the small overflow
                            childAspectRatio:
                                MediaQuery.of(context).size.width > 600
                                    ? 1.2
                                    : 0.85, // Changed from 0.9 to 0.85

                          ),
                          itemCount: exhibits.length,
                          itemBuilder: (context, index) {
                            final exhibit = exhibits[index];
                            final String? frontendUrl = exhibit['frontend_url'];
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: ExhibitCard(
                                exhibit: exhibit,
                                hasLink: frontendUrl != null &&
                                    frontendUrl.isNotEmpty,
                                onTap: () =>
                                    _showExhibitDetails(context, exhibit),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show the exhibit details dialog
  void _showExhibitDetails(BuildContext context, dynamic exhibit) {
    try {
      // Show the dialog with the exhibit data
      showDialog(
        context: context,
        builder: (context) => ExhibitDetailDialog(exhibit: exhibit),
      );
    } catch (e) {
      // Handle any errors that might occur during dialog creation
      ErrorToast.show("Could not create dialog screen.");
    }
  }
}
