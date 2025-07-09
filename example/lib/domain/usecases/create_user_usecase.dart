class CreateUserUsecase {
  Future<void> execute(String name, String email) async {
    // Lógica para criar um usuário
    print('Usuário criado: $name, Email: $email');
  }
}
