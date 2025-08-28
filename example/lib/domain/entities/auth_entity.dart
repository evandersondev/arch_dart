import 'package:equatable/equatable.dart';

final class AuthEntity extends Equatable {
  final String email;
  // final String? passwordHash;

  const AuthEntity({
    required this.email,
    // this.passwordHash,
  });

  @override
  List<Object?> get props => [
        email,
        // passwordHash,
      ];
}
