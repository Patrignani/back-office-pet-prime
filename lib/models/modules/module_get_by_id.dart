class ModuleGetById {
  final String id;
  final String name;
  final double value;
  final String slugId;
  final bool activated;
  final DateTime? activatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ModuleGetById({
    required this.id,
    required this.name,
    required this.value,
    required this.slugId,
    required this.activated,
    required this.activatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ModuleGetById.fromJson(Map<String, dynamic> json) {
    final rawValue = json['value'];

    final parsedValue = rawValue is num
        ? rawValue.toDouble()
        : double.tryParse(rawValue.toString()) ?? 0.0;

    return ModuleGetById(
      id: json['id'] as String,
      name: json['name'] as String,
      value: parsedValue,
      slugId: json['slug_id'] as String,
      activated: json['activated'] as bool,
      activatedAt: json['activated_at'] != null
          ? DateTime.parse(json['activated_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
