import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/Comment.dart';

class CommentService {
  //final String baseUrl = 'http://10.0.2.2:8080/api/comments';
  final String baseUrl = 'http://192.168.2.4:8080/api/comments';
  // Lấy ID người dùng từ SharedPreferences
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }

  // Thêm bình luận mới
  Future<Comment> addComment(Map<String, dynamic> commentData) async {
    String accountId = await getUserId();
    if (accountId.isEmpty) {
      throw Exception('Account ID cannot be empty.');
    }

    commentData['account'] = {'id': accountId}; // Thêm ID người dùng vào dữ liệu bình luận

    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(commentData),
    );

    if (response.statusCode == 200) {
      return Comment.fromJson(jsonDecode(utf8.decode(response.bodyBytes))); // Giải mã UTF-8
    } else {
      throw Exception('Failed to add comment: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // Lấy tất cả bình luận cho một bài hát
  Future<List<Comment>> getCommentsBySongId(String songId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/song/$songId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> commentsJson = jsonDecode(utf8.decode(response.bodyBytes)); // Giải mã UTF-8
      return commentsJson.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // Xóa bình luận
  Future<void> deleteComment(String commentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$commentId'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete comment: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // Lấy tổng số bình luận cho một bài hát
  Future<int> getCommentCountBySongId(String songId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/song/$songId/count'),
    );

    if (response.statusCode == 200) {
      // Giải mã UTF-8 và chuyển đổi từ JSON
      String responseBody = utf8.decode(response.bodyBytes);
      return int.parse(responseBody); // Chuyển đổi sang int
    } else {
      throw Exception('Failed to load comment count: ${response.statusCode}, Body: ${response.body}');
    }
  }
}