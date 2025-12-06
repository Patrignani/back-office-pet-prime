import 'package:flutter/material.dart';
import '../models/account_get_all.dart';
import 'entity_card.dart';

class AccountCard extends StatelessWidget {
  final AccountGetAll item;
  final VoidCallback? onPressed;
  final VoidCallback? onMore;

  const AccountCard({
    super.key,
    required this.item,
    this.onPressed,
    this.onMore,
  });

  static const Map<int, Color> _statusColorMap = {
    1: Colors.green,
    2: Colors.redAccent,
    3: Colors.orange,
    4: Colors.purple,
  };

  Color _statusColor(int id) {
    return _statusColorMap[id] ?? Colors.blueGrey;
  }

  String _format(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.statusId);

    return EntityCard(
      title: item.name,
      id: item.id,
      statusLabel: item.statusSlug,
      statusColor: color,
      primaryButtonLabel: 'Ver detalhes',
      infoLines: [
        'Criado em: ${_format(item.createdAt)}',
        'Status atualizado: ${_format(item.updatedStatus)}',
        'Última atualização: ${_format(item.updatedAt)}',
      ],
      onPressed: onPressed,
      onMore: onMore,
    );
  }
}
