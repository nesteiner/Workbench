class LoginRequest {
  String username;
  String passwordHash;

  LoginRequest({required this.username, required this.passwordHash});

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "passwordHash": passwordHash
    };
  }
}