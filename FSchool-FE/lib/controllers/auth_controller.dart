import 'package:bai1/models/auth_response.dart';
import 'package:bai1/models/login_request.dart';
import 'package:bai1/services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<AuthResponse> login(String phone, String password) async {
    final request = LoginRequest(username: phone, password: password);

    return await _authService.login(request);
  }
}
