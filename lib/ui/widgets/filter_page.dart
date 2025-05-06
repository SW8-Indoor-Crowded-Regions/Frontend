import 'package:flutter/material.dart';
import '../../services/filter_service.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final FilterService _filterService = FilterService();
  Map<String, List<String>> selectedFilters = {};


  Map<String, Map<String, bool>> _filtersByType = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    try {
      final response = await _filterService.getFilters();
      final List<dynamic> rawData = response.data;

      final Map<String, Map<String, bool>> parsedFilters = {};

      for (final item in rawData) {
        final String type = item['type'];
        final List<dynamic> filters = item['filters'];

        parsedFilters[type] = {
          for (var filter in filters) filter['key'].toString(): false
        };
      }

      setState(() {
        _filtersByType = parsedFilters;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleFilter(String type, String key) {
    setState(() {
      final current = _filtersByType[type]![key]!;
      _filtersByType[type]![key] = !current;

      if (!current) {
        // Toggle ON
        if (!selectedFilters.containsKey(type)) {
          selectedFilters[type] = [];
        }
        selectedFilters[type]!.add(key);
      } else {
        // Toggle OFF
        selectedFilters[type]?.remove(key);
        if (selectedFilters[type]?.isEmpty ?? true) {
          selectedFilters.remove(type);
        }
      }
    });
  }


  Future<void> _confirmFilters() async {
    try {
      final List<Map<String, dynamic>> filtersPayload = selectedFilters.entries
          .where((entry) =>
              (entry.key == "creator" || entry.key == "material") &&
              entry.value.isNotEmpty)
          .map((entry) => {
                "type": entry.key,
                "keys": List<String>.from(entry.value),
              })
          .toList();

      final payload = {
        "filters": filtersPayload,
      };

      print("Sending payload: ${payload}");

      final response = await _filterService.getRoomsFromFilters(payload);

      final List<dynamic> rooms = response.data;
      print("Fetched rooms: $rooms");
    } catch (e) {
      print("Error while fetching rooms: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: _filtersByType.entries.map((typeEntry) {
                      final type = typeEntry.key;
                      final filterMap = typeEntry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type[0].toUpperCase() + type.substring(1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...filterMap.entries.map((filterEntry) {
                            return SwitchListTile(
                              title: Text(filterEntry.key),
                              value: filterEntry.value,
                              onChanged: (_) =>
                                  _toggleFilter(type, filterEntry.key),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: ElevatedButton(
                    onPressed: _confirmFilters,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text("Confirm"),
                  ),
                ),
              ],
            ),
    );
  }
}