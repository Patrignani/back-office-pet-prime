import 'dart:convert';
import '../config/app_config.dart';
import '../core/http_client.dart'; 

class AuthService {
  static final _base = AppConfig.authUrl;

  static Future<Map<String, dynamic>?> login({
    required String user,
    required String pass,
    required String token,
  }) async {
    final url = Uri.parse("$_base/auth-admin");

    final response = await httpClient.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "2AF": token,
      },
      body: json.encode({
        "grant_type": "password",
        "client_id": AppConfig.clientId,
        "client_secret": AppConfig.clientPass,
        "username": user,
        "password": pass,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return null;
  }
}
