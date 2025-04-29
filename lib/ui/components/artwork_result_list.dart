import 'package:flutter/material.dart';

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
/// Each artwork is displayed in a [Card] widget with a [ListTile] that shows the title and location of the artwork.
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
            final titleString = titles[0]["title"].toString();
            final location = item["current_location_name"] ?? "Not on display";

            return Card(
              child: ListTile(
                title: Text(titleString),
                subtitle: Text("Room: $location"),
              ),
            );
          },
        ));
  }
}
