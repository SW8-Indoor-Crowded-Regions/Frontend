import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class UserLocationWidget extends StatefulWidget {
  final MapController mapController;
  bool hasAlteredMap;
  UserLocationWidget({super.key, required this.mapController, this.hasAlteredMap = false});

  void updateAlteredMap(bool value) {
    hasAlteredMap = value;
  }

  @override
  State<UserLocationWidget> createState() => _UserLocationWidgetState();
}

class _UserLocationWidgetState extends State<UserLocationWidget> {
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;
  bool hasAlteredMap = false;

  @override
  void initState() {
    super.initState();
    initLocation();
  }

  Future<void> initLocation() async {
    await Future.delayed(const Duration(seconds: 1));
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _locationData = await location.getLocation();
    if (mounted) {
      setState(() {
        widget.mapController.move(
          LatLng(_locationData?.latitude ?? 0, _locationData?.longitude ?? 0),
          16,
        );
      });
    }

    updateLocation();
  }

  double calculateDistance(double oldLat, double oldLong, double newLat, double newLong) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, LatLng(oldLat, oldLong), LatLng(newLat, newLong));
  }

  void updateLocation() {
    location.onLocationChanged.listen((LocationData newLocation) {
      if (_locationData == null ||
        calculateDistance(_locationData!.latitude!, _locationData!.longitude!,
                          newLocation.latitude!, newLocation.longitude!) > 1) {
        setState(() {
          _locationData = newLocation;
          if (!widget.hasAlteredMap) {
            widget.mapController.move(LatLng(newLocation.latitude!, newLocation.longitude!), widget.mapController.camera.zoom);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_locationData == null ||
        _locationData!.latitude == null ||
        _locationData!.longitude == null) {
      return const SizedBox();
    }

    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(_locationData!.latitude!, _locationData!.longitude!),
          width: 30,
          height: 30,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
