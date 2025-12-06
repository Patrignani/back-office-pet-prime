import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../core/http_client.dart';
import '../core/exceptions.dart';
import '../models/modules/module_get_all.dart';
import '../models/modules/module_get_by_id.dart';
import '../models/paginator.dart';

class ModuleService {
  final http.Client _client;

  ModuleService({http.Client? client}) : _client = client ?? httpClient;

  Future<Paginator<ModuleGetAll>> getModules({
    required String token,
    int page = 1,
    int perPage = 12,
    String? name,
    String? slug,
    bool? activated,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
      if (name != null && name.isNotEmpty) 'name': name,
      if (slug != null) 'slug': '$slug',
      if (activated != null) 'activated': activated.toString(),
    };

    final uri = Uri.parse('${AppConfig.authUrl}/admin/modules')
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
      (json) => ModuleGetAll.fromJson(json),
    );
  }

  Future<ModuleGetById> getModulesId({
    required String token,
    required String id,
  }) async {
    final uri = Uri.parse('${AppConfig.authUrl}/admin/modules/${id}');

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
    return ModuleGetById.fromJson(body);
  }

  Future<ModuleGetById> saveNewModule({
    required String token,
    required String name,
    required String slugId,
    required double value,
    required bool activated,
  }) async {
    final uri = Uri.parse('${AppConfig.authUrl}/admin/modules');

    final body = jsonEncode({
      'name': name,
      'value': value,
      'slug_id': slugId.toString(),
      'activated': activated,
    });

    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw SessionExpiredException();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erro ao criar módulo: ${response.statusCode} - ${response.body}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    return ModuleGetById.fromJson(json);
  }

  Future<ModuleGetById> updateNewModule({
    required String token,
    required String id,
    required String name,
    required String slugId,
    required double value,
    required bool activated,
  }) async {
    final uri = Uri.parse('${AppConfig.authUrl}/admin/modules/${id}');

    final body = jsonEncode({
      'name': name,
      'value': value,
      'slug_id': slugId.toString(),
      'activated': activated,
    });

    final response = await _client.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw SessionExpiredException();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erro ao atualizar módulo: ${response.statusCode} - ${response.body}',
      );
    }

    final Map<String, dynamic> json = jsonDecode(response.body);
    return ModuleGetById.fromJson(json);
  }
}
