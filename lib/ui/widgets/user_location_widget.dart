import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class UserLocationWidget extends StatefulWidget {
  final MapController mapController;
  bool hasAlteredMap;
  UserLocationWidget({
    super.key, 
    required this.mapController, 
    this.hasAlteredMap = false, 
  });

  void updateAlteredMap(bool value) {
    hasAlteredMap = value;
  }

  @override
  State<UserLocationWidget> createState() => UserLocationWidgetState();
}

class UserLocationWidgetState extends State<UserLocationWidget> {
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData;
  bool hasAlteredMap = false;
  double heading = 0.0;
  double smkLat = 55.68875;
  double smkLong = 12.5783;
  double ourLat = 55.6509822;
  double ourLong = 12.5420834;
  double latOffset = 55.68875 - 55.6509822;
  double longOffset = 12.5783 - 12.5420834;

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
          LatLng(smkLat, smkLong), 17.5,
          // DO NOT DELETE COMMENT PLZ
          //LatLng(_locationData?.latitude ?? 0, _locationData?.longitude ?? 0), 16,
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
      if (newLocation.heading != null) {
        setState(() {
          heading = newLocation.heading!;
        });
      }
      if (_locationData == null ||
        calculateDistance(_locationData!.latitude!, _locationData!.longitude!,
                          newLocation.latitude!, newLocation.longitude!) > 1) {
        _locationData = newLocation;

        double adjustedLat = newLocation.latitude! + latOffset;
        double adjustedLong = newLocation.longitude! + longOffset;

        if (!widget.hasAlteredMap) {
          widget.mapController.move(
            LatLng(adjustedLat, adjustedLong),
            widget.mapController.camera.zoom,
          );
          // DO NOT DELETE COMMENT PLZ (this is the actual implementation, the above is used for offset)
          //widget.mapController.move(LatLng(newLocation.latitude!, newLocation.longitude!), widget.mapController.camera.zoom);
        }
      }
    });
  }

  void recenterLocation() {
  if (_locationData != null) {
    double adjustedLat = _locationData!.latitude! + latOffset;
    double adjustedLong = _locationData!.longitude! + longOffset;
    widget.mapController.move(
      LatLng(adjustedLat, adjustedLong),
      widget.mapController.camera.zoom,
    );
    // DO NOT DELETE COMMENT PLZ (this is the actual implementation, the above is used for offset)
    /*
    widget.mapController.move(
      LatLng(_locationData!.latitude!, _locationData!.longitude!), 
      widget.mapController.camera.zoom,
    );
    */
  }
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
          point: LatLng(_locationData!.latitude! + latOffset, _locationData!.longitude! + longOffset),
          width: 30,
          height: 30,
          child: Transform.rotate(
            angle: heading * (math.pi / 180),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    color: Colors.white, 
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(
                  Icons.assistant_navigation,
                  color: Colors.blue,
                  size: 30, 
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
