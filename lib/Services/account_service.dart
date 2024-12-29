import 'dart:convert';
import 'package:http/http.dart' as http;

class AccountService {
  final String baseUrl = 'http://10.0.2.2:8080/api/accounts'; // Sử dụng baseUrl từ config.dart
  // final String cloudinaryUrl = cloudinaryUrl;

  // Hàm loại bỏ dấu tiếng Việt
  String removeDiacritics(String text) {
    const vietnamese = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
        'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    const without = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd'
        'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';

    for (int i = 0; i < vietnamese.length; i++) {
      text = text.replaceAll(vietnamese[i], without[i]);
    }

    return text;
  }

  // Tạo tài khoản
  Future<Map<String, dynamic>> createAccount(
      Map<String, dynamic> accountData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(accountData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Lỗi đăng ký: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến API: $e');
    }
  }
}