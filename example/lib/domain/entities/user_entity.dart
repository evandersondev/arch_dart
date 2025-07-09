// import 'package:http/http.dart' as http;

import '../repositories/user_repository.dart';

final class UserEntity {
  final IUserRepository repository;

  UserEntity(this.repository);

  // final client = http.Client();
}
