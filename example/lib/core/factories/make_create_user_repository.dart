import '../../domain/repositories/user_repository.dart';
import '../../infra/repositories/user_repository_impl.dart';

IUserRepository makeCreateUserRepository() {
  return UserRepositoryImpl();
}
