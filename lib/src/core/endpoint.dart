// lib/src/core/endpoint.dart

import 'dart:async';

import 'package:dio/dio.dart';

import '../utils/logger.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/cache_interceptor.dart';
import 'interceptors/connection_checker.dart';
import 'interceptors/request_logger.dart';
import 'models/auth_options.dart';
import 'models/cache_options.dart';
import 'typedefs.dart';

/// An abstract class defining the structure of an API endpoint.
abstract class ApiEndpoint {
  /// The HTTP method for the API endpoint (e.g., 'GET', 'POST', 'PUT').
  String get method;

  /// The valid status code expected from the API response.
  int get validStatusCode;

  /// The URL of the API endpoint.
  String get url;

  /// The configuration defining caching options.
  CacheOptions get cacheOptions;

  /// The default authentication options for the endpoint.
  EndpointAuthOptions get defaultAuthOptions;

  /// Makes an API request to the endpoint and returns the parsed response of type [T].
  ///
  /// This method allows for various customizations such as:
  /// - [authOptions]: Authentication options specific to this request.
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
  ///
  /// The method returns a [FutureOr] object which, upon completion, yields
  /// a value of type [T] or null.
  FutureOr<T?> call<T>({
    EndpointAuthOptions? authOptions,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? pathParameters,
    Object? data,
    Map<String, dynamic>? headers,
    T Function(dynamic responseBody)? map,
    EndpointErrorCallback? onError,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool isMultipart = false,
    bool ignoreCache = false,
  });
}

/// A base implementation of [ApiEndpoint] that provides common functionality for API endpoints.
abstract class Endpoint implements ApiEndpoint {
  /// Creates an [Endpoint] instance.
  ///
  /// - [dio]: Optional [Dio] instance for making HTTP requests.
  /// - [method]: The HTTP method for the API endpoint (e.g., 'GET', 'POST', 'PUT').
  /// - [url]: The URL of the API endpoint.
  /// - [validStatusCode]: The valid status code expected from the API response (default is 200).
  /// - [defaultAuthOptions]: Default authentication options for the endpoint.
  /// - [cacheOptions]: Configuration defining caching options (default is no caching).
  /// - [interceptors]: Additional interceptors to apply to the [Dio] instance.
  Endpoint({
    Dio? dio,
    required this.method,
    required String url,
    this.validStatusCode = 200,
    EndpointAuthOptions? defaultAuthOptions,
    this.cacheOptions = const CacheOptions(
      cacheDuration: Duration.zero,
    ),
    Iterable<Interceptor> interceptors = const {},
  })  : _url = url,
        defaultAuthOptions = defaultAuthOptions ?? EndpointAuthOptions.none(),
        dio = dio ?? Dio(_options)
          ..interceptors.addAll({
            RequestLogger(),
            AuthInterceptor(),
            CacheInterceptor(validStatusCode: validStatusCode),
            ConnectionChecker(),
            ...interceptors,
          });

  /// The Dio instance used for making HTTP requests.
  final Dio dio;

  @override
  final CacheOptions cacheOptions;

  @override
  final EndpointAuthOptions defaultAuthOptions;

  @override
  final String method;

  @override
  final int validStatusCode;

  static final Map<String, dynamic> _headers = {
    "Accept": "application/json",
    "Content-Type": "application/json"
  };

  static final BaseOptions _options = BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: _headers,
  );

  final String _url;

  @override
  FutureOr<T?> call<T>({
    EndpointAuthOptions? authOptions,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? pathParameters,
    Object? data,
    Map<String, dynamic>? headers,
    T Function(dynamic responseBody)? map,
    EndpointErrorCallback? onError,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool isMultipart = false,
    bool ignoreCache = false,
  }) async {
    T? result;

    try {
      final Response response = await _sendRequest(
        authOptions: authOptions,
        queryParameters: queryParameters,
        pathParameters: pathParameters,
        data: data,
        headers: headers,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        isMultipart: isMultipart,
        ignoreCache: ignoreCache,
      );

      try {
        result = map?.call(response.data) ?? response.data;
        Logger.log('MAPPED DATA: \n$result', name: "$method $_url");
        Logger.log('✅✅✅ Mapping Successful ✅✅✅', name: "$method $_url");
      } catch (e) {
        Logger.log(
          '❌❌❌ Mapping Error ❌❌❌',
          name: "$method $_url",
          error: e,
        );
        throw DioException(
          error: 'Mapping Error',
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.unknown,
        );
      }
    } on DioException catch (e) {
      final errorMessage = "Request Error: ${e.runtimeType}";
      Logger.log(
        '❌❌❌ $errorMessage ❌❌❌',
        name: "$method $_url",
        error: e,
      );
      onError?.call(e);
    } catch (e) {
      Logger.log(e.toString(), name: "$method $_url");
      Logger.log(
        '❌❌❌ Unknown Error ❌❌❌',
        name: "$method $_url",
        error: e,
      );
      onError?.call(DioException(
        error: e,
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: _url),
      ));
    }
    return result;
  }

  @override
  String get url => domainUrl + _url;

  /// The base URL for the API domain.
  String get domainUrl;

  /// Extracts placeholders from the URL path.
  List<String> _extractUrlPlaceholders() {
    RegExp regex = RegExp(r'\{[^{}]*\}');
    Iterable<RegExpMatch> matches = regex.allMatches(url);

    List<String> result = [];
    for (RegExpMatch match in matches) {
      result.add(match.group(0)!);
    }

    return [
      for (String placeholder in result)
        placeholder.substring(1, placeholder.length - 1)
    ];
  }

  /// Sends an HTTP request to the endpoint.
  Future<Response> _sendRequest({
    EndpointAuthOptions? authOptions,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? pathParameters,
    Object? data,
    Map<String, dynamic>? headers,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    required bool isMultipart,
    required bool ignoreCache,
  }) {
    String requestUrl = url;

    final extra = <String, dynamic>{
      if (!ignoreCache) "cacheOptions": cacheOptions,
      "authOptions": authOptions ?? defaultAuthOptions,
      "pathParameters": pathParameters,
    };

    final Set<String> urlPathParameters = _extractUrlPlaceholders().toSet();

    if (urlPathParameters.isNotEmpty) {
      if (pathParameters == null ||
          !pathParameters.keys.toSet().containsAll(urlPathParameters)) {
        throw ArgumentError(
          "This endpoint has required path parameters that were not passed:"
          "\n${urlPathParameters.difference(pathParameters?.keys.toSet() ?? {})}",
        );
      }

      for (String placeholder in urlPathParameters) {
        requestUrl = requestUrl.replaceAll(
          "{$placeholder}",
          pathParameters[placeholder].toString(),
        );
      }
    }

    final options = Options(
      method: method,
      extra: extra,
      receiveTimeout: const Duration(seconds: 30),
      followRedirects: false,
      responseType: ResponseType.json,
      validateStatus: (status) => (status ?? 999) == validStatusCode,
      headers: {
        "content-type": 'application/json; charset=utf-8',
      }..addAll(headers ?? {}),
    );

    final dioRequest =
        isMultipart ? _buildMultipartRequest(data) : _buildRequest(data);

    return dio.request(
      requestUrl,
      data: dioRequest,
      queryParameters: queryParameters,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      options: options,
    );
  }

  /// Builds a multipart request body.
  dynamic _buildMultipartRequest(Object? data) {
    if (data.runtimeType != FormData) {
      throw ArgumentError(
        "isMultipart is set to true but data is not of type FormData",
      );
    }

    final formData = data as FormData;
    final dataMap = <String, dynamic>{}..addEntries(formData.fields);
    final filesMap = <String, MultipartFile>{}..addEntries(formData.files);

    Logger.log('DATA: $dataMap', name: "$method $_url");
    Logger.log(
      'Files: ${{
        for (var k in filesMap.keys) k: filesMap[k]!.filename
      }}, name: "$method $_url"',
    );

    return formData;
  }

  /// Builds a regular request body.
  dynamic _buildRequest(Object? data) {
    return data;
  }
}
