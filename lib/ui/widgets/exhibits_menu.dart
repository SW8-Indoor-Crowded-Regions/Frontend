import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../components/search_suggestion_list.dart';
import '../components/artwork_result_list.dart';
import '../components/search_input_bar.dart';

class ExhibitsMenu extends StatefulWidget {
  final void Function(bool show) showExhibitsMenu;
  const ExhibitsMenu(
      {super.key, this.showExhibitsMenu = _defaultShowExhibitsMenu});
  static void _defaultShowExhibitsMenu(bool show) {}
  @override
  State<ExhibitsMenu> createState() => _ExhibitsMenuState();
}

class _ExhibitsMenuState extends State<ExhibitsMenu> {
  APIService apiService = APIService();
  bool fetchingArtworks = false;
  List<String> previousSearch = [];
  List<dynamic> artworks = [];
  List<String> suggestions = [];
  int offset = 0;
  int rowsPerPage = 10;
  int totalResults = 0;
  bool isLoadingMore = false;
  bool hasMore = true;

  void showExhibits(bool show) {
    widget.showExhibitsMenu(show);
  }

  /// Performs a search for artworks based on the given query.
  /// ---
  /// If __[isNewSearch]__ is true, it resets the current search state.
  ///
  /// If __[isNewSearch]__ is false, it appends the new results to the existing list.
  ///
  /// __[query]__ is the search term entered by the user.
  ///
  /// It also updates the state of the widget to reflect the loading status and
  /// the results.
  /// If the search is successful, it updates the list of artworks and the
  /// total number of results. If the search fails, it shows a snackbar with an
  /// error message.
  Future<void> _performSearch(String query, {bool isNewSearch = true}) async {
    if (isNewSearch) {
      offset = 0;
      totalResults = 0;
      artworks.clear();
      hasMore = true;
    }

    try {
      if (!hasMore || isLoadingMore) return;

      setState(() => isLoadingMore = true);

      final response = await apiService.getArtwork(
        query,
        rows: rowsPerPage,
        offset: offset,
      );

      final List<dynamic> data = response.data?["items"];
      final int found = response.data?["found"] ?? 0;

      setState(() {
        totalResults = found;
        artworks.addAll(data);
        offset += rowsPerPage;
        hasMore = artworks.length < totalResults;
        suggestions = [];
      });

      if (isNewSearch && !previousSearch.contains(query)) {
        previousSearch.insert(0, query);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to search for artworks")),
        );
      }
    } finally {
      setState(() => isLoadingMore = false);
    }
  }

  final TextEditingController searchTextController = TextEditingController();

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => showExhibits(false),
        ),
        title: const Text("Search Exhibits"),
        backgroundColor: const Color(0xFF1E1E1E), // Dark background for app bar
        foregroundColor:
            const Color(0xFFFF7D00), // Brighter orange for dark mode
        elevation: 2,
      ),
      body: Stack(
        children: <Widget>[
          // Content of the screen, including artworks list
          Container(
            color: const Color(0xFF121212), // Dark background for body
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  SearchInputBar(
                    controller: searchTextController,
                    onTap: () => setState(() {
                      suggestions = previousSearch;
                    }),
                    onSubmit: _performSearch,
                    onChanged: (value) => setState(() {
                      suggestions = previousSearch
                          .where((item) =>
                              item.toLowerCase().contains(value.toLowerCase()))
                          .toList();
                    }),
                  ),
                  const SizedBox(height: 8),
                  // Title for the results section
                  if (artworks.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Exhibits',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(
                                0xFFFF7D00), // Brighter orange for dark mode
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    // List of artworks from the API search
                    child: ArtworkResultsList(
                      artworks: artworks,
                      isLoadingMore: isLoadingMore,
                      hasMore: hasMore,
                      loadMore: () => _performSearch(searchTextController.text,
                          isNewSearch: false),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Search suggestions
          if (suggestions.isNotEmpty)
            SearchSuggestionList(
                suggestions: suggestions, onSelect: _performSearch),
        ],
      ),
    );
  }
}
