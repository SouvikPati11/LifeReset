import '../../../../core/utils/result.dart';
import '../../../../shared/repositories/base_repository.dart';
import '../../domain/entities/subscription_models.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_data_source.dart';

class SubscriptionRepositoryImpl extends BaseRepository
    implements SubscriptionRepository {
  SubscriptionRepositoryImpl(this._remote);

  final SubscriptionRemoteDataSource _remote;

  @override
  Stream<SubscriptionState> watchSubscription(String uid) =>
      _remote.watchSubscription(uid);

  @override
  Stream<List<TransactionRecord>> watchTransactions(String uid) =>
      _remote.watchTransactions(uid);

  @override
  Future<Result<CheckoutOrder>> createOrder() =>
      guard(() => _remote.createOrder());

  @override
  Future<Result<void>> verifyPayment(PaymentHandshake handshake) =>
      guard(() => _remote.verifyPayment(handshake));

  @override
  Future<Result<void>> startFreeTrial() =>
      guard(() => _remote.startFreeTrial());

  @override
  Future<Result<void>> cancelAutoRenew() =>
      guard(() => _remote.cancelAutoRenew());

  @override
  Future<Result<void>> resumeAutoRenew() =>
      guard(() => _remote.resumeAutoRenew());

  @override
  Future<Result<void>> restore() => guard(() => _remote.restore());
}
