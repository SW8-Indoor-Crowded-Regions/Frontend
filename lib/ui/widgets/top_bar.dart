import 'package:flutter/material.dart';
import 'package:indoor_crowded_regions_frontend/services/gateway_service.dart';
import 'package:indoor_crowded_regions_frontend/ui/screens/home_screen.dart';
import 'package:indoor_crowded_regions_frontend/ui/widgets/utils/input_field.dart';

class TopBar extends StatefulWidget {
  final Room? fromRoom;
  final Room? toRoom;
  final GatewayService? gatewayService;
  final VoidCallback? onClose;
  final VoidCallback? onFromPressed;
  final VoidCallback? onToPressed;
  final VoidCallback? onGetDirections;
  final Function? setEdgesFuture;

  const TopBar(
      {super.key,
      this.fromRoom,
      this.toRoom,
      this.gatewayService,
      this.onClose,
      this.onFromPressed,
      this.onToPressed,
      this.onGetDirections,
      this.setEdgesFuture});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  late TextEditingController _fromController;
  late TextEditingController _toController;
  GatewayService? _gatewayService;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController(
        text: widget.fromRoom?.name ?? "Select starting point");
    _toController = TextEditingController(
        text: widget.toRoom?.name ?? "Select destination");
    _gatewayService = widget.gatewayService ?? GatewayService();
  }

  @override
  void didUpdateWidget(TopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fromRoom != widget.fromRoom) {
      _fromController.text = widget.fromRoom?.name ?? 'Select starting point';
    }
    if (oldWidget.toRoom != widget.toRoom) {
      _toController.text = widget.toRoom?.name ?? 'Select destination';
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _fetchRoute() {
    if (widget.fromRoom?.id != null && widget.toRoom?.id != null) {
      final res = _gatewayService!.getFastestRouteWithCoordinates(
        widget.fromRoom!.id!,
        widget.toRoom!.id!,
      );

      widget.setEdgesFuture!(res);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Calculating route from ${widget.fromRoom?.name ?? 'Start'} to ${widget.toRoom?.name ?? 'End'}...'),
          backgroundColor: Colors.blue.shade700, // Darker blue for dark mode
          duration: const Duration(seconds: 2),
        ),
      );

      res.then((routeData) {
        if (routeData.isNotEmpty && mounted) {
        } else if (routeData.isEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Could not find a route between the selected points.'),
              backgroundColor:
                  Colors.orange.shade700, // Darker orange for dark mode
            ),
          );
        }
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error calculating route: $error'),
              backgroundColor: Colors.red.shade700, // Darker red for dark mode
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Please select both a starting point and a destination on the map.'),
          backgroundColor: Colors.red.shade700, // Darker red for dark mode
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E)
            .withValues(alpha: 0.95), // Dark background for top bar
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.3), // Darker shadow for visibility
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Route Planner",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Light text for dark mode
                ),
              ),
              if (widget.onClose != null)
                IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.white70), // Light icon for dark mode
                  onPressed: widget.onClose,
                  tooltip: "Close Route Planner",
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRouteInputs(),
        ],
      ),
    );
  }

  Widget _buildRouteInputs() {
    return Column(
      children: [
        InkWell(
          onTap: widget.onFromPressed,
          borderRadius: BorderRadius.circular(8),
          child: AbsorbPointer(
            child: buildInputField(
              controller: _fromController,
              hint: 'Select starting point',
              icon: Icons.my_location,
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.onToPressed,
          borderRadius: BorderRadius.circular(8),
          child: AbsorbPointer(
            child: buildInputField(
              controller: _toController,
              hint: 'Select destination',
              icon: Icons.location_on,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _fetchRoute,
          icon: const Icon(Icons.directions),
          label: const Text("Get Directions"),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor:
                const Color(0xFFFF7D00), // Brighter orange for dark mode
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ],
    );
  }
}
