import 'package:flutter_test/flutter_test.dart';
import 'package:lifereset/config/environment.dart';
import 'package:lifereset/core/errors/failures.dart';
import 'package:lifereset/core/utils/result.dart';

void main() {
  group('EnvironmentX.resolve', () {
    test('maps known aliases to the correct environment', () {
      expect(EnvironmentX.resolve('prod'), Environment.production);
      expect(EnvironmentX.resolve('PRODUCTION'), Environment.production);
      expect(EnvironmentX.resolve('staging'), Environment.staging);
      expect(EnvironmentX.resolve('dev'), Environment.development);
    });

    test('falls back to development for unknown values', () {
      expect(EnvironmentX.resolve('nonsense'), Environment.development);
    });
  });

  group('Result', () {
    test('Success folds through the success branch', () {
      const Result<int> result = Success(42);
      final folded = result.when(
        success: (value) => 'value:$value',
        failure: (_) => 'failure',
      );
      expect(result.isSuccess, isTrue);
      expect(folded, 'value:42');
    });

    test('FailureResult folds through the failure branch', () {
      const Result<int> result =
          FailureResult(NetworkFailure('offline'));
      final folded = result.when(
        success: (_) => 'value',
        failure: (f) => 'failure:${f.message}',
      );
      expect(result.isFailure, isTrue);
      expect(folded, 'failure:offline');
    });
  });
}
