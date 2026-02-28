import 'package:bai1/screens/clubs-details.dart';
import 'package:bai1/screens/clubs.dart';
import 'package:bai1/screens/create-report.dart';
import 'package:bai1/screens/event-details.dart';
import 'package:bai1/screens/events.dart';
import 'package:bai1/screens/forgot-password.dart';
import 'package:bai1/screens/home.dart';
import 'package:bai1/screens/login.dart';
import 'package:bai1/screens/mark-report.dart';
import 'package:bai1/screens/report.dart';
import 'package:bai1/screens/schedule.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/login',

      routes: {
        '/login': (context) => LoginScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/home': (context) => Home(),
        "/mark-report": (context) => MarkReportScreen(),
        "/schedule": (context) => ScheduleScreen(),
        "/report": (context) => ReportScreen(),
        "/create-report": (context) => CreateReportScreen(),
        "/events": (context) => EventsScreen(),
        "/event-details": (context) => EventDetailScreen(
          event:
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
        ),
        "/clubs": (context) => ClubsScreen(),
        "/club-details": (context) => ClubDetailScreen(
          club:
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>,
        ),
      },
    );
  }
}
