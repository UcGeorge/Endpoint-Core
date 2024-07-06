import 'endpoint_core.dart';

/// Example API for a hypothetical country-state-city service
class CountryStateCityApi extends Endpoint {
  CountryStateCityApi({
    required super.method,
    required super.url,
    super.validStatusCode,
    EndpointAuthOptions? authOptions,
    super.cacheOptions = const CacheOptions(cacheDuration: Duration(days: 28)),
  }) : super(
          defaultAuthOptions: authOptions ?? _getDefaultAuthOptions(),
        );

  @override
  String get domainUrl => "https://api.example-country-state-city.com";

  static EndpointAuthOptions _getDefaultAuthOptions() =>
      CustomHeaderTokenAuthOptions(
        headerName: "X-API-KEY",
        token: "your-api-key-here",
        unauthorizedStatusCodes: <int>[401, 403],
        onUnauthorizedCallback: (_) async {
          // Handle unauthorized access
          print("Unauthorized access detected");
        },
      );

  static Map<String, ApiEndpoint> endpoints() => {
        "getAllCountries": CountryStateCityApi(
          method: "GET",
          url: "/v1/countries",
        ),
        "getCountryDetails": CountryStateCityApi(
          method: "GET",
          url: "/v1/countries/{country_code}",
        ),
        "getStatesOfCountry": CountryStateCityApi(
          method: "GET",
          url: "/v1/countries/{country_code}/states",
        ),
        "getCitiesOfState": CountryStateCityApi(
          method: "GET",
          url: "/v1/countries/{country_code}/states/{state_code}/cities",
        ),
      };
}

/// Example API for a hypothetical user management service
class UserManagementApi extends Endpoint {
  UserManagementApi({
    required super.method,
    required super.url,
    super.validStatusCode,
    super.cacheOptions = const CacheOptions(cacheDuration: Duration.zero),
  }) : super(
          defaultAuthOptions: _getDefaultAuthOptions(),
        );

  @override
  String get domainUrl => "https://api.example-user-management.com";

  static EndpointAuthOptions _getDefaultAuthOptions() =>
      EndpointAuthOptions.bearerToken(
        token: "your-bearer-token-here",
        unauthorizedStatusCodes: <int>[401],
        onUnauthorizedCallback: (_) async {
          // Handle unauthorized access, e.g., refresh token or logout
          print("Bearer token expired or invalid");
        },
      );

  static Map<String, ApiEndpoint> endpoints() => {
        "login": UserManagementApi(
          method: "POST",
          url: "/auth/login",
          validStatusCode: 200,
        ),
        "getUserProfile": UserManagementApi(
          method: "GET",
          url: "/users/profile",
          validStatusCode: 200,
        ),
        "updateUserProfile": UserManagementApi(
          method: "PUT",
          url: "/users/profile",
          validStatusCode: 200,
        ),
        "changePassword": UserManagementApi(
          method: "POST",
          url: "/users/change-password",
          validStatusCode: 200,
        ),
      };
}

// Usage example
void main() async {
  // Using CountryStateCityApi
  final countryApi = CountryStateCityApi.endpoints();
  final countries = await countryApi["getAllCountries"]!.call<List<dynamic>>(
    map: (data) => data as List<dynamic>,
  );
  print("Countries: $countries");

  // Using UserManagementApi
  final userApi = UserManagementApi.endpoints();
  final loginResult = await userApi["login"]!.call<Map<String, dynamic>>(
    data: {"username": "example@email.com", "password": "password123"},
    map: (data) => data as Map<String, dynamic>,
  );
  print("Login result: $loginResult");

  final userProfile =
      await userApi["getUserProfile"]!.call<Map<String, dynamic>>(
    map: (data) => data as Map<String, dynamic>,
  );
  print("User profile: $userProfile");
}
