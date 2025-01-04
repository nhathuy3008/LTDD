import 'dart:convert';
import 'package:http/http.dart' as http;

class VerifyService {
  final String baseUrl = 'http://192.168.2.4:8080';

  Future<bool> verifyAccount(String code, String email) async {
    final response = await http.get(Uri.parse('$baseUrl/verify?code=$code&email=$email'));

    if (response.statusCode == 200) {
      // Xử lý phản hồi nếu thành công
      print('Xác thực thành công!');
      return true; // Hoặc xử lý dữ liệu nếu cần
    } else {
      // Xử lý lỗi
      print('Có lỗi xảy ra: ${response.body}');
      return false;
    }
  }
}