import '../../data/models/graph_models.dart';
import '../../ui/widgets/path/edge_segment.dart';

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

Future<Map<String, dynamic>> loadGraphData() async {
  try {
    final String jsonString = await rootBundle.loadString('mock_data/graph.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final List<dynamic> nodesJson = jsonData['nodes'] ?? [];
    final List<NodeModel> loadedNodes =
        nodesJson.map((n) => NodeModel.fromJson(n)).toList();

    final List<dynamic> edgesJson = jsonData['edges'] ?? [];
    final List<EdgeModel> loadedEdges =
        edgesJson.map((e) => EdgeModel.fromJson(e)).toList();

    final nodeMap = <int, NodeModel>{};
    for (var node in loadedNodes) {
      nodeMap[node.id] = node;
    }

    return {
      'edges': loadedEdges,
      'nodeMap': nodeMap,
    };
  } catch (e) {
    debugPrint('Error loading graph data: $e');
    return {
      'edges': <EdgeModel>[],
      'nodeMap': <int, NodeModel>{},
    };
  }
}

List<EdgeSegment> createEdgeSegments(
  List<EdgeModel> edges,
  Map<int, NodeModel> nodeMap,
) {
  return edges.map((edge) {
    final fromNode = nodeMap[edge.source];
    final toNode = nodeMap[edge.target];
    // Guard-check for any missing data
    if (fromNode == null || toNode == null) {
      return null; // skip edges if data is incomplete
    }
    return EdgeSegment(
      from: LatLng(fromNode.latitude, fromNode.longitude),
      to: LatLng(toNode.latitude, toNode.longitude),
      population: edge.population,
    );
  }).whereType<EdgeSegment>().toList();
}