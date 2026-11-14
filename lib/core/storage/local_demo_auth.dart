import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../feature/auth/model/account.dart';

class LocalDemoAuth implements AuthGateway {
  const LocalDemoAuth(this._storage);

  final FlutterSecureStorage _storage;
  static const _sessionKey = 'demo-session.v1';

  String _key(String email) =>
      'demo-account.v1.${sha256.convert(utf8.encode(email))}';

  @override
  Future<Account?> restoreSession() async {
    final id = await _storage.read(key: _sessionKey);
    if (id == null) return null;
    if (id == Account.demo.id) return Account.demo;
    final record = await _readAccount(id);
    return record == null
        ? null
        : Account(id: id, name: record['name'] as String, email: id);
  }

  @override
  Future<void> saveSession(Account? account) => account == null
      ? _storage.delete(key: _sessionKey)
      : _storage.write(key: _sessionKey, value: account.id);

  Future<Map<String, dynamic>?> _readAccount(String email) async {
    final saved = await _storage.read(key: _key(email));
    return saved == null ? null : jsonDecode(saved) as Map<String, dynamic>;
  }

  @override
  Future<Account?> register(String name, String email, String password) async {
    final key = _key(email);
    if (await _storage.read(key: key) != null) return null;

    final random = Random.secure();
    final salt = base64Url.encode(
      List.generate(16, (_) => random.nextInt(256)),
    );
    await _storage.write(
      key: key,
      value: jsonEncode({
        'name': name,
        'salt': salt,
        'digest': _digest(salt, password),
      }),
    );
    return Account(id: email, name: name, email: email);
  }

  @override
  Future<Account?> signIn(String email, String password) async {
    final record = await _readAccount(email);
    if (record == null) return null;
    if (record['digest'] != _digest(record['salt'] as String, password)) {
      return null;
    }
    return Account(id: email, name: record['name'] as String, email: email);
  }

  String _digest(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
}
