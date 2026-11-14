class Account {
  const Account({required this.id, required this.name, required this.email});

  static const demo = Account(id: 'demo', name: '', email: '');

  final String id;
  final String name;
  final String email;

  bool get isDemo => id == demo.id;
}

abstract interface class AuthGateway {
  Account? signIn(String email, String password);
  Account? register(String name, String email, String password);
}
