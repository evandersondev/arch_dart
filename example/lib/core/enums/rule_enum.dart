enum RuleEnum {
  admin,
  user,
  guest;

  static RuleEnum? stringToEnum(String value) {
    return switch (value) {
      'admin' => RuleEnum.admin,
      'user' => RuleEnum.user,
      'guest' => RuleEnum.guest,
      _ => null,
    };
  }
}
