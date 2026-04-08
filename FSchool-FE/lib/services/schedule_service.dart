import 'package:bai1/services/api_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bai1/config/api_config.dart';
import 'package:bai1/models/schedule.dart';

class ScheduleService {
  /// Lấy lịch theo khoảng ngày [fromDate, toDate]
  /// API trả về { fromDate, toDate, schedules: [...] }
  Future<Map<String, dynamic>> getSchedulesByDateRange({
    int? classId,
    int? staffId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    String url = ApiConfig.getSchedules;
    List<String> params = [];

    params.add('fromDate=${_formatDate(fromDate)}');
    params.add('toDate=${_formatDate(toDate)}');
    if (classId != null) params.add('classId=$classId');
    if (staffId != null) params.add('staffId=$staffId');

    url += '?${params.join('&')}';

    final response = await ApiClient.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List<dynamic> schedulesJson = body['schedules'] ?? [];
      final schedules = schedulesJson.map((m) => Schedule.fromJson(m)).toList();

      return {
        'fromDate': body['fromDate'],
        'toDate': body['toDate'],
        'schedules': schedules,
      };
    } else {
      throw Exception('Failed to load schedules');
    }
  }

  /// Lấy lịch (backward-compatible, dùng cho các chỗ cũ nếu cần)
  Future<List<Schedule>> getSchedules({int? classId, int? staffId}) async {
    // Tăng khoảng thời gian lấy lịch để thấy được nhiều buổi học hơn
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 30));
    final to = now.add(const Duration(days: 180));

    final result = await getSchedulesByDateRange(
      classId: classId,
      staffId: staffId,
      fromDate: from,
      toDate: to,
    );
    return result['schedules'] as List<Schedule>;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<String> batchSchedule(Map<String, dynamic> data) async {
    final response = await ApiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/Schedules/batch'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['message'] ?? 'Xếp lịch thành công';
    } else {
      String errorMessage = 'Lỗi khi xếp lịch hàng loạt';
      try {
        final body = json.decode(response.body);
        if (body is Map && body.containsKey('message')) {
          errorMessage = body['message'];
        } else if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> createSchedule(Map<String, dynamic> data) async {
    final response = await ApiClient.post(
      Uri.parse('${ApiConfig.baseUrl}/Schedules'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      String errorMessage = 'Lỗi khi tạo lịch học';
      try {
        // Handle both simple strings and JSON objects with message property
        if (response.body.startsWith('{')) {
          final body = json.decode(response.body);
          errorMessage = body['message'] ?? errorMessage;
        } else {
          errorMessage = response.body;
        }
      } catch (_) {
        errorMessage = response.body;
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> updateSchedule(int id, Map<String, dynamic> data) async {
    final response = await ApiClient.put(
      Uri.parse('${ApiConfig.baseUrl}/Schedules/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      String errorMessage = 'Lỗi khi cập nhật lịch học';
      try {
        if (response.body.startsWith('{')) {
          final body = json.decode(response.body);
          errorMessage = body['message'] ?? errorMessage;
        } else {
          errorMessage = response.body;
        }
      } catch (_) {
        errorMessage = response.body;
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> deleteSchedule(int id) async {
    final response = await ApiClient.delete(
      Uri.parse('${ApiConfig.baseUrl}/Schedules/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete schedule');
    }
  }
}
