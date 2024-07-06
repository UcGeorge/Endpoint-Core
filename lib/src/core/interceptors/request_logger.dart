import 'package:dio/dio.dart';

import '../../utils/logger.dart';

/// Interceptor for logging Dio requests, responses, and errors.
class RequestLogger extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logError(err);
    super.onError(err, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logRequest(options);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logResponse(response);
    super.onResponse(response, handler);
  }

  /// Logs the details of a request.
  void _logRequest(RequestOptions options) {
    final url = options.uri.toString();
    final path = options.uri.path;
    final method = options.method;
    final headers = options.headers;
    final queryParameters = options.queryParameters;
    final data = options.data;

    Logger.log('➡️ $method $url', name: "$method $path");
    Logger.log('HEADERS: $headers', name: "$method $path");
    Logger.log('QUERY PARAMETERS: $queryParameters', name: "$method $path");
    if (data != null) Logger.log('DATA: $data', name: "$method $path");
  }

  /// Logs the details of a response.
  void _logResponse(Response response) {
    final url = response.requestOptions.uri.toString();
    final path = response.requestOptions.uri.path;
    final method = response.requestOptions.method;

    Logger.log('SUCCESS: $method $url', name: "$method $path");
    Logger.log('RAW DATA: \n${response.data}', name: "$method $path");
  }

  /// Logs the details of a DioException representing an error.
  void _logError(DioException err) {
    final data = err.requestOptions.data;
    final path = err.requestOptions.uri.path;
    final method = err.requestOptions.method;
    final headers = err.requestOptions.headers;
    final statusCode = err.response?.statusCode;
    final responseData = err.response?.data;
    final responseHeaders = err.response?.headers;
    final queryParameters = err.requestOptions.queryParameters;

    if (err.response != null) {
      Logger.log('🛎️ $method $path', name: "$method $path");
      Logger.log('QUERY PARAMETERS: \n$queryParameters', name: "$method $path");
      Logger.log('REQUEST DATA: \n$data', name: "$method $path");
      Logger.log('REQUEST HEADERS: \n$headers', name: "$method $path");
      Logger.log('STATUS CODE: \n$statusCode', name: "$method $path");
      Logger.log('RESPONSE DATA: \n$responseData', name: "$method $path");
      Logger.log('RESPONSE HEADERS: \n$responseHeaders', name: "$method $path");
    } else {
      Logger.log('Error sending request!', name: "$method $path");
      Logger.log(err.message ?? "", error: err, name: "$method $path");
    }
  }
}
