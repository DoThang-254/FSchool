import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bai1/config/api_config.dart';
import 'package:bai1/models/schedule.dart';

class ScheduleService {
  Future<List<Schedule>> getSchedules({int? classId, int? staffId}) async {
    String url = ApiConfig.getSchedules;
    List<String> params = [];
    if (classId != null) params.add('classId=$classId');
    if (staffId != null) params.add('staffId=$staffId');
    
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => Schedule.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load schedules');
    }
  }

  Future<void> batchSchedule(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/Schedules/batch'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to batch schedule');
    }
  }

  Future<void> createSchedule(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/Schedules'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create schedule');
    }
  }

  Future<void> updateSchedule(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/Schedules/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update schedule');
    }
  }

  Future<void> deleteSchedule(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/Schedules/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete schedule');
    }
  }
}
