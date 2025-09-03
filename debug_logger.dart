import 'package:flutter/foundation.dart';

class DebugLogger {
  static const String _tag = 'TripVisor';

  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? '/$tag' : ''}] $message');
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? '/$tag' : ''}] ERROR: $message');
      if (error != null) {
        print('[$_tag${tag != null ? '/$tag' : ''}] Error details: $error');
      }
      if (stackTrace != null) {
        print('[$_tag${tag != null ? '/$tag' : ''}] Stack trace: $stackTrace');
      }
    }
  }

  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? '/$tag' : ''}] WARNING: $message');
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? '/$tag' : ''}] INFO: $message');
    }
  }

  static void ads(String message) {
    log(message, tag: 'ADS');
  }

  static void auth(String message) {
    log(message, tag: 'AUTH');
  }

  static void performance(String message) {
    log(message, tag: 'PERFORMANCE');
  }
}
