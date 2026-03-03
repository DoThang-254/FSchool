class AuthResponse {
  final String accessToken;
  final String role;

  AuthResponse({required this.accessToken, required this.role});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(accessToken: json['accessToken'], role: json['role']);
  }
}
