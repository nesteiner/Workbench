import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:frontend/model/login.dart';

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

class PostUserRequest {
  final String name;
  final List<Role> roles;
  final String email;
  String password;

  PostUserRequest({required this.name, required this.roles, required this.email, required this.password});

  Map<String, dynamic> toJson() {
    final passwordHash = md5.convert(utf8.encode(password)).toString();
    return {
      "name": name,
      "roles": roles.map((e) => e.toJson()).toList(),
      "email": email,
      "enabled": true,
      "passwordHash": passwordHash
    };
  }
}