import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class AuthState extends ChangeNotifier {
  static const key = "jwt_token";

  bool _logged = false;
  String? _token;
  String? _userName; // <- adiciona isso

  bool get isLoggedIn => _logged;
  String? get token => _token;
  String? get userName => _userName; // <- getter pro UI usar

  AuthState() {
    _loadToken();
  }

  void _loadToken() {
    final storage = web.window.localStorage;
    final stored = storage.getItem(key);

    if (stored != null && stored.isNotEmpty) {
      _token = stored;
      _logged = true;
      // se quiser, poderia decodificar o token e extrair usuário aqui
      _userName = 'Usuário'; // por enquanto fixo
      notifyListeners();
    }
  }

  Future<bool> login(String email, String pass) async {
    if (email.isEmpty || pass.isEmpty) return false;

    final fakeJwt = "FAKE.JWT.TOKEN.${DateTime.now().millisecondsSinceEpoch}";

    final storage = web.window.localStorage;
    storage.setItem(key, fakeJwt);

    _token = fakeJwt;
    _logged = true;
    _userName = email; // <- guarda o e-mail como nome de usuário
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
