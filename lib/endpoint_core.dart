/// The `endpoint_core` library provides a robust framework for building and managing API endpoints using the Dio HTTP client in Dart.
///
/// This library includes:
/// - Core endpoint classes and models.
/// - A set of interceptors for handling authentication, caching, connection checks, and logging.
/// - Utilities for logging and extending Dio functionalities.
/// - Convenience re-exports for common Dio types and functionalities.
/// - Example APIs to demonstrate usage.
///
/// The library is designed to streamline the process of making HTTP requests, handling errors, and managing caching and authentication.

library endpoint_core;

// Core
export 'src/core/endpoint.dart';

// Models
export 'src/core/models/auth_options.dart';
export 'src/core/models/cache_options.dart';

// Interceptors
export 'src/core/interceptors/auth_interceptor.dart';
export 'src/core/interceptors/cache_interceptor.dart';
export 'src/core/interceptors/connection_checker.dart';
export 'src/core/interceptors/request_logger.dart';

// Utils
export 'src/utils/logger.dart';

// Extensions
export 'src/extensions/dio_extensions.dart';

// Dio re-export (for convenience)
export 'package:dio/dio.dart'
    show Dio, DioException, Response, RequestOptions, Options;

// Typedefs
export 'src/core/typedefs.dart';

// Constants
export 'src/core/constants.dart';

// Example APIs
export 'example_apis.dart';
