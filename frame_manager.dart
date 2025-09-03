import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Advanced frame management utilities to reduce BLASTBufferQueue errors
class FrameManager {
  static final FrameManager _instance = FrameManager._internal();
  factory FrameManager() => _instance;
  FrameManager._internal();

  int _droppedFrames = 0;
  int _totalFrames = 0;
  bool _isMonitoring = false;

  /// Start monitoring frame performance
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    SchedulerBinding.instance.addTimingsCallback(_onReportTimings);
  }

  /// Stop monitoring frame performance
  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    SchedulerBinding.instance.removeTimingsCallback(_onReportTimings);
  }

  void _onReportTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      _totalFrames++;
      
      // Check if frame was dropped (took longer than 16.67ms for 60fps)
      final frameDuration = timing.totalSpan.inMicroseconds;
      if (frameDuration > 16670) { // 16.67ms in microseconds
        _droppedFrames++;
      }
    }
  }

  /// Get frame performance statistics
  Map<String, dynamic> getStats() {
    return {
      'totalFrames': _totalFrames,
      'droppedFrames': _droppedFrames,
      'dropRate': _totalFrames > 0 ? (_droppedFrames / _totalFrames) * 100 : 0.0,
    };
  }

  /// Reset statistics
  void resetStats() {
    _droppedFrames = 0;
    _totalFrames = 0;
  }

  /// Optimize widget for better frame performance
  static Widget optimizeForFrames(Widget child, {String? debugName}) {
    return RepaintBoundary(
      child: Builder(
        builder: (context) {
          // Simply return the child without animation wrapper for now
          return child;
        },
      ),
    );
  }

  /// Create a throttled builder that limits rebuild frequency
  static Widget throttledBuilder({
    required Widget Function(BuildContext context) builder,
    Duration throttleDuration = const Duration(milliseconds: 16), // ~60fps
    String? debugName,
  }) {
    DateTime? lastBuild;
    Widget? lastWidget;

    return StatefulBuilder(
      builder: (context, setState) {
        final now = DateTime.now();
        
        // Only rebuild if enough time has passed
        if (lastBuild == null || now.difference(lastBuild!) >= throttleDuration) {
          lastBuild = now;
          lastWidget = RepaintBoundary(
            child: builder(context),
          );
        }

        return lastWidget ?? const SizedBox.shrink();
      },
    );
  }

  /// Wrap a scrollable widget to improve performance
  static Widget optimizeScrollable(Widget scrollableChild) {
    return RepaintBoundary(
      child: ClipRect(
        child: scrollableChild,
      ),
    );
  }

  /// Schedule a frame-safe callback
  static void scheduleFrameSafe(VoidCallback callback) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Use microtask to ensure it runs after current frame
      Future.microtask(callback);
    });
  }

  /// Batch multiple UI updates to reduce frame pressure
  static void batchUIUpdates(List<VoidCallback> updates) {
    if (updates.isEmpty) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Execute all updates in a single frame
      for (final update in updates) {
        try {
          update();
        } catch (e) {
          debugPrint('[FrameManager] Error in batched update: $e');
        }
      }
    });
  }

  /// Force a frame sync to reduce buffer queue pressure
  static void forceFrameSync() {
    SchedulerBinding.instance.ensureVisualUpdate();
  }
}

/// Widget that automatically optimizes its child for frame performance
class FrameOptimizedWidget extends StatelessWidget {
  final Widget child;
  final String? debugName;
  final bool enableRepaintBoundary;
  final bool enableClipping;

  const FrameOptimizedWidget({
    super.key,
    required this.child,
    this.debugName,
    this.enableRepaintBoundary = true,
    this.enableClipping = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget optimizedChild = child;

    if (enableClipping) {
      optimizedChild = ClipRect(child: optimizedChild);
    }

    if (enableRepaintBoundary) {
      optimizedChild = RepaintBoundary(child: optimizedChild);
    }

    return optimizedChild;
  }
}
