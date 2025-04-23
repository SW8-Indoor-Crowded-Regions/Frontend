import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  final String? fromRoomName;
  final String? toRoomName;
  final VoidCallback? onClose;
  final VoidCallback? onFromPressed;
  final VoidCallback? onToPressed;
  final VoidCallback? onGetDirections;

  const TopBar({
    super.key,
    this.fromRoomName,
    this.toRoomName,
    this.onClose,
    this.onFromPressed,
    this.onToPressed,
    this.onGetDirections,
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
    _fromController = TextEditingController(text: widget.fromRoomName ?? "Select starting point");
    _toController = TextEditingController(text: widget.toRoomName ?? "Select destination");
  }

  @override
  void didUpdateWidget(TopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fromRoomName != widget.fromRoomName) {
      _fromController.text = widget.fromRoomName ?? 'Select starting point';
    }
    if (oldWidget.toRoomName != widget.toRoomName) {
      _toController.text = widget.toRoomName ?? 'Select destination';
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
      decoration: BoxDecoration(
         color: Colors.white.withValues(alpha: 0.95),
         borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
         ),
         boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
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
                    color: Colors.black87,
                  ),
               ),
              if (widget.onClose != null)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
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
            child: _buildInputField(
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
            child: _buildInputField(
              controller: _toController,
              hint: 'Select destination',
              icon: Icons.location_on,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: widget.onGetDirections,
          icon: const Icon(Icons.directions),
          label: const Text("Get Directions"),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.orange.shade700,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
       padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        enableInteractiveSelection: false,
        style: TextStyle(
           color: controller.text.startsWith("Select") ? Colors.grey.shade600 : Colors.black87,
           fontWeight: controller.text.startsWith("Select") ? FontWeight.normal : FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.orange.shade700, size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}