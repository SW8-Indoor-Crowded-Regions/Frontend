import 'package:flutter/material.dart';
import 'package:indoor_crowded_regions_frontend/ui/components/error_toast.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/utils/filter_item.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/utils/types.dart';
import '../../services/filter_service.dart';
import '../../services/gateway_service.dart';

class FilterPage extends StatefulWidget {
  final Function(Future<List<DoorObject>> path) setPath;
  const FilterPage({super.key, required this.setPath});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final FilterService _filterService = FilterService();
  final GatewayService _gatewayService = GatewayService();
  Map<String, List<String>> selectedFilters = {};
  Map<String, bool> showAll = {};

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
          for (var filter in filters)
            filter['key']
                .toString()
                .split(' ')
                .map((word) => word[0].toUpperCase() + word.substring(1))
                .join(' '): false
        };

        // Initialize the showAll map for this type
        showAll[type] = false;
      }

      setState(() {
        _filtersByType = parsedFilters;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleType(String type) {
    setState(() {
      // Toggle all filters of this type
      final current = _filtersByType[type]!;
      final allSelected = current.values.every((value) => value);
      final newValue = !allSelected;
      _filtersByType[type] =
          current.map((key, value) => MapEntry(key, newValue));
      if (newValue) {
        // If all are selected, add to selectedFilters
        selectedFilters[type] = current.keys.toList();
      } else {
        // If none are selected, remove from selectedFilters
        selectedFilters.remove(type);
      }
    });
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
          .where((entry) => entry.value.isNotEmpty)
          .map((entry) => {
                "type": entry.key,
                "keys": List<String>.from(entry.value),
              })
          .toList();

      final payload = {
        "filters": filtersPayload,
      };

      final response = await _filterService.getRoomsFromFilters(payload);

      final List<String> rooms = response.cast<String>();

      final path = _gatewayService.getFastestMultiRoomPath(
          "67efbb1f0b23f5290bff6fe5", rooms);
      widget.setPath(path);
      Navigator.pop(context, path);
      Navigator.pop(context, rooms);
    } catch (e) {
      ErrorToast.show("Failed to fetch rooms from filters");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
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
                          // Text(
                          //   type[0].toUpperCase() + type.substring(1),
                          //   style: const TextStyle(
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          SwitchListTile(
                            title: Text(
                              type[0].toUpperCase() + type.substring(1),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            contentPadding:
                                const EdgeInsets.only(left: 0, right: 20),
                            subtitle: const Text("Select all",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.orange,
                                )),
                            value: filterMap.values.every((value) => value),
                            onChanged: (_) => _toggleType(type),
                            activeTrackColor: Colors.orange,
                            inactiveTrackColor: Colors.white,
                            thumbColor:
                                const WidgetStatePropertyAll(Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          // Only show the first 10 filters of each type and add a "Show more" button
                          if (!showAll[type]! && filterMap.length > 10) ...[
                            Column(
                              children: [
                                ...List.generate(
                                  filterMap.entries.take(10).length * 2 - 1,
                                  (index) {
                                    if (index.isOdd) {
                                      return const Divider(
                                          color: Colors.grey, height: 1);
                                    }
                                    final entryIndex = index ~/ 2;
                                    final filterEntry =
                                        filterMap.entries.elementAt(entryIndex);
                                    return FilterToggleRow(
                                        label: filterEntry.key,
                                        value: filterEntry.value,
                                        onChanged: (filter) {
                                          _toggleFilter(type, filterEntry.key);
                                        });
                                  },
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Show all filters when "Show more" is pressed
                                    setState(() {
                                      _filtersByType[type] = filterMap;
                                      showAll[type] = true;
                                    });
                                  },
                                  child: const Text("Show more",
                                      style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ] else ...[
                            Column(
                              children: [
                                ...List.generate(
                                  filterMap.entries.length * 2 - 1,
                                  (index) {
                                    if (index.isOdd) {
                                      return const Divider(
                                          color: Colors.grey, height: 1);
                                    }
                                    final entryIndex = index ~/ 2;
                                    final filterEntry =
                                        filterMap.entries.elementAt(entryIndex);
                                    return FilterToggleRow(
                                        label: filterEntry.key,
                                        value: filterEntry.value,
                                        onChanged: (filter) {
                                          _toggleFilter(type, filterEntry.key);
                                        });
                                  },
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _filtersByType[type] = filterMap;
                                      showAll[type] = false;
                                    });
                                  },
                                  child: const Text("Show less",
                                      style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
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
                      backgroundColor: const Color(0xFFFF7D00),
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 255, 111, 1),
                          width: 2,
                          style: BorderStyle.solid
                        ),
                      ),
                    ),
                    child: const Text("Confirm",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
    );
  }
}
