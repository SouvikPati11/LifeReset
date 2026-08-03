import '../../../../core/utils/result.dart';
import '../entities/daily_quote.dart';
import '../repositories/home_repository.dart';

/// Reads today's motivational quote.
class GetDailyQuote {
  const GetDailyQuote(this._repository);

  final HomeRepository _repository;

  Future<Result<DailyQuote>> call() => _repository.getTodaysQuote();
}
