import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
class AccountService {
  final String baseUrl = 'http://10.0.2.2:8080/api/accounts'; // Sử dụng baseUrl từ config.dart
  // final String cloudinaryUrl = cloudinaryUrl;
  //final String baseUrl = 'http://localhost:8080/api/accounts';

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

  // Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login?email=$email&password=$password'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Lỗi đăng nhập: ${response.body}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến API: $e');
    }
  }

  //cập nhật tài khoản
  Future<Map<String, dynamic>> updateAccount(String id, Map<String, dynamic> accountData, [File? imageFile]) async {
    if (accountData.isEmpty) {
      throw Exception('Dữ liệu cập nhật không được để trống.');
    }

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/$id'),
      );

      // Thêm các trường dữ liệu vào request
      request.fields['fullName'] = accountData['fullName'] ?? '';
      request.fields['password'] = accountData['password'] ?? '';

      // Thêm tệp hình ảnh nếu có
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image', // Tên trường phải trùng với tên trong backend
          imageFile.path,
        ));
      }

      // Gửi request
      final response = await request.send();

      // Xử lý phản hồi
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return json.decode(responseBody);
      } else {
        throw Exception('Lỗi cập nhật tài khoản: ${response.statusCode} - ${await response.stream.bytesToString()}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến API: $e');
    }
  }
}