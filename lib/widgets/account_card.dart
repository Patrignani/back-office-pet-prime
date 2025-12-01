import 'package:flutter/material.dart';
import '../models/account_get_all.dart';

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
    return "$d/$m/$y";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(item.statusId);

    return Card(
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Mais ações',
                            onPressed: onMore,
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "ID: ${item.id}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 8, color: color),
                            const SizedBox(width: 6),
                            Text(
                              item.statusSlag,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Criado em: ${_format(item.createdAt)}",
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        "Status atualizado: ${_format(item.updatedStatus)}",
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        "Última atualização: ${_format(item.updatedAt)}",
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onPressed,
                  child: const Text(
                    "Ver detalhes",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
