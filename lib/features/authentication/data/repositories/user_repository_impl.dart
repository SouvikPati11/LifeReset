import '../../../../core/utils/result.dart';
import '../../../../shared/repositories/base_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

/// [UserRepository] backed by a [UserRemoteDataSource] (Cloud Firestore).
class UserRepositoryImpl extends BaseRepository implements UserRepository {
  UserRepositoryImpl(this._remote);

  final UserRemoteDataSource _remote;

  @override
  Stream<UserProfile?> watchProfile(String uid) => _remote.watchProfile(uid);

  @override
  Future<Result<UserProfile?>> getProfile(String uid) {
    return guard<UserProfile?>(() => _remote.getProfile(uid));
  }

  @override
  Future<Result<void>> ensureProfile(AuthUser user) {
    return guard<void>(() => _remote.ensureProfile(user));
  }
}
