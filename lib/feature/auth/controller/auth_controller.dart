import 'package:get/get.dart';

import '../model/account.dart';

class AuthController extends GetxController {
  AuthController(this._gateway);

  final AuthGateway _gateway;
  final account = Rxn<Account>();
  final registering = false.obs;
  final restoring = true.obs;
  final busy = false.obs;
  final error = RxnString();

  Future<void> restoreSession() async {
    try {
      final restored = await _gateway.restoreSession();
      if (!isClosed) account.value = restored;
    } on Exception {
      if (!isClosed) error.value = 'auth_storage_error';
    } finally {
      if (!isClosed) restoring.value = false;
    }
  }

  void switchMode() {
    if (busy.value) return;
    registering.toggle();
    error.value = null;
  }

  Future<void> submit({
    required String name,
    required String email,
    required String password,
  }) => _perform(() async {
    final address = email.trim().toLowerCase();
    final result = registering.value
        ? await _gateway.register(name.trim(), address, password)
        : await _gateway.signIn(address, password);
    if (isClosed) return;
    if (result == null) {
      error.value = registering.value ? 'email_used' : 'invalid_login';
    } else {
      await _open(result);
    }
  });

  Future<void> openDemo() => _perform(() => _open(Account.demo));

  Future<void> _open(Account user) async {
    await _gateway.saveSession(user);
    if (isClosed) return;
    registering.value = false;
    account.value = user;
  }

  Future<void> signOut() => _perform(() async {
    await _gateway.saveSession(null);
    if (!isClosed) account.value = null;
  });

  Future<void> _perform(Future<void> Function() action) async {
    if (busy.value || restoring.value) return;
    busy.value = true;
    error.value = null;
    try {
      await action();
    } on Exception {
      if (!isClosed) error.value = 'auth_storage_error';
    } finally {
      if (!isClosed) busy.value = false;
    }
  }
}
