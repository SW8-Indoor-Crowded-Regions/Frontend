import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class Room {
  final String name;
  final String description;
  final LatLng location;
  List<LatLng>? corners;
  final IconData icon;
  final Color color;

  Room({
    required this.name,
    required this.description,
    required this.location,
    this.corners,
    required this.icon,
    required this.color
  });

  num get minZoomThreshold => 19;
}

// Example room list
List<Room> rooms = [
  // Rooms
  Room(name: "Room 101", location: const LatLng(55.688495, 12.577325), description: "Ancient Greece Statues", icon: Icons.place, color: Colors.black),
  Room(name: "Room 102", location: const LatLng(55.688732, 12.577545), description: "Ancient Roman Statues", icon: Icons.place, color: Colors.black),
  Room(name: "Room 103", location: const LatLng(55.688732, 12.577640), description: "Ancient Roman Statues", icon: Icons.place, color: Colors.black),
  Room(name: "Room 104", location: const LatLng(55.688732, 12.577728), description: "Ancient Roman Statues", icon: Icons.place, color: Colors.black),
  Room(name: "Room 105", location: const LatLng(55.688732, 12.577816), description: "Ancient Roman Statues", icon: Icons.place, color: Colors.black),
  Room(name: "Room 106", location: const LatLng(55.688732, 12.577904), description: "Ancient Roman Statues", icon: Icons.place, color: Colors.black),
  Room(name: "Room 107", location: const LatLng(55.688732, 12.577998), description: "Ancient Roman Statues", icon: Icons.place, color: Colors.black),

  // Toilets
  Room(
    name: "Bathroom", 
    location: const LatLng(55.68875, 12.57818), 
    corners: [
      const LatLng(55.68878846831496, 12.578127398210889), 
      const LatLng(55.688788018310774, 12.578234373336088),
      const LatLng(55.6887060049609, 12.578127797371794),
      const LatLng(55.68870555495577, 12.578234373336088)
    ], 
    description: "Skibidi Toilet", 
    icon: Icons.wc, 
    color: Colors.black
  ),
  Room(name: "Bathroom", location: const LatLng(55.688732, 12.57904), description: "Skibidi Toilet", icon: Icons.wc, color: Colors.black),

  // Restaurants
  Room(name: "Cafeteria", location: const LatLng(55.6890, 12.5783), description: "Veri gud fud", icon: Icons.local_cafe, color: Colors.black),
];
