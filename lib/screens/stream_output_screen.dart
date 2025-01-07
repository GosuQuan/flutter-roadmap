import 'dart:async';
import 'package:flutter/material.dart';

class StreamOutputScreen extends StatefulWidget {
  const StreamOutputScreen({super.key});

  @override
  State<StreamOutputScreen> createState() => _StreamOutputScreenState();
}

class _StreamOutputScreenState extends State<StreamOutputScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final List<String> _outputs = [];
  String _currentLine = '';
  Timer? _timer;
  bool _isGenerating = false;
  final StreamController<String> _streamController = StreamController<String>();

  @override
  void initState() {
    super.initState();
    _streamController.stream.listen((data) {
      setState(() {
        if (data == '\n') {
          if (_currentLine.isNotEmpty) {
            _outputs.add(_currentLine);
            _currentLine = '';
          }
        } else {
          _currentLine += data;
        }
      });
      // 自动滚动到底部
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamController.close();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _startGenerating(String text) {
    if (_isGenerating) return;
    
    setState(() {
      _isGenerating = true;
    });

    List<String> characters = text.split('');
    int currentIndex = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (currentIndex >= characters.length) {
        _streamController.add('\n');
        _stopGenerating();
        return;
      }

      _streamController.add(characters[currentIndex]);
      currentIndex++;
    });
  }

  void _stopGenerating() {
    _timer?.cancel();
    setState(() {
      _isGenerating = false;
    });
  }

  void _resetOutput() {
    _timer?.cancel();
    setState(() {
      _outputs.clear();
      _currentLine = '';
      _isGenerating = false;
      _textController.clear();
    });
  }

  void _handleSubmit() {
    if (_textController.text.isEmpty || _isGenerating) return;
    
    String text = _textController.text;
    _textController.clear();
    _startGenerating(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '流式输出',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _resetOutput,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListView(
                controller: _scrollController,
                children: [
                  ..._outputs.map((text) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      text,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        height: 1.5,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  )),
                  if (_currentLine.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _currentLine,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 16,
                                height: 1.5,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          if (_isGenerating)
                            const Text(
                              '|',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: '输入要显示的文本...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    enabled: !_isGenerating,
                    onSubmitted: (_) => _handleSubmit(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isGenerating ? _stopGenerating : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isGenerating ? Colors.red : Colors.blue,
                    padding: const EdgeInsets.all(16),
                    shape: const CircleBorder(),
                  ),
                  child: Icon(
                    _isGenerating ? Icons.stop : Icons.send,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
