import 'package:flutter/material.dart';
import 'package:indoor_crowded_regions_frontend/services/api_service.dart';
import '../../models/polygon_area.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final panelHeight =
        screenSize.height * 0.4 > 300 ? 300 : screenSize.height * 0.4;
    return Container(
      width: double.infinity,
      height: panelHeight.toDouble(),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border(top: BorderSide(color: Colors.orange, width: 3)),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      widget.onShowRoute!(widget.polygon.id);
                    },
                    icon: const Icon(Icons.alt_route),
                    label: const Text("Show Route"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.orange.shade800,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.orange),
                    onPressed: widget.onClose,
                    tooltip: 'Close Panel',
                  ),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Room Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                          ),
                          _buildInfoRow(context, 'Name', widget.polygon.name),
                          _buildInfoRow(context, 'Type', widget.polygon.type),
                          if (widget.polygon.additionalData != null) ...[
                            _buildInfoRow(
                              context,
                              'Floor',
                              widget.polygon.additionalData!['floor']?.toString() ?? 'N/A',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exhibits',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                          ),
                          FutureBuilder<List<dynamic>>(
                            future: _exhibitFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text(
                                  'Fetching exhibits...',
                                  style: TextStyle(fontSize: 16),
                                );
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Text('No exhibits on display.');
                              } else {
                                final exhibits = snapshot.data!;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: exhibits.length,
                                  itemBuilder: (context, index) {
                                    final exhibit = exhibits[index];
                                    final title = (exhibit['titles'] as List?)?.isNotEmpty == true
                                        ? exhibit['titles'][0]['title'] ?? 'Untitled'
                                        : 'Untitled';
                                    final artist = (exhibit['artist'] as List?)?.isNotEmpty == true
                                        ? exhibit['artist'][0] ?? 'Unknown'
                                        : 'Unknown';
                                    final String? thumbnail = exhibit['image_thumbnail'];
                                    final String? frontendUrl = exhibit['frontend_url'];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: _buildInfoRow(
                                              context,
                                              artist,
                                              title,
                                              thumbnail,
                                              frontendUrl,
                                            ),
                                          ),
                                        ],
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, [String? thumbnail, String? frontendUrl]) {
    final content = Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            label == 'Ubekendt' ? 'Unknown' : label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (thumbnail != null && thumbnail.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Image.network(
                thumbnail,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
              ),
            ),
        ],
      ),
    );

    return frontendUrl != null && frontendUrl.isNotEmpty
      ? GestureDetector(
        onTap: () async {
          final open = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Do you want to open this link?'),
              content: Text(frontendUrl),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Open'),
                ),
              ],
            ),
          );
          if (open!) launchUrl(Uri.parse(frontendUrl));
        },
        child: content,
      )
      : content;
  }
}