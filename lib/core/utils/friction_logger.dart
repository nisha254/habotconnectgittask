// lib/core/utils/friction_logger.dart
import 'dart:async';

/// Status of the friction tracking state machine.
enum FrictionStatus {
  idle,       // Not focused
  tracking,   // Focused, user actively typing / countdown running
  stalled,    // Focused, user paused for > 5 seconds
  resumed,    // User resumed typing after a stall
}

/// A friction event logged when a user stalls on an input field for > 5 seconds.
class FrictionEvent {
  final String fieldName;
  final DateTime timestamp;
  final String type; // 'stall' or 'resumed'

  const FrictionEvent({
    required this.fieldName,
    required this.timestamp,
    required this.type,
  });

  @override
  String toString() {
    final time = '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
    return '[$time] ${type.toUpperCase()} on "$fieldName"';
  }
}

/// Tracks UI friction events per field with real-time status callbacks.
class FrictionLogger {
  static const Duration stallThreshold = Duration(seconds: 5);

  final String fieldName;
  final void Function(FrictionEvent event) onEvent;
  final void Function(FrictionStatus status)? onStatusChanged;

  Timer? _stallTimer;
  FrictionStatus _status = FrictionStatus.idle;
  final List<FrictionEvent> _log = [];

  FrictionLogger({
    required this.fieldName,
    required this.onEvent,
    this.onStatusChanged,
  });

  List<FrictionEvent> get log => List.unmodifiable(_log);
  FrictionStatus get status => _status;
  bool get isStalled => _status == FrictionStatus.stalled;

  /// Call when user focuses the input field.
  void startTracking() {
    _setStatus(FrictionStatus.tracking);
    _resetTimer();
  }

  /// Call on every keystroke / user interaction.
  void onUserInteracted() {
    if (_status == FrictionStatus.stalled) {
      final event = FrictionEvent(
        fieldName: fieldName,
        timestamp: DateTime.now(),
        type: 'resumed',
      );
      _log.add(event);
      onEvent(event);
      _setStatus(FrictionStatus.resumed);

      // Transition back to tracking after brief resumed feedback
      Timer(const Duration(seconds: 2), () {
        if (_status == FrictionStatus.resumed) {
          _setStatus(FrictionStatus.tracking);
        }
      });
    } else if (_status != FrictionStatus.resumed) {
      _setStatus(FrictionStatus.tracking);
    }
    _resetTimer();
  }

  /// Call when user leaves the input field.
  void stopTracking() {
    _stallTimer?.cancel();
    _stallTimer = null;
    _setStatus(FrictionStatus.idle);
  }

  void _resetTimer() {
    _stallTimer?.cancel();
    _stallTimer = Timer(stallThreshold, _onStallDetected);
  }

  void _onStallDetected() {
    _setStatus(FrictionStatus.stalled);
    final event = FrictionEvent(
      fieldName: fieldName,
      timestamp: DateTime.now(),
      type: 'stall',
    );
    _log.add(event);
    onEvent(event);
  }

  void _setStatus(FrictionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      onStatusChanged?.call(_status);
    }
  }

  void dispose() {
    _stallTimer?.cancel();
    _stallTimer = null;
  }
}
