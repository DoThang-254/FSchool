import 'dart:convert';

import 'package:bai1/config/api_config.dart';
import 'package:bai1/models/auth_response.dart';
import 'package:bai1/models/login_request.dart';

import 'package:http/http.dart' as http;

class AuthService {
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } else {
      throw Exception("Login failed");
    }
  }
}
