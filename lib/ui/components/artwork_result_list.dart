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
              if (open == true) launchUrl(Uri.parse(frontendUrl));
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
                      color: Colors.white.withValues(alpha: 0.8),
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
