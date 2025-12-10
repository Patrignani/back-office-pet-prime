class UserGetAll {
  final String id;
  final String name;
  final String email;
  final String accountName;
  final String userName;
  final bool controlModule;
  final bool twoFactory;

  UserGetAll({
    required this.id,
    required this.name,
    required this.email,
    required this.accountName,
    required this.userName,
    required this.controlModule,
    required this.twoFactory,
  });

  factory UserGetAll.fromJson(Map<String, dynamic> json) {
    return UserGetAll(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      accountName: json['account_name_id'],
      userName: json['user_name'],
      controlModule: json['control_module'],
      twoFactory: json['two_factory'],
    );
  }
}
