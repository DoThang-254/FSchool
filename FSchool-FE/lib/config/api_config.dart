class ApiConfig {
  static const String baseUrl = "https://localhost:7221/api";

  // Auth endpoints
  static const String login = "$baseUrl/Auth/login";

  // User endpoints
  static const String getProfile = "$baseUrl/users/profile";
}
