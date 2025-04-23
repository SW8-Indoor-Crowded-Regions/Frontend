import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  final String title;
  final String? fromRoomName;
  final String? toRoomName;
  final Function(String?, String?)? onRouteChanged;
  final VoidCallback? onClose;
  final VoidCallback? onFromPressed;
  final VoidCallback? onToPressed;

  const TopBar({
    super.key,
    required this.title,
    this.fromRoomName,
    this.toRoomName,
    this.onRouteChanged,
    this.onClose,
    this.onFromPressed,
    this.onToPressed,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  late TextEditingController _fromController;
  late TextEditingController _toController;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController(text: widget.fromRoomName);
    _toController = TextEditingController(text: widget.toRoomName);
  }

  @override
  void didUpdateWidget(TopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fromRoomName != widget.fromRoomName) {
      _fromController.text = widget.fromRoomName ?? '';
    }
    if (oldWidget.toRoomName != widget.toRoomName) {
      _toController.text = widget.toRoomName ?? '';
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      // ignore: deprecated_member_use
      color: Colors.white.withOpacity(0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Route Planner",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (widget.onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
            ],
          ),
          const SizedBox(height: 8),
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
            child: _buildInputField(
              controller: _fromController,
              label: 'From',
              icon: Icons.my_location,
              onChanged: (value) {
                if (widget.onRouteChanged != null) {
                  widget.onRouteChanged!(value, _toController.text);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.onToPressed,
          borderRadius: BorderRadius.circular(8),
          child: AbsorbPointer(
            child: _buildInputField(
              controller: _toController,
              label: 'To',
              icon: Icons.location_on,
              onChanged: (value) {
                if (widget.onRouteChanged != null) {
                  widget.onRouteChanged!(_fromController.text, value);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            if (widget.onRouteChanged != null) {
              widget.onRouteChanged!(_fromController.text, _toController.text);
            }
          },
          icon: const Icon(Icons.directions),
          label: const Text("Get Directions"),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.orange.shade800,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        readOnly:
            true, // Make the field read-only to prevent keyboard from showing
        enableInteractiveSelection: false, // Disable text selection
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.orange.shade800),
          hintText: label,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
