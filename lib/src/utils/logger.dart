import 'dart:developer' as developer;

/// A utility class for logging messages and errors.
class Logger {
  /// Logs a message with optional name and error.
  ///
  /// [message] is the main message to be logged.
  /// [name] is an optional name or tag for the log entry.
  /// [error] is an optional error object to be logged along with the message.
  static void log(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: name ?? 'Logger',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Logs an error message with optional name and error object.
  ///
  /// [message] is the error message to be logged.
  /// [name] is an optional name or tag for the log entry.
  /// [error] is an optional error object to be logged along with the message.
  static void logError(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      'ERROR: $message',
      name: name ?? 'Logger',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Logs a warning message with optional name.
  ///
  /// [message] is the warning message to be logged.
  /// [name] is an optional name or tag for the log entry.
  static void logWarning(
    String message, {
    String? name,
  }) {
    developer.log(
      'WARNING: $message',
      name: name ?? 'Logger',
    );
  }

  /// Logs an info message with optional name.
  ///
  /// [message] is the info message to be logged.
  /// [name] is an optional name or tag for the log entry.
  static void logInfo(
    String message, {
    String? name,
  }) {
    developer.log(
      'INFO: $message',
      name: name ?? 'Logger',
    );
  }
}
