import 'package:dio/dio.dart';

import '../models/auth_options.dart';

/// Interceptor for handling authentication in API requests.
class AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final authOptions =
        err.requestOptions.extra["authOptions"] as EndpointAuthOptions?;

    if (authOptions != null) {
      final int? statusCode = err.response?.statusCode;

      // Check if the status code is within the unauthorized status codes
      if (authOptions.unauthorizedStatusCodes.contains(statusCode)) {
        // Trigger the onUnauthorizedCallback with the error information
        authOptions.onUnauthorizedCallback(err.response);
      }
    }

    super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra.containsKey("authOptions")) {
      final authOptions = options.extra["authOptions"] as EndpointAuthOptions;

      // Apply authentication to the request using the provided auth options
      handler.next(authOptions.authenticateRequest(options));
    } else {
      handler.next(options);
    }
  }
}
