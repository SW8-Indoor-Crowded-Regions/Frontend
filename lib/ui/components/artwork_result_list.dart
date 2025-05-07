import 'package:flutter/material.dart';
import 'package:indoor_crowded_regions_frontend/ui/components/error_toast.dart';
import 'exhibit_card.dart';
import 'exhibit_detail_dialog.dart';

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
  /// The list of artworks to display
  final List<dynamic> artworks;

  /// Whether more artworks are being loaded
  final bool isLoadingMore;

  /// Whether there are more artworks to load
  final bool hasMore;

  /// Callback function to load more artworks
  final Function() loadMore;

  /// Constructor for the artwork results list
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
      return const Center(
        child: Text(
          "No results found",
          style: TextStyle(color: Colors.white70), // Light text for dark mode
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
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
          final String? frontendUrl = item["frontend_url"];
          final bool hasLink = frontendUrl != null && frontendUrl.isNotEmpty;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            child: ExhibitCard(
              exhibit: item,
              hasLink: hasLink,
              onTap: () => _showExhibitDetails(context, index),
            ),
          );
        },
      ),
    );
  }

  /// Show the exhibit details dialog
  void _showExhibitDetails(BuildContext context, int index) {
    // Find the full item data to show all available information
    try {
      final selectedItem = artworks[index];
      // Show the dialog with the full item data
      showDialog(
        context: context,
        builder: (context) => ExhibitDetailDialog(exhibit: selectedItem),
      );
    } catch (e) {
      ErrorToast.show("Could not create dialog screen.");
    }
  }
}
