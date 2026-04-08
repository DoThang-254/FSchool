import 'dart:async';
import 'package:bai1/models/reset_password_request.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phoneNumber;
  const ResetPasswordScreen({super.key, required this.phoneNumber});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  // Biến cho bộ đếm ngược
  int _timeLeft = 300; // 5 phút khớp với Backend của bạn
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Bắt đầu đếm ngược ngay khi vào màn hình
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy timer khi rời khỏi màn hình để tránh lỗi bộ nhớ
    super.dispose();
  }

  // Hàm đếm ngược thời gian
  void _startTimer() {
    setState(() => _timeLeft = 300);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  // Hàm xử lý nút Resend OTP
  void _handleResendOtp() async {
    setState(() => _isLoading = true);
    try {
      await _authService.sendOtp(widget.phoneNumber);
      _startTimer(); // Gửi thành công thì reset lại bộ đếm 20s
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP has been resent to your email!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Hàm xử lý nút Xác nhận đổi mật khẩu
  void _handleReset() async {
    final otpCode = _otpController.text.trim();
    final newPassword = _passController.text.trim();

    if (otpCode.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both OTP and your new password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = ResetPasswordRequest(
        phoneNumber: widget.phoneNumber,
        otpCode: otpCode,
        newPassword: newPassword,
      );

      bool success = await _authService.resetPassword(request);

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password changed successfully! Please log in again."),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        ); // Đẩy về login, xóa lịch sử
      }
    } catch (e) {
      // NẾU MÃ HẾT HẠN HOẶC SAI, LỖI SẼ HIỆN Ở ĐÂY
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OTP Verification"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 20),
              Text(
                "An OTP code has been sent to the account linked with:\n${widget.phoneNumber}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),

              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.password),
                  labelText: "Enter OTP Code",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _passController,
                obscureText: true, // Ẩn mật khẩu
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: "New Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // Nút xác nhận
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleReset,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Confirm Password Change",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // LOGIC HIỂN THỊ NÚT RESEND OTP THEO THỜI GIAN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive the code? "),
                  _timeLeft > 0
                      ? Text(
                          "Resend in ${(_timeLeft ~/ 60)}:${(_timeLeft % 60).toString().padLeft(2, '0')}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        )
                      : TextButton(
                          onPressed: _isLoading ? null : _handleResendOtp,
                          child: const Text(
                            "Resend Code",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
