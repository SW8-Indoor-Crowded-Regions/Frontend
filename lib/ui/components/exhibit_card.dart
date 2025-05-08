import 'package:flutter/material.dart';
import '../../utils/data_extractor.dart';

/// A card widget that displays an exhibit item
class ExhibitCard extends StatelessWidget {
  /// The exhibit data to display
  final dynamic exhibit;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  /// Whether the card has a link
  final bool hasLink;

  /// Constructor for the exhibit card
  const ExhibitCard({
    super.key,
    required this.exhibit,
    required this.onTap,
    this.hasLink = false,
  });

  @override
  Widget build(BuildContext context) {
    final String artist = DataExtractor.extractArtist(exhibit);
    final String title = DataExtractor.extractTitle(exhibit);
    final String? thumbnail = exhibit["image_thumbnail"];
    final String location = DataExtractor.extractLocation(exhibit);
    const double cardHeight = 180.0;

    final card = Card(
      elevation: hasLink ? 4.0 : 3.0,
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFF2D2D2D), // Dark background for card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: hasLink ? Colors.orange.shade400 : Colors.grey.shade600,
          width: hasLink ? 1.0 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
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
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      // Gradient overlay for better text readability
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
                    color: const Color(
                        0xFF1E1E1E), // Darker background for placeholder
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color:
                            Colors.grey.shade600, // Lighter gray for visibility
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
                    color:
                        Colors.orange.shade500, // Brighter orange for dark mode
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70, // Light text for dark mode
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (location.isNotEmpty && location != "Not on display")
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Room: $location",
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Colors.grey.shade400, // Lighter gray for visibility
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

    return GestureDetector(
      onTap: onTap,
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
                  color: const Color(0xFF2D2D2D)
                      .withValues(alpha: 0.8), // Dark background for icon
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color:
                      Colors.orange.shade500, // Brighter orange for dark mode
                ),
              ),
            ),
        ],
      ),
    );
  }
}
