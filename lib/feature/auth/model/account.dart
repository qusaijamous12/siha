class Account {
  const Account({required this.id, required this.name, required this.email});

  static const demo = Account(id: 'demo', name: '', email: '');

  final String id;
  final String name;
  final String email;

  bool get isDemo => id == demo.id;
}

abstract interface class AuthGateway {
  Future<Account?> restoreSession();
  Future<void> saveSession(Account? account);
  Future<Account?> signIn(String email, String password);
  Future<Account?> register(String name, String email, String password);
}
