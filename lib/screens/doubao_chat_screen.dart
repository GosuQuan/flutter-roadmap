import 'package:flutter/material.dart';
import '../services/doubao_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/highlight.dart' show highlight, Node;
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_highlighter/themes/atom-one-light.dart';

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
  final _doubaoService = DoubaoService();
  final _messages = <Message>[];
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(content: text, isUser: true));
      _isLoading = true;
      _messageController.clear();
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
        title: const Text('豆包AI'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30), // 圆润边框
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
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

class _SyntaxHighlighter extends SyntaxHighlighter {
  final bool isDark;

  _SyntaxHighlighter(this.isDark);

  @override
  TextSpan format(String source, {String? language}) {
    if (language == null) return TextSpan(text: source);

    try {
      var highlighted = highlight.parse(source, language: language);
      var theme = isDark ? atomOneDarkTheme : atomOneLightTheme;

      return _convert(highlighted.nodes!, theme);
    } catch (e) {
      return TextSpan(text: source);
    }
  }

  TextSpan _convert(List<Node> nodes, Map<String, TextStyle> theme) {
    List<TextSpan> spans = [];
    var currentSpans = spans;
    var codeTheme = theme;

    _traverse(Node node) {
      if (node.value != null) {
        final style = node.className == null ? null : codeTheme[node.className];
        currentSpans.add(TextSpan(
          style: style?.copyWith(
            fontFamily: GoogleFonts.firaCode().fontFamily,
            fontSize: 14,
          ),
          text: node.value,
        ));
      } else if (node.children != null) {
        List<TextSpan> tmp = [];
        currentSpans.add(TextSpan(
          children: tmp,
          style: TextStyle(
            fontFamily: GoogleFonts.firaCode().fontFamily,
            fontSize: 14,
          ),
        ));
        var previousSpans = currentSpans;
        currentSpans = tmp;

        node.children!.forEach((n) {
          _traverse(n);
          if (n == node.children!.last) {
            currentSpans = previousSpans;
          }
        });
      }
    }

    for (var node in nodes) {
      _traverse(node);
    }

    return TextSpan(
      style: TextStyle(
        fontFamily: GoogleFonts.firaCode().fontFamily,
        fontSize: 14,
      ),
      children: spans,
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final content = message.streamingContent ?? message.content;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 4,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: message.isUser
            ? Text(
                content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              )
            : MarkdownBody(
                data: content,
                selectable: true,
                syntaxHighlighter: _SyntaxHighlighter(isDark),
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  code: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                    fontFamily: GoogleFonts.firaCode().fontFamily,
                  ),
                  codeblockPadding: const EdgeInsets.all(8),
                  codeblockDecoration: BoxDecoration(
                    color: isDark
                        ? const Color(
                            0xFF282C34) // VS Code dark theme background
                        : const Color(
                            0xFFF6F8FA), // GitHub light theme background
                    borderRadius: BorderRadius.circular(8),
                  ),
                  h1: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  h2: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  h3: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  blockquote: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 16,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: isDark ? Colors.white30 : Colors.black26,
                        width: 4,
                      ),
                    ),
                  ),
                  tableBody: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  tableHead: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  tableBorder: TableBorder.all(
                    color: isDark ? Colors.white30 : Colors.black12,
                    width: 1,
                  ),
                ),
                onTapLink: (text, href, title) async {
                  if (href != null) {
                    final uri = Uri.parse(href);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  }
                },
              ),
      ),
    );
  }
}
