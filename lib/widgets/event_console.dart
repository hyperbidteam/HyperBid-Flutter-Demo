import 'package:flutter/material.dart';

/// A small append-only log panel used by every ad screen to surface SDK
/// callbacks. It has no SDK dependency — it is purely a demo UI helper.
class EventConsoleController extends ChangeNotifier {
  final List<String> _lines = <String>[];
  bool _isDisposed = false;

  List<String> get lines => List.unmodifiable(_lines);

  /// Global SDK listeners can outlive the screen that registered them (the
  /// mc_sdk setters are static and non-removable), so every entry point must
  /// be a silent no-op after dispose to avoid notifyListeners-after-dispose.
  void log(String message) {
    if (_isDisposed) return;
    _lines.add(message);
    notifyListeners();
  }

  void clear() {
    if (_isDisposed) return;
    _lines.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

class EventConsole extends StatelessWidget {
  const EventConsole({super.key, required this.controller, this.height = 180});

  final EventConsoleController controller;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final lines = controller.lines;
          return SingleChildScrollView(
            reverse: true,
            child: Text(
              lines.isEmpty ? 'Waiting for events...' : lines.join('\n'),
              style: const TextStyle(
                color: Color(0xFFB9F6CA),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }
}
