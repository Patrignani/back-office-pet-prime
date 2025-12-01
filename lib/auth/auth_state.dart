import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import '../services/auth.dart';

class AuthState extends ChangeNotifier {
  static const key = "jwt_token";

  bool _logged = false;
  String? _token;
  String? _userName;

  bool get isLoggedIn => _logged;
  String? get token => _token;
  String? get userName => _userName;

  AuthState() {
    _loadToken();
  }

  void _loadToken() {
    final storage = web.window.localStorage;
    final stored = storage.getItem(key);

    if (stored != null && stored.isNotEmpty) {
      _token = stored;
      _logged = true;
      _userName = 'Usuário';
      notifyListeners();
    }
  }

  Future<bool> login(String user, String pass, String token) async {
    final response = await AuthService.login(
      user: user,
      pass: pass,
      token: token,
    );

    if (response == null) return false;

    final jwt = response["access_token"];

    final storage = web.window.localStorage;
    storage.setItem(key, jwt);

    _token = jwt;
    _userName = user;
    _logged = true;
    notifyListeners();

    return true;
  }

  void logout() {
    final storage = web.window.localStorage;
    storage.removeItem(key);

    _token = null;
    _userName = null;
    _logged = false;
    notifyListeners();
  }
}
