import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';

/// Exposes the resolved [AppConfig] to the widget tree.
///
/// Overridden in `main.dart` at startup with the concrete configuration so the
/// rest of the app depends on this provider rather than reading environment
/// variables directly.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError(
    'appConfigProvider must be overridden in ProviderScope at app startup.',
  );
});
