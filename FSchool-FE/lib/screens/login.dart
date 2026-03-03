import 'package:bai1/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();

  Future<void> _handleLogin() async {
    try {
      final response = await _authController.login(
        _phoneController.text.trim(),
        _passwordController.text.trim(),
      );

      print(response.accessToken);

      if (!mounted) return;

      Navigator.pushNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sai tài khoản hoặc mật khẩu")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.only(
            top: 10,
            left: 10,
            bottom: 10,
            right: 10,
          ),
          child: Column(
            children: [
              Column(
                children: [
                  Image(
                    height: 150,
                    image: NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNkwDjcK0EsrsVg_I-HsRnivHuIkBcsfyitw&s',
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("Welcome to FSchool"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        prefix: Icon(Icons.phone),
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 10),

                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        prefix: Icon(Icons.password),
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        suffix: Icon(Icons.remove_red_eye),
                      ),
                    ),

                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot-password',
                                );
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: _handleLogin,

                        child: Text(
                          "Sign In",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
