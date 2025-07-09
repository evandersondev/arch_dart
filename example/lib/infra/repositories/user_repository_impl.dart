import 'package:example/domain/entities/user_entity.dart';
import 'package:example/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements IUserRepository {
  void anyMethod(dynamic client) {
    // implementação do método
  }

  @override
  Future<void> save(UserEntity user) {
    throw UnimplementedError();
  }
}
