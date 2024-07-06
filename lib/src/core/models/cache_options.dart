/// Configuration class for defining caching options.
class CacheOptions {
  /// Creates an instance of [CacheOptions] with the specified cache duration.
  ///
  /// The [cacheDuration] parameter determines how long the data should be kept in the cache.
  const CacheOptions({
    required this.cacheDuration,
  });

  /// The duration for which data should be kept in the cache.
  final Duration cacheDuration;
}
