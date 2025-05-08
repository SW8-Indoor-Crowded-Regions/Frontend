import 'package:flutter/material.dart';

/// A widget that displays a list of search suggestions.
///
/// __[suggestions]__ is the list of suggestions to display.
///
/// __[onSelect]__ is a callback function that is called when a suggestion is selected.
///
/// The widget uses a [ListView] to display the suggestions.Each suggestion
/// is displayed in a [ListTile] widget. When a suggestion is selected,
/// it calls the [onSelect] function with the selected suggestion.
class SearchSuggestionList extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String suggestion) onSelect;

  const SearchSuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 65.0,
      left: 8.0,
      right: 8.0,
      child: Material(
        color: Colors.transparent,
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2D), // Dark background for suggestions
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withAlpha(50), // Darker shadow for visibility
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: suggestions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = suggestions[index];
              final truncatedItem =
                  item.length > 50 ? "${item.substring(0, 47)}..." : item;
              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                title: Text(truncatedItem,
                    style: const TextStyle(
                        color: Colors.white70)), // Light text for dark mode
                onTap: () => onSelect(item),
              );
            },
          ),
        ),
      ),
    );
  }
}
