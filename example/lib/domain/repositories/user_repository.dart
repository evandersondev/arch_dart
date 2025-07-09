import '../entities/user_entity.dart';

abstract class IUserRepository {
  Future<void> save(UserEntity user);
}
