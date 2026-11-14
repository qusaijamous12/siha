import 'package:get/get.dart';

import '../model/account.dart';

class AuthController extends GetxController {
  AuthController(this._gateway);

  final AuthGateway _gateway;
  final account = Rxn<Account>();
  final registering = false.obs;
  final error = RxnString();

  void switchMode() {
    registering.toggle();
    error.value = null;
  }

  void submit({
    required String name,
    required String email,
    required String password,
  }) {
    final address = email.trim().toLowerCase();
    final result = registering.value
        ? _gateway.register(name.trim(), address, password)
        : _gateway.signIn(address, password);
    if (result == null) {
      error.value = registering.value ? 'email_used' : 'invalid_login';
      return;
    }
    _open(result);
  }

  void openDemo() => _open(Account.demo);

  void _open(Account user) {
    error.value = null;
    registering.value = false;
    account.value = user;
  }

  void signOut() => account.value = null;
}
