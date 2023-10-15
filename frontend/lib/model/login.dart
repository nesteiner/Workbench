class Role {
  int id;
  String name;

  Role({
    required this.id,
    required this.name
  });

  static Role fromJson(Map<String, dynamic> json) {
    return Role(
      id: json["id"],
      name: json["name"]
    );
  }
}

class User {
  int id;
  String name;
  List<Role> roles;
  String email;

  User({
    required this.id,
    required this.name,
    required this.roles,
    required this.email
  });

  static User fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      name: json["name"],
      roles: json["roles"].map<Role>((e) => Role.fromJson(e)).toList(),
      email: json["email"]
    );
  }
}