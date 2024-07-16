import 'package:dio/dio.dart';

import 'models/auth_options.dart';

/// A callback type for handling unauthorized responses.
///
/// [response]: The response that was unauthorized.
typedef OnUnauthorizedCallback = Future<void> Function(Response? response);

/// A delegate type for generating error messages from [DioException].
///
/// [exception]: The Dio exception that occurred.
typedef EndpointErrorMessageDelegate = String Function(DioException exception);

/// A callback type for handling endpoint errors.
///
/// [exception]: The Dio exception that occurred.
typedef EndpointErrorCallback = Function(DioException exception);

/// A type definition for making API requests.
///
/// This function allows for making an API request with various parameters:
/// - [authOptions]: Authentication options specific to the request.
/// - [queryParameters]: Query parameters to include in the URL.
/// - [pathParameters]: Path parameters to include in the URL.
/// - [data]: The body of the request (for POST, PUT, etc.).
/// - [headers]: Additional headers to include in the request.
/// - [map]: A function to map the response body to the desired type [T].
/// - [onError]: A callback function to handle errors.
/// - [onSendProgress]: A callback to track the progress of data being sent.
/// - [onReceiveProgress]: A callback to track the progress of data being received.
/// - [isMultipart]: A flag indicating if the request is multipart.
/// - [ignoreCache]: A flag indicating if the cache should be ignored for this request.
/// - [nullIfError]: A flag indicating if the request should return null if an error occurs.
///
/// The function returns a [Future] that yields a value of type [T] or null.
typedef ApiRequestFunction = Future<T?> Function<T>({
  EndpointAuthOptions? authOptions,
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? pathParameters,
  Object? data,
  Map<String, dynamic>? headers,
  T Function(dynamic responseBody)? map,
  EndpointErrorCallback? onError,
  ProgressCallback? onSendProgress,
  ProgressCallback? onReceiveProgress,
  bool isMultipart,
  bool ignoreCache,
  bool nullIfError,
});
