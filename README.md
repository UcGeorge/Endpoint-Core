# Endpoint Core

Endpoint Core is a powerful and flexible Dart package for building and managing API endpoints in Flutter applications. It provides a structured way to define, authenticate, and interact with RESTful APIs, leveraging the popular Dio HTTP client.

## Features

- Easy-to-use API endpoint definition
- Support for custom data models
- Flexible authentication options (Bearer Token, Custom Header)
- Built-in request caching with customizable options
- Automatic error handling and parsing
- Customizable interceptors for logging, connection checking, and more
- Dio extension methods for common tasks
- Fully testable architecture

## Installation

Add `endpoint_core` to your `pubspec.yaml` file:

```yaml
dependencies:
  endpoint_core: ^1.0.0
```

Then run:

```
flutter pub get
```

## Usage

### Defining Custom Models

First, let's define a custom model that we'll use with our API:

```dart
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
```

### Defining an API with Custom Models and Cached Endpoints

Now, let's define an API that uses our custom `User` model and includes cached endpoints:

```dart
import 'package:endpoint_core/endpoint_core.dart';

class UserApi extends Endpoint {
  UserApi({
    required super.method,
    required super.url,
    super.validStatusCode,
    super.defaultAuthOptions,
    super.cacheOptions,
  });

  @override
  String get domainUrl => "https://api.example.com";

  static Map<String, ApiEndpoint> endpoints() => {
    "getUsers": UserApi(
      method: "GET",
      url: "/users",
      validStatusCode: 200,
      defaultAuthOptions: EndpointAuthOptions.bearerToken(
        token: "your-token-here",
        unauthorizedStatusCodes: [401, 403],
        onUnauthorizedCallback: (_) {
          // Handle unauthorized access
        },
      ),
      cacheOptions: CacheOptions(cacheDuration: Duration(minutes: 5)),
    ),
    "getUserById": UserApi(
      method: "GET",
      url: "/users/{id}",
      validStatusCode: 200,
      cacheOptions: CacheOptions(cacheDuration: Duration(hours: 1)),
    ),
    "createUser": UserApi(
      method: "POST",
      url: "/users",
      validStatusCode: 201,
    ),
    "updateUser": UserApi(
      method: "PUT",
      url: "/users/{id}",
      validStatusCode: 200,
    ),
  };
}
```

### Making API Calls with Custom Models and Caching

Here's how you can use the API with custom models and take advantage of caching:

```dart
void main() async {
  final api = UserApi.endpoints();
  
  // Get all users (cached for 5 minutes)
  final users = await api["getUsers"]!.call<List<User>>(
    map: (data) => (data as List).map((json) => User.fromJson(json)).toList(),
  );
  print("All users: $users");
  
  // Get a specific user by ID (cached for 1 hour)
  final user = await api["getUserById"]!.call<User>(
    pathParameters: {"id": "123"},
    map: (data) => User.fromJson(data),
  );
  print("User with ID 123: $user");
  
  // Create a new user (not cached)
  final newUser = await api["createUser"]!.call<User>(
    data: User(id: 0, name: "John Doe", email: "john@example.com").toJson(),
    map: (data) => User.fromJson(data),
  );
  print("Newly created user: $newUser");
  
  // Update a user (not cached)
  final updatedUser = await api["updateUser"]!.call<User>(
    pathParameters: {"id": "123"},
    data: {"name": "Jane Doe"},
    map: (data) => User.fromJson(data),
  );
  print("Updated user: $updatedUser");
}
```

### Working with Cached Endpoints

When working with cached endpoints, keep in mind:

1. The `CacheOptions` in the endpoint definition determines how long the response will be cached.
2. Cached responses are automatically returned for subsequent calls within the cache duration.
3. You can force a fresh request by setting `ignoreCache` to `true`:

```dart
final freshUserData = await api["getUserById"]!.call<User>(
  pathParameters: {"id": "123"},
  map: (data) => User.fromJson(data),
  ignoreCache: true, // This will ignore any cached data and make a fresh request
);
```

4. Cache keys are generated based on the full request details, including URL, method, headers, and body. This ensures that different requests don't accidentally share cached data.

5. The cache is automatically cleared when it expires. You don't need to manually manage cache expiration.

### Custom Authentication

```dart
final customAuthOptions = CustomHeaderTokenAuthOptions(
  headerName: "X-API-Key",
  token: "your-api-key-here",
  unauthorizedStatusCodes: [401],
  onUnauthorizedCallback: (_) {
    // Handle unauthorized access
  },
);

final result = await api["someEndpoint"]!.call(
  authOptions: customAuthOptions,
  // other parameters...
);
```

### Using Interceptors

The package comes with several built-in interceptors:

- `AuthInterceptor`: Handles authentication
- `CacheInterceptor`: Manages request caching
- `ConnectionChecker`: Checks for internet connectivity
- `RequestLogger`: Logs request and response details

You can add custom interceptors when defining your API:

```dart
class MyApi extends Endpoint {
  MyApi({
    // ... other parameters
  }) : super(
    interceptors: [MyCustomInterceptor()],
  );
  
  // ... rest of the class
}
```

### Custom Caching Behavior

If you need more control over caching behavior, you can implement a custom `CacheInterceptor`:

```dart
class CustomCacheInterceptor extends CacheInterceptor {
  CustomCacheInterceptor({required super.validStatusCode});

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Custom caching logic here
    // For example, you might want to cache based on custom headers:
    final customCacheDuration = response.headers.value('X-Cache-Duration');
    if (customCacheDuration != null) {
      final duration = Duration(seconds: int.parse(customCacheDuration));
      // Implement custom caching logic with this duration
    }

    super.onResponse(response, handler);
  }
}

// Then use this custom interceptor when defining your API:
class UserApi extends Endpoint {
  UserApi({
    // ... other parameters
  }) : super(
    interceptors: [CustomCacheInterceptor(validStatusCode: 200)],
  );
  
  // ... rest of the class
}
```

### Dio Extensions

The package provides useful Dio extensions:

```dart
final dio = Dio();

// Add authorization header to all requests
dio.addAuthorizationInterceptor('your-token-here');

// Add a custom header to all requests
dio.addCustomHeader('X-Custom-Header', 'custom-value');

// Check if a response is successful
if (response.isSuccessful) {
  // Handle successful response
}

// Get a user-friendly error message
print(dioError.friendlyMessage);
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.