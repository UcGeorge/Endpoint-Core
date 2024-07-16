# Changelog

## [v1.0.1] - 2024-07-16

### Added
- Re-exported entire Dio library:
- `nullIfError` argument to `Endpoint.call` function. 
  This is a flag indicating if the request should return null if an error occurs.

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

## [v1.0.0] - 2024-07-06

### Added
- Initial release of `endpoint_core` library.
- Core functionality for defining and managing API endpoints:
  - `ApiEndpoint`: Abstract class defining the structure of an API endpoint.
  - `Endpoint`: Base implementation providing common functionality for API endpoints.
- Models for handling authentication and caching:
  - `EndpointAuthOptions`: Model for defining authentication options.
  - `CacheOptions`: Model for defining caching options.
- Interceptors for enhancing API request handling:
  - `AuthInterceptor`: Handles authentication for API requests.
  - `CacheInterceptor`: Manages caching of HTTP responses.
  - `ConnectionChecker`: Checks internet connection before making requests.
  - `RequestLogger`: Logs details of requests, responses, and errors.
- Utility for logging:
  - `Logger`: Provides logging functionalities.
- Extensions for Dio:
  - `DioExtensions`: Extends Dio functionalities with additional methods.
- Type definitions for callbacks and API request functions:
  - `OnUnauthorizedCallback`: Callback for handling unauthorized responses.
  - `EndpointErrorMessageDelegate`: Delegate for generating error messages from Dio exceptions.
  - `EndpointErrorCallback`: Callback for handling endpoint errors.
  - `ApiRequestFunction`: Type definition for making API requests.
- Constants for commonly used values.
- Example APIs to demonstrate usage of the library.
- Re-exported Dio types for convenience:
  - `Dio`, `DioException`, `Response`, `RequestOptions`, `Options`.

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

---

This initial release of `endpoint_core` provides a comprehensive framework for building and managing API endpoints using the Dio HTTP client in Dart. It includes essential core classes, models for authentication and caching, interceptors for enhancing request handling, utility classes for logging, and example APIs to demonstrate usage.