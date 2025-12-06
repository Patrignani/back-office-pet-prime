import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../core/http_client.dart';
import '../core/exceptions.dart';
import '../models/modules_slug/module_slug_get_all.dart';

class ModuleSlugService {
  final http.Client _client;

  ModuleSlugService({http.Client? client}) : _client = client ?? httpClient;

  Future<List<ModuleSlugGetAll>> getModulesSlug({
    required String token,
  }) async {
    final uri = Uri.parse('${AppConfig.authUrl}/admin/modules-slug');

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
      throw Exception('Erro ao buscar módulos: ${response.statusCode}');
    }

    final List<dynamic> body = jsonDecode(response.body);
    return body.map((e) => ModuleSlugGetAll.fromJson(e)).toList();
  }
}
