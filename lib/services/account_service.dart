import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../core/http_client.dart';
import '../core/exceptions.dart';
import '../models/account_get_all.dart';
import '../models/paginator.dart';

class AccountService {
  final http.Client _client;

  AccountService({http.Client? client}) : _client = client ?? httpClient;

  Future<Paginator<AccountGetAll>> getAccounts({
    required String token,
    int page = 1,
    int perPage = 12,
    String? name,
    int? statusId,
    DateTime? createdAt,
    DateTime? statusUpdatedAt,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
      if (name != null && name.isNotEmpty) 'name': name,
      if (statusId != null) 'status_id': '$statusId',
      if (createdAt != null) 'created_at': createdAt.toIso8601String(),
      if (statusUpdatedAt != null)
        'status_updated_at': statusUpdatedAt.toIso8601String(),
    };

    final uri = Uri.parse('${AppConfig.authUrl}/admin/accounts')
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
      throw Exception('Erro ao buscar contas: ${response.statusCode}');
    }

    final Map<String, dynamic> body = jsonDecode(response.body);
    return Paginator.fromJson(
      body,
      (json) => AccountGetAll.fromJson(json),
    );
  }
}
