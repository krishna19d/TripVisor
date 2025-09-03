import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PerformanceOptimizer {
  static Timer? _debounceTimer;
  static bool _isProcessing = false;

  /// Debounce frequent UI updates to reduce frame drops
  static void debounceUIUpdate(VoidCallback callback, {Duration delay = const Duration(milliseconds: 16)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle expensive operations
  static void throttle(VoidCallback callback) {
    if (!_isProcessing) {
      _isProcessing = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        callback();
        _isProcessing = false;
      });
    }
  }

  /// Add frame barriers for smooth animations
  static Future<void> waitForFrame() async {
    return SchedulerBinding.instance.endOfFrame;
  }

  /// Optimize widget builds by minimizing rebuilds
  static Widget optimizedBuilder({
    required Widget child,
    bool addRepaintBoundary = true,
    bool addAutomaticKeepAlive = false,
  }) {
    Widget result = child;
    
    if (addRepaintBoundary) {
      result = RepaintBoundary(child: result);
    }
    
    if (addAutomaticKeepAlive) {
      result = AutomaticKeepAlive(child: result);
    }
    
    return result;
  }

  /// Dispose resources
  static void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _isProcessing = false;
  }
}
