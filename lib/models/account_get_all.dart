class AccountGetAll {
  final String id;
  final String name;
  final int statusId;
  final String statusSlug;
  final DateTime updatedStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountGetAll({
    required this.id,
    required this.name,
    required this.statusId,
    required this.statusSlug,
    required this.updatedStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountGetAll.fromJson(Map<String, dynamic> json) {
    return AccountGetAll(
      id: json['id'],
      name: json['name'],
      statusId: json['status_id'],
      statusSlug: json['status_slug'],
      updatedStatus: DateTime.parse(json['updated_status']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
