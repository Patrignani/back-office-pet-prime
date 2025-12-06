class ModuleGetAll {
  final String id;
  final String name;
  final double value;
  final String slug;
  final bool activated;
  final String slugId;

  ModuleGetAll({
    required this.id,
    required this.name,
    required this.value,
    required this.slug,
    required this.activated,
    required this.slugId,
  });

  factory ModuleGetAll.fromJson(Map<String, dynamic> json) {
    return ModuleGetAll(
      id: json['id'],
      name: json['name'],
      value: double.parse(json['value']),
      slug: json['slug'],
      activated: json['activated'],
      slugId: json['slug_id'],
    );
  }
}
