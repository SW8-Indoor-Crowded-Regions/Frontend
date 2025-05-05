import 'package:flutter/material.dart';
import 'package:indoor_crowded_regions_frontend/services/api_service.dart';
import '../../models/polygon_area.dart';
import 'package:url_launcher/url_launcher.dart';

class PolygonInfoPanel extends StatelessWidget {
  final PolygonArea polygon;
  final VoidCallback onClose;
  final void Function(String roomId)? onShowRoute;

  PolygonInfoPanel({
    super.key,
    required this.polygon,
    required this.onClose,
    required this.onShowRoute,
  });

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
                        polygon.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${polygon.type} • Floor ${polygon.additionalData?['floor']?.toString() ?? 'N/A'}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.orange),
                  onPressed: onClose,
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
                onShowRoute!(polygon.id);
              },
              icon: const Icon(Icons.alt_route),
              label: const Text("Show Route"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange.shade800,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const Divider(height: 4),

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
                          color: Colors.orange.shade800,
                        ),
                  ),
                  // Use SizedBox with zero height to eliminate any default spacing
                  const SizedBox(height: 0),
                  FutureBuilder<List<dynamic>>(
                    future: _fetchExhibits(polygon.id),
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
                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio:
                                MediaQuery.of(context).size.width > 600
                                    ? 1.2
                                    : 0.9,
                          ),
                          itemCount: exhibits.length,
                          itemBuilder: (context, index) {
                            final exhibit = exhibits[index];
                            final title =
                                (exhibit['titles'] as List?)?.isNotEmpty == true
                                    ? exhibit['titles'][0]['title'] ??
                                        'Untitled'
                                    : 'Untitled';
                            final artist =
                                (exhibit['artist'] as List?)?.isNotEmpty == true
                                    ? exhibit['artist'][0] ?? 'Unknown'
                                    : 'Unknown';
                            final String? thumbnail =
                                exhibit['image_thumbnail'];
                            final String? frontendUrl = exhibit['frontend_url'];
                            return _buildExhibitCard(
                              context,
                              artist,
                              title,
                              thumbnail,
                              frontendUrl,
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

  // Keep the original _buildInfoRow method for compatibility
  Widget _buildInfoRow(BuildContext context, String label, String value,
      [String? thumbnail, String? frontendUrl]) {
    final content = Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
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

  Widget _buildExhibitCard(BuildContext context, String artist, String title,
      [String? thumbnail, String? frontendUrl]) {
    final bool hasLink = frontendUrl != null && frontendUrl.isNotEmpty;

    final card = Card(
      elevation: hasLink ? 4.0 : 3.0,
      clipBehavior:
          Clip.antiAlias, // Ensures image doesn't overflow rounded corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: hasLink ? Colors.orange.shade300 : Colors.grey.shade300,
          width: hasLink ? 1.0 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          if (thumbnail != null && thumbnail.isNotEmpty)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.broken_image,
                              size: 40, color: Colors.grey.shade400)),
                    ),
                    // Gradient overlay for better text readability if needed
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Text section
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    artist == 'Ubekendt' ? 'Unknown' : artist,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
            child: Stack(
              children: [
                card,
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255)
                          .withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          )
        : card;
  }
}
