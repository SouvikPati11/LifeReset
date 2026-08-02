/// The runtime environment the app is executing in.
enum Environment {
  development,
  staging,
  production,
}

extension EnvironmentX on Environment {
  String get name {
    switch (this) {
      case Environment.development:
        return 'development';
      case Environment.staging:
        return 'staging';
      case Environment.production:
        return 'production';
    }
  }

  /// Resolves an [Environment] from a raw string (case-insensitive).
  /// Falls back to [Environment.development] for unknown values.
  static Environment resolve(String value) {
    switch (value.toLowerCase()) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'staging':
      case 'stage':
        return Environment.staging;
      case 'development':
      case 'dev':
      default:
        return Environment.development;
    }
  }
}
