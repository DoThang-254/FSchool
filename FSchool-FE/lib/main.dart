import 'package:bai1/screens/club_details.dart';
import 'package:bai1/screens/clubs.dart';
import 'package:bai1/screens/create_report.dart';
import 'package:bai1/screens/event_details.dart';
import 'package:bai1/screens/events.dart';
import 'package:bai1/screens/forgot_password.dart';
import 'package:bai1/screens/home.dart';
import 'package:bai1/screens/login.dart';
import 'package:bai1/screens/mark_report.dart';
import 'package:bai1/screens/report.dart';
import 'package:bai1/screens/schedule.dart';
import 'package:bai1/screens/settings.dart';
import 'package:bai1/screens/table_app.dart';
import 'package:bai1/screens/admin_account_screen.dart';
import 'package:bai1/screens/course_registration_screen.dart';
import 'package:bai1/screens/class_assignment_screen.dart';
import 'package:bai1/screens/manage_grades_screen.dart';
import 'package:bai1/screens/manage_events_screen.dart';
import 'package:bai1/screens/manage_absence_requests_screen.dart';
import 'package:bai1/screens/manage_clubs_screen.dart';
import 'package:bai1/screens/manage_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bai1/models/auth_response.dart';
import 'dart:convert';
import 'package:bai1/services/session_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager().loadSession();

  runApp(MyApp(initialUser: SessionManager().user));
}

class MyApp extends StatelessWidget {
  final AuthResponse? initialUser;

  const MyApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialUser != null ? '/home' : '/login',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          primary: Colors.orange,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const RoleGuard(
          roles: ['student', 'admin', 'staff'],
          child: Home(),
        ),
        "/mark_report": (context) => RoleGuard(
          roles: const ['student', 'staff', 'admin'],
          child: MarkReportScreen(),
        ),
        "/manage_grades": (context) =>
            RoleGuard(roles: const ['admin'], child: ManageGradesScreen()),
        "/schedule": (context) => RoleGuard(
          roles: const ['student', 'staff', 'admin'],
          child: ScheduleScreen(),
        ),
        "/report": (context) =>
            RoleGuard(roles: const ['student', 'admin'], child: ReportScreen()),
        "/create_report": (context) => RoleGuard(
          roles: const ['student', 'admin'],
          child: CreateReportScreen(),
        ),
        "/events": (context) =>
            RoleGuard(roles: const ['student', 'admin'], child: EventsScreen()),
        "/event_details": (context) => EventDetailScreen(
          event:
              (ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?) ??
              {},
        ),
        "/clubs": (context) =>
            RoleGuard(roles: const ['student', 'admin'], child: ClubsScreen()),
        "/club_details": (context) => ClubDetailScreen(
          club:
              (ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?) ??
              {},
        ),
        "/schedule_table": (context) => const TableApp(),
        "/settings": (context) => const RoleGuard(
          roles: ['student', 'staff', 'admin'],
          child: SettingsScreen(),
        ),
        "/admin_account": (context) =>
            const RoleGuard(roles: ['admin'], child: AdminAccountScreen()),
        "/course_registration": (context) => CourseRegistrationScreen(
          studentId: (ModalRoute.of(context)?.settings.arguments as int?) ?? 0,
        ),
        "/class_assignment": (context) =>
            const RoleGuard(roles: ['admin'], child: ClassAssignmentScreen()),
        "/manage_events": (context) =>
            const RoleGuard(roles: ['admin'], child: ManageEventsScreen()),
        "/manage_clubs": (context) =>
            const RoleGuard(roles: ['admin'], child: ManageClubsScreen()),
        "/manage_absences": (context) => const RoleGuard(
          roles: ['staff', 'admin'],
          child: ManageAbsenceRequestsScreen(),
        ),
        "/manage_schedule": (context) =>
            const RoleGuard(roles: ['admin'], child: ManageScheduleScreen()),
      },
    );
  }
}

class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<String> roles; // empty list means ANY logged-in user

  const RoleGuard({super.key, required this.child, this.roles = const []});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );

        final prefs = snapshot.data!;
        final userInfoStr = prefs.getString('user_info');

        if (userInfoStr == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        try {
          final userInfo = jsonDecode(userInfoStr);
          final roleStr = (userInfo['role'] ?? '').toString().toLowerCase();
          final userRoles = roleStr.split(',').map((e) => e.trim()).toList();

          bool hasAccess =
              roles.isEmpty; // If no roles specified, just check login
          for (var r in roles) {
            if (userRoles.contains(r.toLowerCase())) {
              hasAccess = true;
              break;
            }
          }

          if (!hasAccess) {
            return const Scaffold(
              body: Center(
                child: Text(
                  'Access Denied: You do not have permission to view this page.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          }

          return child;
        } catch (e) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
