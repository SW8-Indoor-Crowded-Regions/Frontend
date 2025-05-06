import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget that displays a list of artworks with infinite scrolling.
/// __[artworks]__ is the list of artworks to display.
///
/// __[isLoadingMore]__ indicates whether more artworks are being loaded.
///
/// __[hasMore]__ indicates whether there are more artworks to load.
///
/// __[loadMore]__ is a callback function to load more artworks when the user scrolls to the bottom of the list.
///
/// The widget uses a [NotificationListener] to detect when the user has scrolled to the bottom of the list.
/// When the user scrolls to the bottom, it calls the [loadMore] function to load more artworks.
///
/// If there are no artworks to display, it shows a message indicating that no results were found.
///
/// Each artwork is displayed in a styled card similar to the PolygonInfoPanel exhibit cards.
class ArtworkResultsList extends StatelessWidget {
  final List<dynamic> artworks;
  final bool isLoadingMore;
  final bool hasMore;
  final Function() loadMore;

  const ArtworkResultsList({
    super.key,
    required this.artworks,
    required this.isLoadingMore,
    required this.hasMore,
    required this.loadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (artworks.isEmpty) {
      return const Center(child: Text("No results found"));
    }

    return NotificationListener(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoadingMore &&
              hasMore &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
            loadMore();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: artworks.length,
          itemBuilder: (context, index) {
            final item = artworks[index];
            final titles = item["titles"] as List<dynamic>;
            final titleString = titles.isNotEmpty
                ? titles[0]["title"]?.toString() ?? "Untitled"
                : "Untitled";
            final artist = (item["artist"] as List?)?.isNotEmpty == true
                ? item["artist"][0] ?? "Unknown"
                : "Unknown";
            final String? thumbnail = item["image_thumbnail"];
            final String? frontendUrl = item["frontend_url"];
            final location = item["current_location_name"] ?? "Not on display";

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
              child: _buildExhibitCard(
                context,
                artist,
                titleString,
                thumbnail,
                frontendUrl,
                location,
              ),
            );
          },
        ));
  }

  Widget _buildExhibitCard(BuildContext context, String artist, String title,
      [String? thumbnail, String? frontendUrl, String? location]) {
    final bool hasLink = frontendUrl != null && frontendUrl.isNotEmpty;
    final double cardHeight = 180.0; // height

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
          // Image section - always include a container for consistent sizing
          SizedBox(
            height: cardHeight * 0.6, // 60% of card height for image
            width: double.infinity,
            child: thumbnail != null && thumbnail.isNotEmpty
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(Icons.broken_image,
                              size: 40, color: Colors.grey.shade400),
                        ),
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
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
          ),

          // Text section
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist == 'Ubekendt' ? 'Unknown' : artist,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (location != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Room: $location",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    // Make all cards tappable to show details
    return GestureDetector(
      onTap: () {
        // Find the full item data to show all available information
        final index = artworks.indexWhere((item) {
          try {
            final itemTitle = ((item["titles"] as List?)?.isNotEmpty == true)
                ? item["titles"][0]["title"]?.toString() ?? "Untitled"
                : "Untitled";
            final itemArtist = (item["artist"] as List?)?.isNotEmpty == true
                ? item["artist"][0] ?? "Unknown"
                : "Unknown";
            return itemTitle == title && itemArtist == artist;
          } catch (e) {
            return false;
          }
        });

        if (index >= 0) {
          // Use the full item data from the artworks list
          _showExhibitDetails(context, artworks[index]);
        } else {
          // Fallback to basic data if we can't find the full item
          _showExhibitDetails(context, {
            "titles": [
              {"title": title}
            ],
            "artist": [artist],
            "image_thumbnail": thumbnail,
            "frontend_url": frontendUrl,
            "current_location_name": location,
          });
        }
      },
      child: Stack(
        children: [
          card,
          if (hasLink)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.orange.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to build a detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a colors section with color circles
  Widget _buildColorsSection(String label, List<String> colorStrings) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colorStrings.map((colorString) {
              // Convert the color string to a Color object
              Color displayColor = _parseColorString(colorString);

              // Create a row with color circle and text
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color circle
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: displayColor,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.grey.shade300, width: 0.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Color name
                  Text(
                    colorString,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Helper method to parse color strings
  Color _parseColorString(String colorString) {
    try {
      // Handle hex colors with # prefix
      if (colorString.startsWith('#')) {
        String hex = colorString.substring(1);
        if (hex.length == 6) {
          return Color(int.parse(hex, radix: 16) | 0xFF000000);
        }
      }

      // Use a hash-based color for other strings
      return Color((colorString.hashCode & 0xFFFFFF) | 0xFF000000);
    } catch (e) {
      // Default fallback color
      return Colors.grey;
    }
  }

  // Helper method to extract values from the JSON response with error handling
  String _extractValue(dynamic item, String key) {
    try {
      if (item == null || item[key] == null) return "Unknown";

      if (item[key] is List) {
        final list = item[key] as List;
        if (list.isEmpty) return "Unknown";
        return list[0].toString();
      }

      return item[key].toString();
    } catch (e) {
      // Return a default value if there's an error
      return "Unknown";
    }
  }

  // Helper method to extract a list of values with error handling
  List<String> _extractListValues(dynamic item, String key) {
    try {
      if (item == null || item[key] == null) return [];

      if (item[key] is List) {
        final list = item[key] as List;
        return list.map((value) => value.toString()).toList();
      }

      return [];
    } catch (e) {
      // Return an empty list if there's an error
      return [];
    }
  }

  void _showExhibitDetails(BuildContext context, dynamic exhibit) {
    try {
      // Extract all the relevant information with null safety
      String title = "Untitled";
      try {
        final titles = exhibit["titles"] as List?;
        title = titles?.isNotEmpty == true
            ? titles![0]["title"]?.toString() ?? "Untitled"
            : "Untitled";
      } catch (e) {
        // Use default title if there's an error
      }

      String artist = "Unknown";
      try {
        artist = (exhibit["artist"] as List?)?.isNotEmpty == true
            ? exhibit["artist"][0] ?? "Unknown"
            : "Unknown";
      } catch (e) {
        // Use default artist if there's an error
      }

      final String? thumbnail = exhibit["image_thumbnail"];
      final location = exhibit["current_location_name"] ?? "Not on display";

      // Extract additional information - these will return defaults if fields don't exist
      final dating = _extractValue(exhibit, "production_date");
      final materials = _extractListValues(exhibit, "materials");
      final techniques = _extractListValues(exhibit, "techniques");
      final colors = _extractListValues(exhibit, "colors");
      final dimensions = _extractListValues(exhibit, "dimensions");
      final description = _extractValue(exhibit, "content_description");

      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with image
                if (thumbnail != null && thumbnail.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: SizedBox(
                      height: 200,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Icon(Icons.broken_image,
                                  size: 40, color: Colors.grey.shade400),
                            ),
                          ),
                          // Gradient overlay for better text readability
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Title and artist on the image
                          Positioned(
                            bottom: 8,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  artist == 'Ubekendt' ? 'Unknown' : artist,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Close button
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Details section
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (thumbnail == null || thumbnail.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  artist == 'Ubekendt' ? 'Unknown' : artist,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Location
                        _buildDetailRow("Location", location),

                        // Dating
                        if (dating != "Unknown")
                          _buildDetailRow("Dating", dating),

                        // Materials
                        if (materials.isNotEmpty)
                          _buildDetailRow("Materials", materials.join(", ")),

                        // Techniques
                        if (techniques.isNotEmpty)
                          _buildDetailRow("Techniques", techniques.join(", ")),

                        // Dimensions
                        if (dimensions.isNotEmpty)
                          _buildDetailRow("Dimensions", dimensions.join(", ")),

                        // Colors
                        if (colors.isNotEmpty)
                          _buildColorsSection("Colors", colors),

                        // Description
                        if (description != "Unknown" && description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Description",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade800,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  description,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),

                        // Link to more info - with null safety
                        if (exhibit["frontend_url"] != null &&
                            exhibit["frontend_url"].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                try {
                                  launchUrl(Uri.parse(exhibit["frontend_url"]));
                                } catch (e) {
                                  // Handle URL launch error silently
                                }
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: const Text("View on Website"),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.orange.shade800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      // Handle any errors that might occur during dialog creation
      print("Error showing exhibit details: $e");
    }
  }
}
