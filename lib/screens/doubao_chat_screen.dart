import 'package:flutter/material.dart';
import '../services/doubao_service.dart';

class Message {
  String content;
  final bool isUser;
  final DateTime timestamp;
  String? streamingContent;

  Message({
    required this.content,
    required this.isUser,
    this.streamingContent,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class DoubaoScreen extends StatefulWidget {
  const DoubaoScreen({super.key});

  @override
  State<DoubaoScreen> createState() => _DoubaoScreenState();
}

class _DoubaoScreenState extends State<DoubaoScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _doubaoService = DoubaoService();
  final List<Message> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(content: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final messages = _messages
          .map((m) => ChatMessage(
                role: m.isUser ? 'user' : 'assistant',
                content: m.content,
              ))
          .toList();

      final aiMessage =
          Message(content: '', isUser: false, streamingContent: '');
      setState(() {
        _messages.add(aiMessage);
        _isLoading = true;
      });
      _scrollToBottom();

      await for (final content in _doubaoService.streamChat(messages)) {
        setState(() {
          aiMessage.streamingContent =
              (aiMessage.streamingContent ?? '') + content;
          aiMessage.content = aiMessage.streamingContent ?? '';
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('发送消息错误: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('豆包AI助手'),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(
                  message: message,
                  content: message.streamingContent ?? message.content,
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '输入消息...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (text) => _sendMessage(text),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final String content;

  const _MessageBubble({
    required this.message,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 4,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Text(
          content,
          style: TextStyle(
            color: message.isUser ? Colors.white : null,
            fontSize: 16,
          ),
          textAlign: TextAlign.left,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }
}
