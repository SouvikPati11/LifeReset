import 'environment.dart';

/// Central, immutable application configuration.
///
/// Values here are resolved once at startup from the active [Environment].
/// Secrets (API keys, etc.) are never hard-coded — they are supplied at build
/// time via `--dart-define` and read through [Environment].
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.geminiApiKey,
    required this.razorpayKeyId,
  });

  final Environment environment;

  /// Google Gemini API key (injected via `--dart-define=GEMINI_API_KEY=...`).
  final String geminiApiKey;

  /// Razorpay public key id (injected via `--dart-define=RAZORPAY_KEY_ID=...`).
  final String razorpayKeyId;

  bool get isProduction => environment == Environment.production;
  bool get isDevelopment => environment == Environment.development;

  /// Builds the configuration from compile-time environment variables.
  factory AppConfig.fromEnvironment() {
    return AppConfig(
      environment: EnvironmentX.resolve(
        const String.fromEnvironment('APP_ENV', defaultValue: 'development'),
      ),
      geminiApiKey: const String.fromEnvironment('GEMINI_API_KEY'),
      razorpayKeyId: const String.fromEnvironment('RAZORPAY_KEY_ID'),
    );
  }
}
