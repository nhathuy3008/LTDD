import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AccountService {
  final String baseUrl = 'http://192.168.2.4:8080/api/accounts';

  // Tải hình ảnh từ URL và lưu vào file tạm thời
  Future<File> downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/temp_image.jpg');

    await file.writeAsBytes(bytes);
    return file;
  }

  // Hàm xử lý phản hồi từ API
  Future<dynamic> handleResponse(http.Response response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(utf8.decode(response.bodyBytes)); // Giải mã UTF-8
    } else {
      print('Error from API: ${response.statusCode} - ${response.body}');
      throw Exception('Error: ${response.body}');
    }
  }

  // Tạo tài khoản
  Future<Map<String, dynamic>> createAccount(Map<String, dynamic> accountData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode(accountData),
      );

      final responseBody = await handleResponse(response);

      // Đảm bảo phản hồi chứa trường success
      if (responseBody['success'] == null) {
        responseBody['success'] = false; // Thiết lập mặc định nếu không có
      }

      return responseBody;
    } catch (e) {
      print('Connection error: $e');
      throw Exception('Cannot connect to API: $e');
    }
  }

  // Lấy tất cả tài khoản
  Future<List<dynamic>> getAllAccounts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      return await handleResponse(response);
    } catch (e) {
      throw Exception('Cannot connect to API: $e');
    }
  }

  // Lấy tài khoản theo ID
  Future<Map<String, dynamic>> getAccountById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));
      return await handleResponse(response);
    } catch (e) {
      throw Exception('Cannot connect to API: $e');
    }
  }

  // Cập nhật tài khoản
  Future<Map<String, dynamic>> updateAccount(String id, Map<String, dynamic> accountData, String? imagePath) async {
    if (accountData.isEmpty) {
      throw Exception('Dữ liệu cập nhật không được để trống.');
    }

    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/$id'));
      request.headers['Content-Type'] = 'application/json; charset=utf-8'; // Đảm bảo mã hóa

      // Thêm dữ liệu vào request
      request.fields['fullName'] = accountData['fullName'];

      // Chỉ thêm mật khẩu nếu người dùng muốn thay đổi
      if (accountData['password'] != null && accountData['password'].isNotEmpty) {
        request.fields['password'] = accountData['password'];
      }

      // Thêm file hình ảnh nếu có
      if (imagePath != null) {
        // Nếu imagePath là URL, tải về trước
        if (imagePath.startsWith('http')) {
          File imageFile = await downloadImage(imagePath);
          imagePath = imageFile.path; // Cập nhật đường dẫn
        }
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      return json.decode(responseBody);
    } catch (e) {
      print('Connection error: $e');
      throw Exception('Cannot connect to API: $e');
    }
  }

  // Xóa tài khoản
  Future<Map<String, dynamic>> deleteAccount(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return await handleResponse(response);
    } catch (e) {
      throw Exception('Cannot connect to API: $e');
    }
  }

  // Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login?email=$email&password=$password'),
        headers: {'Content-Type': 'application/json; charset=utf-8'}, // Đảm bảo mã hóa
      );

      return await handleResponse(response);
    } catch (e) {
      throw Exception('Cannot connect to API: $e');
    }
  }

  // Xác thực mật khẩu
  Future<Map<String, dynamic>> validatePassword(String id, String oldPassword) async {
    try {
      final uri = Uri.parse('$baseUrl/validate-password?id=$id&oldPassword=$oldPassword');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      // Ghi lại phản hồi
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return await handleResponse(response);
    } catch (e) {
      throw Exception('Cannot connect to API: $e');
    }
  }

  // Lấy tổng số người dùng
  Future<int> getTotalUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/total'));
      return await handleResponse(response);
    } catch (e) {
      throw Exception('Cannot connect to API: $e');
    }
  }
}