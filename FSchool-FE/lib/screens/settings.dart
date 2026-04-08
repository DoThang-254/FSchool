import 'package:flutter/material.dart';
import 'package:bai1/widgets/custom_bottom_nav_bar.dart';
import 'package:bai1/controllers/auth_controller.dart';
import 'package:bai1/config/api_config.dart';
import 'package:bai1/services/session_manager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthController _authController = AuthController();
  bool _is2faEnabled = false;
  bool _is2faLoading = true;

  dynamic _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args = ModalRoute.of(context)?.settings.arguments ?? SessionManager().user;

    // Lấy trạng thái 2FA hiện tại
    try {
      final accountId = _args?.id;
      if (accountId != null) {
        _fetch2faStatus(accountId);
      } else {
        setState(() => _is2faLoading = false);
      }
    } catch (e) {
      setState(() => _is2faLoading = false);
    }
  }

  Future<void> _fetch2faStatus(int accountId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/Auth/2fa-status?accountId=$accountId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _is2faEnabled = data['twoFactorEnabled'] == true;
            _is2faLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _is2faLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _is2faLoading = false);
    }
  }

  Future<void> _toggle2fa() async {
    final accountId = _args?.id;
    if (accountId == null) return;

    setState(() => _is2faLoading = true);

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/Auth/toggle-2fa?accountId=$accountId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _is2faEnabled = data['twoFactorEnabled'] == true;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: _is2faEnabled ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _is2faLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // User Section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _args?.fullName ?? 'User Name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Role: ${_args?.role ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_args?.role == 'Student')
                          Text(
                            'Roll Number: ${_args?.rollNumber ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        if (_args?.role == 'Staff' || _args?.role == 'Admin') ...[
                          if (_args?.employeeId != null)
                            Text(
                              'Employee ID: ${_args?.employeeId}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          if (_args?.department != null)
                            Text(
                              'Department: ${_args?.department}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),

            // === 2FA Toggle ===
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: _is2faEnabled ? Colors.green.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _is2faEnabled ? Colors.green.shade200 : Colors.grey.shade200,
                ),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.security,
                  color: _is2faEnabled ? Colors.green : Colors.grey,
                ),
                title: const Text(
                  'Two-Factor Authentication',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _is2faEnabled
                      ? 'OTP will be sent via email for each login'
                      : 'Enable to increase account security',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: _is2faLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: _is2faEnabled,
                        activeColor: Colors.green,
                        onChanged: (value) => _toggle2fa(),
                      ),
              ),
            ),

            const SizedBox(height: 4),

            _buildSettingsItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature not implemented yet')),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.notifications_none,
              title: 'Notifications',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'About App',
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _authController.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'LOGOUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        args: _args,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
