import 'package:dio/dio.dart';

/// Extension methods for Dio and its related classes.
extension DioExtensions on Dio {
  /// Adds an authorization header to all requests made by this Dio instance.
  ///
  /// [token] is the authorization token to be added.
  /// [scheme] is the authorization scheme (default is 'Bearer').
  void addAuthorizationInterceptor(String token, {String scheme = 'Bearer'}) {
    interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = '$scheme $token';
          return handler.next(options);
        },
      ),
    );
  }

  /// Adds a custom header to all requests made by this Dio instance.
  ///
  /// [name] is the name of the header.
  /// [value] is the value of the header.
  void addCustomHeader(String name, String value) {
    interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers[name] = value;
          return handler.next(options);
        },
      ),
    );
  }
}

extension ResponseExtensions on Response {
  /// Checks if the response status code indicates a successful request.
  bool get isSuccessful =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;

  /// Checks if the response status code indicates a client error.
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Checks if the response status code indicates a server error.
  bool get isServerError => statusCode != null && statusCode! >= 500;
}

extension DioErrorExtensions on DioException {
  /// Returns a user-friendly error message based on the error type.
  String get friendlyMessage {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please check your internet connection and try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timed out while sending data. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timed out. Please check your internet connection and try again.';
      case DioExceptionType.badCertificate:
        return 'There was a problem with the server\'s security certificate. Please try again later.';
      case DioExceptionType.badResponse:
        return 'The server returned an unexpected response. Please try again.';
      case DioExceptionType.cancel:
        return 'The request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection and try again.';
      case DioExceptionType.unknown:
        return 'An unknown error occurred. Please try again.';
    }
  }
}
