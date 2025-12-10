import 'package:flutter/material.dart';
import '../models/users/users_get_all.dart';
import 'entity_card.dart';

class UserCard extends StatefulWidget {
  final UserGetAll item;
  final VoidCallback? onPressed;
  final VoidCallback? onMore;
  final String token;

  const UserCard({
    super.key,
    required this.item,
    this.onPressed,
    this.onMore,
    required this.token,
  });

  @override
  State<UserCard> createState() => _userCardState();
}

class _userCardState extends State<UserCard> {
  late bool _controlModule;

  static const Map<bool, Color> _controlModuleColorMap = {
    false: Colors.green,
    true: Colors.blue,
  };

  Color _controlModuleColor(bool controlModule) {
    return _controlModuleColorMap[controlModule] ?? Colors.blueGrey;
  }

  @override
  void initState() {
    super.initState();
    _controlModule = widget.item.controlModule;
  }

  @override
  Widget build(BuildContext context) {
    final color = _controlModuleColor(_controlModule);

    return EntityCard(
      title: widget.item.userName,
      id: widget.item.id,
      statusLabel: _controlModule ? "Administrador" : "Usuário",
      statusColor: color,
      primaryButtonLabel: 'Ver detalhes',
      infoLines: [
        'Email: ${widget.item.email}',
        'Nome: ${widget.item.name}',
        'Nome da conta: ${widget.item.accountName}',
        'Autenticação de dois fatores: ${widget.item.twoFactory ? "Sim" : "Não"}',
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
