import 'package:flutter/material.dart';

class SearchInputBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSubmit;
  final void Function(String) onChanged;
  final VoidCallback onTap;

  const SearchInputBar({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
      builder: (context, _) {
        return SearchBar(
          controller: controller,
          onSubmitted: onSubmit,
          onChanged: onChanged,
          onTap: onTap,
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          leading: const Icon(Icons.search),
          hintText: "Search for artworks",
        );
      },
      suggestionsBuilder: (context, controller) => [],
    );
  }
}
