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
          leading: const Icon(Icons.search,
              color: Color(0xFFFF7D00)), // Brighter orange for dark mode
          hintText: "Search for artworks",
          backgroundColor: const WidgetStatePropertyAll<Color>(
              Color(0xFF2D2D2D)), // Dark background for search bar
          overlayColor: const WidgetStatePropertyAll<Color>(
              Color(0xFF1E1E1E)), // Dark background for overlay
          textStyle: const WidgetStatePropertyAll<TextStyle>(
              TextStyle(color: Colors.white70)), // Light text for dark mode
          hintStyle: const WidgetStatePropertyAll<TextStyle>(TextStyle(
              color: Color(
                  0xFFBDBDBD))), // Lighter gray for visibility (equivalent to Colors.grey.shade400)
        );
      },
      suggestionsBuilder: (context, controller) => [],
    );
  }
}
