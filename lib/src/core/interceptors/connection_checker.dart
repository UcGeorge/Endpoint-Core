import 'package:dio/dio.dart';

import '../../utils/logger.dart';

/// Interceptor for checking internet connection before making HTTP requests.
class ConnectionChecker extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.uri.path;
    final method = options.method;

    // Check if the internet connection is available
    if (!await _checkConnection()) {
      Logger.log(
        '❌❌❌ Unable to connect to the internet ❌❌❌',
        name: "$method $path",
      );
      // Reject the request if no internet connection is available
      handler.reject(
        DioException(
          requestOptions: options,
          error: "Unable to connect to the internet. "
              "Check your internet connection and try again.",
          type: DioExceptionType.connectionError,
        ),
        true,
      );
    } else {
      // Proceed with the request if internet connection is available
      handler.next(options);
    }
  }

  /// Checks the internet connection by making a test request to a known endpoint.
  Future<bool> _checkConnection() async {
    final Dio dio = Dio();
    const endpoint = 'https://www.google.com';
    try {
      final Response response = await dio.get(endpoint);
      // Return true if the status code indicates success
      return response.statusCode == 200;
    } catch (e) {
      // Return false if any error occurs
      return false;
    }
  }
}
