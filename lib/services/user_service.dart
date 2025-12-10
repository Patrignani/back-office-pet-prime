import 'dart:convert';
import 'package:back_office/models/users/users_get_all.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../core/http_client.dart';
import '../core/exceptions.dart';
import '../models/paginator.dart';

class UserService {
  final http.Client _client;

  UserService({http.Client? client}) : _client = client ?? httpClient;

  Future<Paginator<UserGetAll>> getUsers({
    required String token,
    int page = 1,
    int perPage = 12,
    String? name,
    String? email,
    String? userName,
    String? accountName,
    bool? controlModule,
    bool? twoFactory,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
      if (name != null && name.isNotEmpty) 'name': name,
      if (email != null) 'email': '$email',
      if (userName != null) 'user_name': '$userName',
      if (accountName != null) 'account_name': '$accountName',
      if (controlModule != null) 'control_module': controlModule.toString(),
      if (twoFactory != null) 'two_factory': twoFactory.toString(),
    };

    final uri = Uri.parse('${AppConfig.authUrl}/admin/users')
        .replace(queryParameters: query);

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw SessionExpiredException();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao buscar Modulos: ${response.statusCode}');
    }

    final Map<String, dynamic> body = jsonDecode(response.body);
    return Paginator.fromJson(
      body,
      (json) => UserGetAll.fromJson(json),
    );
  }
}
