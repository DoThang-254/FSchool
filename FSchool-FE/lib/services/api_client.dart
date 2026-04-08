import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static Future<Map<String, String>> _getHeaders(Map<String, String>? customHeaders) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    
    return headers;
  }

  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return await http.get(url, headers: await _getHeaders(headers));
  }

  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return await http.post(url, headers: await _getHeaders(headers), body: body, encoding: encoding);
  }

  static Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return await http.put(url, headers: await _getHeaders(headers), body: body, encoding: encoding);
  }

  static Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return await http.delete(url, headers: await _getHeaders(headers), body: body, encoding: encoding);
  }

  static Future<http.MultipartRequest> multipartRequest(String method, Uri url, {Map<String, String>? headers}) async {
    var request = http.MultipartRequest(method, url);
    request.headers.addAll(await _getHeaders(headers));
    return request;
  }
}
