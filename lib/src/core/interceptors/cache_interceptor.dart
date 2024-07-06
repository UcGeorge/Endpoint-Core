import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/logger.dart';
import '../models/cache_options.dart';

/// Interceptor for caching HTTP responses based on specified options.
class CacheInterceptor extends Interceptor {
  /// Creates a [CacheInterceptor] with the specified valid status code.
  CacheInterceptor({required this.validStatusCode});

  /// The valid status code to consider for caching.
  final int validStatusCode;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.uri.path;
    final method = options.method;
    final cacheOptions = options.extra["cacheOptions"] as CacheOptions?;

    final String cacheKey = _getCacheKey(options);
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if caching is enabled and if the cache contains the key
    if (cacheOptions != null && prefs.containsKey(cacheKey)) {
      final cacheDuration = cacheOptions.cacheDuration;
      String cachedValue = prefs.getString(cacheKey)!;
      var decodedValue = json.decode(cachedValue) as Map<String, dynamic>;
      DateTime updatedAt = DateTime.parse(decodedValue["updatedAt"]);

      // Check if the cache is still valid
      if (DateTime.now().difference(updatedAt) < cacheDuration) {
        Logger.log(
          "Resolving request with cached response",
          name: "$method $path",
        );
        return handler.resolve(
          Response(
            data: decodedValue["data"],
            requestOptions: options,
            statusCode: validStatusCode,
          ),
          true,
        );
      } else {
        // Remove expired cache
        prefs.remove(cacheKey);
      }
    }

    Logger.log("Making a new request", name: "$method $path");
    super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    final cacheOptions =
        response.requestOptions.extra["cacheOptions"] as CacheOptions?;
    final cacheDuration = cacheOptions?.cacheDuration ?? Duration.zero;

    // Cache the response if caching is enabled
    if (cacheDuration > Duration.zero) {
      final String cacheKey = _getCacheKey(response.requestOptions);
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      var cacheValue = {
        "updatedAt": DateTime.now().toIso8601String(),
        "data": response.data,
      };

      String encodedValue = json.encode(cacheValue);
      await prefs.setString(cacheKey, encodedValue);
    }

    handler.next(response);
  }

  /// Generates a cache key based on the request options.
  String _getCacheKey(RequestOptions options) {
    final data = options.data;
    final method = options.method;
    final headers = options.headers;
    final url = options.uri.toString();
    final queryParameters = options.queryParameters;
    final pathParameters =
        options.extra["pathParameters"] as Map<String, dynamic>?;
    final cacheOptions = options.extra["cacheOptions"] as CacheOptions?;
    final cacheDuration = cacheOptions?.cacheDuration ?? Duration.zero;

    // Create a string representation of the request
    final callDef = "$method $url"
        "\nH:$headers"
        "\nP:$pathParameters"
        "\nQ:$queryParameters"
        "\nB:$data"
        "\nC:${cacheDuration.inMilliseconds}";

    // Generate a hash of the request string to use as a cache key
    final hash = sha256.convert(utf8.encode(callDef.toLowerCase())).toString();
    Logger.log(
      callDef,
      name: "$method ${Uri.parse(url).path}",
      error: hash,
    );

    return hash;
  }
}
