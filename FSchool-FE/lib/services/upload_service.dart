import 'package:bai1/services/api_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bai1/config/api_config.dart';
import 'package:image_picker/image_picker.dart';

class UploadService {
  Future<String?> uploadImage(XFile imageFile) async {
    try {
      var request = await ApiClient.multipartRequest('POST', Uri.parse(ApiConfig.uploadImage));
      
      final bytes = await imageFile.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      );
      
      request.files.add(multipartFile);
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['imageUrl'];
      }
      return null;
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }
}
