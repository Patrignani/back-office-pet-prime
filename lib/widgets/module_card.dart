import 'package:flutter/material.dart';
import '../models/modules/module_get_all.dart';
import 'entity_card.dart';
import '../../core/utils/money_utils.dart';
import '../services/module_service.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_scope.dart';
import '../core/exceptions.dart';

class ModuleCard extends StatefulWidget {
  final ModuleGetAll item;
  final VoidCallback? onPressed;
  final VoidCallback? onMore;
  final String token;

  const ModuleCard({
    super.key,
    required this.item,
    this.onPressed,
    this.onMore,
    required this.token,
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  late bool _activated;
  late ModuleService _service;

  static const Map<bool, Color> _activedColorMap = {
    true: Colors.green,
    false: Colors.redAccent,
  };

  Color _activedColorColor(bool actived) {
    return _activedColorMap[actived] ?? Colors.blueGrey;
  }

  @override
  void initState() {
    super.initState();
    _activated = widget.item.activated;
    _service = ModuleService();
  }

  @override
  Widget build(BuildContext context) {
    final color = _activedColorColor(_activated);

    return EntityCard(
      title: widget.item.name,
      id: widget.item.id,
      statusLabel: _activated ? "Ativo" : "Inativo",
      statusColor: color,
      primaryButtonLabel: 'Ver detalhes',
      infoLines: [
        'Valor: ${formatMoneyToInput(widget.item.value)}',
        'Slug: ${widget.item.slug}',
      ],
      onPressed: widget.onPressed,
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          switch (value) {
            case 'view':
              widget.onPressed?.call();
              break;
            case 'edit':
              widget.onMore?.call();
              break;
            case 'toggle':
              final newActivated = !_activated;
              try {
                await _service.updateNewModule(
                  token: widget.token,
                  id: widget.item.id,
                  name: widget.item.name,
                  slugId: widget.item.slugId,
                  value: widget.item.value,
                  activated: newActivated,
                );

                setState(() {
                  _activated = newActivated;
                });
              } on SessionExpiredException {
                final auth = AuthScope.of(context);
                auth.logout();
                context.go('/login');
                return;
              } catch (e) {
                print('Erro ao atualizar módulo: $e');
              }
              break;
            case 'delete':
              break;
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: 'view',
            child: Text('Ver detalhes'),
          ),
          PopupMenuItem(
            value: 'edit',
            child: Text('Editar módulo'),
          ),
          PopupMenuItem(
            value: 'toggle',
            child: Text('Ativar / Desativar'),
          ),
        ],
      ),
    );
  }
}
