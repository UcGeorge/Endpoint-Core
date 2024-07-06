import 'package:dio/dio.dart';

import '../typedefs.dart';

/// Enum representing different types of authentication for API endpoints.
enum EndpointAuthType {
  /// No authentication required.
  none,

  /// Bearer token authentication.
  bearerToken,

  /// Custom header token authentication.
  customHeaderToken
}

/// A base class representing authentication options for API endpoints.
abstract class EndpointAuthOptions {
  /// Creates an instance of [EndpointAuthOptions] with the specified authentication type.
  EndpointAuthOptions({
    required this.type,
    required this.unauthorizedStatusCodes,
  });

  /// Creates an instance of [EndpointAuthOptions] with bearer token authentication.
  factory EndpointAuthOptions.bearerToken({
    required String token,
    required List<int> unauthorizedStatusCodes,
    required OnUnauthorizedCallback onUnauthorizedCallback,
  }) =>
      BearerTokenAuthOptions(
        token: token,
        unauthorizedStatusCodes: unauthorizedStatusCodes,
        onUnauthorizedCallback: onUnauthorizedCallback,
      );

  /// Creates an instance of [EndpointAuthOptions] with no authentication.
  factory EndpointAuthOptions.none() =>
      NoAuthOptions(onUnauthorizedCallback: (_) async {});

  /// The type of authentication for the endpoint.
  final EndpointAuthType type;

  /// The HTTP status codes indicating unauthorized access.
  final List<int> unauthorizedStatusCodes;

  /// The callback to be invoked when an unauthorized request is detected.
  OnUnauthorizedCallback get onUnauthorizedCallback;

  /// Authenticates the provided [RequestOptions] based on the specified authentication type.
  RequestOptions authenticateRequest(RequestOptions options);
}

/// Authentication options for an endpoint with no authentication.
class NoAuthOptions extends EndpointAuthOptions {
  /// Creates an instance of [NoAuthOptions].
  ///
  /// The [onUnauthorizedCallback] is a callback to be invoked when an unauthorized request is detected.
  NoAuthOptions({
    required this.onUnauthorizedCallback,
    super.unauthorizedStatusCodes = const <int>[],
  }) : super(type: EndpointAuthType.none);

  /// The callback to be invoked when an unauthorized request is detected.
  @override
  final OnUnauthorizedCallback onUnauthorizedCallback;

  /// Authenticates the provided [RequestOptions] without any modifications.
  @override
  RequestOptions authenticateRequest(RequestOptions options) => options;
}

/// Authentication options for an endpoint using a bearer token.
class BearerTokenAuthOptions extends EndpointAuthOptions {
  /// Creates an instance of [BearerTokenAuthOptions].
  ///
  /// The [token] is the bearer token used for authentication.
  /// The [unauthorizedStatusCodes] are the HTTP status codes indicating unauthorized access.
  /// The [onUnauthorizedCallback] is a callback to be invoked when an unauthorized request is detected.
  BearerTokenAuthOptions({
    required this.token,
    required this.onUnauthorizedCallback,
    required super.unauthorizedStatusCodes,
  }) : super(type: EndpointAuthType.bearerToken);

  /// The bearer token used for authentication.
  final String token;

  /// The callback to be invoked when an unauthorized request is detected.
  @override
  final OnUnauthorizedCallback onUnauthorizedCallback;

  /// Authenticates the provided [RequestOptions] by adding the bearer token to the headers.
  @override
  RequestOptions authenticateRequest(RequestOptions options) {
    return options.copyWith(
      headers: {"Authorization": 'Bearer $token', ...options.headers},
    );
  }
}

/// Options for authenticating requests using a custom header token.
class CustomHeaderTokenAuthOptions extends EndpointAuthOptions {
  /// Creates an instance of [CustomHeaderTokenAuthOptions].
  ///
  /// The [tokenPrefix] is the prefix to be added before the token in the header.
  /// The [token] is the authentication token.
  /// The [headerName] is the name of the custom header.
  /// The [onUnauthorizedCallback] is callback function for unauthorized requests.
  /// The [unauthorizedStatusCodes] is the list of unauthorized status codes.
  CustomHeaderTokenAuthOptions({
    this.tokenPrefix,
    required this.token,
    required this.headerName,
    required this.onUnauthorizedCallback,
    required super.unauthorizedStatusCodes,
  }) : super(type: EndpointAuthType.customHeaderToken);

  /// The name of the custom header to be used for authentication.
  final String headerName;

  /// The authentication token to be included in the custom header.
  final String token;

  /// The optional prefix to be added before the token in the custom header.
  final String? tokenPrefix;

  /// The callback to be invoked when an unauthorized request is detected.
  @override
  final OnUnauthorizedCallback onUnauthorizedCallback;

  /// Authenticates the provided [RequestOptions] by adding the custom header with the token.
  @override
  RequestOptions authenticateRequest(RequestOptions options) {
    return options.copyWith(
      headers: {
        headerName: '${tokenPrefix ?? ""}$token',
        ...options.headers,
      },
    );
  }
}
