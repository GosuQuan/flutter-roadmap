import 'dart:convert';
import 'dart:math' show min;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class User {
  final String id;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class AuthService {
  // 确保包含 /api 前缀
  static const String baseUrl = 'http://localhost:3000/api';
  static String? _authToken;  // 添加静态token变量

  // 获取token的getter
  static String? get authToken => _authToken;

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  final _prefs = SharedPreferences.getInstance();

  User? get currentUser => _currentUser;

  Future<void> initialize() async {
    final prefs = await _prefs;
    final userEmail = prefs.getString('user_email');
    final userId = prefs.getString('user_id');
    if (userEmail != null && userId != null) {
      _currentUser = User(email: userEmail, id: userId, createdAt: DateTime.now(), updatedAt: DateTime.now());
    }
  }

  Future<User> login(String email, String password) async {
    try {
      print('开始登录请求: $email'); // 调试日志
      final url = Uri.parse('$baseUrl/auth/login');
      print('请求URL: $url'); // 打印完整URL
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Client-Type': 'mobile',  // 添加客户端标识
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('收到响应状态码: ${response.statusCode}'); // 状态码日志
      print('响应头: ${response.headers}'); // 添加响应头信息
      print(
          '响应体: ${utf8.decode(response.bodyBytes).substring(0, min(500, utf8.decode(response.bodyBytes).length))}'); // 限制响应体长度

      if (response.headers['content-type']?.contains('text/html') ?? false) {
        throw AuthException('服务器返回了HTML而不是JSON响应，请检查API路由配置');
      }

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(utf8.decode(response.bodyBytes));
          // 保存认证令牌
          _authToken = response.headers['set-cookie']?.split(';').first;
          // 直接从 responseData 中获取 user 对象
          if (responseData['user'] != null) {
            final user = User.fromJson(responseData['user']);
            _currentUser = user;
            final prefs = await _prefs;
            await prefs.setString('user_email', user.email);
            await prefs.setString('user_id', user.id);
            return user;
          } else {
            throw AuthException('响应中缺少用户数据');
          }
        } on FormatException catch (e) {
          print('JSON解析错误: $e');
          throw AuthException('服务器响应格式错误: ${e.toString()}');
        }
      } else {
        var errorMessage = '登录失败: ${response.statusCode}';
        try {
          final responseData = json.decode(utf8.decode(response.bodyBytes));
          errorMessage = responseData['error'] ?? errorMessage;
        } catch (_) {
          // 如果无法解析JSON，使用默认错误信息
        }
        throw AuthException(errorMessage, statusCode: response.statusCode);
      }
    } on http.ClientException catch (e) {
      print('网络错误: $e');
      throw AuthException('网络连接失败，请检查网络设置');
    } catch (e) {
      print('登录错误: $e');
      if (e is AuthException) rethrow;
      throw AuthException('登录失败: $e');
    }
  }

  Future<void> register(String email, String password) async {
    try {
      print('开始注册请求: $email'); // 调试日志
      final url = Uri.parse('$baseUrl/auth/register');
      print('请求URL: $url'); // 打印完整URL
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Client-Type': 'mobile',  // 添加客户端标识
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('收到响应状态码: ${response.statusCode}'); // 状态码日志
      print('响应头: ${response.headers}'); // 添加响应头信息
      print('响应体: ${utf8.decode(response.bodyBytes).substring(0, min(500, utf8.decode(response.bodyBytes).length))}');

      if (response.headers['content-type']?.contains('text/html') ?? false) {
        throw AuthException('服务器返回了HTML而不是JSON响应，请检查API路由配置');
      }

      final responseData = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return;
      } else {
        throw AuthException(
          responseData['error'] ?? '注册失败: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      print('网络错误: $e');
      throw AuthException('网络连接失败，请检查网络设置');
    } catch (e) {
      print('注册错误: $e');
      if (e is AuthException) rethrow;
      throw AuthException('注册失败: $e');
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    final prefs = await _prefs;
    await prefs.remove('user_email');
    await prefs.remove('user_id');
  }

  bool get isSignedIn => _currentUser != null;
}
