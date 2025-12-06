class ModuleSlugGetAll {
  final String id;
  final String name;


  ModuleSlugGetAll({
    required this.id,
    required this.name,
  });

  factory ModuleSlugGetAll.fromJson(Map<String, dynamic> json) {
    return ModuleSlugGetAll(
      id: json['id'],
      name: json['slug'],
    );
  }
}
