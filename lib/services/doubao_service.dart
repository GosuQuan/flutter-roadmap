import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'auth_service.dart';

class DoubaoException implements Exception {
  final String message;
  final int? statusCode;

  DoubaoException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class DoubaoService {
  static const String baseUrl = 'http://localhost:3000/api';
  final _uuid = const Uuid();

  Stream<String> streamChat(List<ChatMessage> messages) async* {
    try {
      print('发送AI请求');
      final url = Uri.parse('$baseUrl/chat');
      print('请求URL: $url');

      final chatId = _uuid.v4();
      final requestBody = {
        'messages': messages.map((m) => m.toJson()).toList(),
        'chatId': chatId,
      };

      print('请求体: ${json.encode(requestBody)}');

      // 使用原始的http.Client来处理流式响应
      final client = http.Client();
      final request = http.Request('POST', url);
      request.headers.addAll({
        'Content-Type': 'application/json',
        'X-Client-Type': 'mobile',
        'Accept': 'text/event-stream',
        'Cookie': AuthService.authToken ?? '',
      });
      request.body = json.encode(requestBody);

      final response = await client.send(request);

      if (response.statusCode == 401) {
        throw DoubaoException('请先登录', statusCode: 401);
      }

      if (response.statusCode != 200) {
        final body = await response.stream.bytesToString();
        final errorData = json.decode(body);
        throw DoubaoException(
          errorData['error'] ?? '请求失败: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      // 处理流式响应
      var buffer = '';
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;
        
        while (buffer.contains('\n\n')) {
          final index = buffer.indexOf('\n\n');
          final line = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 2);

          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') continue;

            try {
              final jsonData = json.decode(data);
              final content = jsonData['content'] as String;
              if (content.isNotEmpty) {
                yield content;
              }
            } catch (e) {
              print('解析数据错误: $e');
              print('错误数据: $data');
            }
          }
        }
      }

      client.close();
    } on http.ClientException catch (e) {
      print('网络错误: $e');
      throw DoubaoException('网络连接失败，请检查网络设置');
    } catch (e) {
      print('AI对话错误: $e');
      if (e is DoubaoException) rethrow;
      throw DoubaoException('请求失败: $e');
    }
  }
}
