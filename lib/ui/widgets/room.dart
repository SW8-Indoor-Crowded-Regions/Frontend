import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class Room {
  final String name;
  final LatLng location;
  final IconData icon;
  final Color color;

  Room({
    required this.name,
    required this.location,
    required this.icon,
    required this.color
  });
}

// Example room list
List<Room> rooms = [
  Room(name: "Room 101", location: const LatLng(55.688500, 12.577315), icon: Icons.meeting_room, color: Colors.black),
  Room(name: "Bathroom", location: const LatLng(55.68875, 12.57818), icon: Icons.wc, color: Colors.black),
  Room(name: "Cafeteria", location: const LatLng(55.6890, 12.5783), icon: Icons.local_cafe, color: Colors.black),
  // Add more rooms
];
