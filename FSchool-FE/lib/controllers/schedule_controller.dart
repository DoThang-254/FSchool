import 'package:bai1/models/schedule.dart';
import 'package:bai1/services/schedule_service.dart';

class ScheduleController {
  final ScheduleService _scheduleService = ScheduleService();

  Future<List<Schedule>> fetchSchedules({int? classId, int? staffId}) async {
    try {
      return await _scheduleService.getSchedules(classId: classId, staffId: staffId);
    } catch (e) {
      print("Error fetching schedules: $e");
      return [];
    }
  }
}
