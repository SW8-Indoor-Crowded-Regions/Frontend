import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ExhibitsMenu extends StatefulWidget {
  final void Function(bool show) showExhibitsMenu;
  const ExhibitsMenu({super.key, this.showExhibitsMenu = _defaultShowExhibitsMenu});
  static void _defaultShowExhibitsMenu(bool show) {}
  @override
  State<ExhibitsMenu> createState() => _ExhibitsMenuState();
}

class _ExhibitsMenuState extends State<ExhibitsMenu> {
  APIService apiService = APIService();
  bool fetchingArtworks = false;
  List<String> previousSearch = [];
  List<String> artworks = [];

  void showExhibits(bool show) {
    widget.showExhibitsMenu(show);
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
      ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onSubmitted: (query) async {
                      try {
                        final response = await apiService.searchArtwork(query);
                        final List<dynamic> data = response.data;
                        setState(() {
                          artworks = List<String>.from(data);
                        });
                      } catch (e) {
                        throw Exception("Failed to search for artworks");
                      }
                    },
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder: (BuildContext context, SearchController controller) {
                  return List<ListTile>.generate(previousSearch.length > 5 ? 5 : previousSearch.length, (int index) {
                    final String item = previousSearch[index];
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        setState(() {
                          controller.closeView(item);
                        });
                      },
                    );
                  });
                },
              ),
              Expanded(
                child: Stack(
                  children: [
                    artworks.isEmpty ? const Center(child: Text("No results found"))
                    : ListView.builder(
                      itemCount: artworks.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          future: apiService.getArtwork(artworks[index]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: Text(""));
                            }
                            else if (snapshot.hasError) {
                              return const Center(child: Text("Error loading artwork"));
                            } else {
                              final artwork = snapshot.data?.data[0];
                              return Card(
                                child: ListTile(
                                  title: Text("Room: ${artwork["room"] ?? "Not on display"}"),
                                  subtitle: Text("Artwork ID: ${artwork["id"]}"),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ])
              ),
            ],
          ),
        ),
    );
  }
}