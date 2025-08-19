import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true, type: "text"));
      _isLoading = true;
      _controller.clear();
    });

    _getBotResponse(text);
  }

  Future<void> _getBotResponse(String userMessage) async {
    const url = "https://a69e-122-165-169-235.ngrok-free.app/query";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"prompt": userMessage}),
      );

      String content;
      String type;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        type = data['type'] ?? 'text';
        final responseData = data['response'];

        if (type == 'music' &&
            responseData is Map &&
            responseData.containsKey('music')) {
          final base64Music = responseData['music'];
          final bytes = base64Decode(base64Music);

          final tempDir = await getTemporaryDirectory();
          final filePath =
              '${tempDir.path}/music_${DateTime.now().millisecondsSinceEpoch}.wav';
          final file = File(filePath);
          await file.writeAsBytes(bytes);

          content = file.path;
        } else if (responseData is String) {
          content = responseData;
        } else {
          content = '[Unexpected response format]';
          type = 'text';
        }
      } else {
        content = "⚠️ Error ${response.statusCode}: ${response.reasonPhrase}";
        type = 'text';
      }

      setState(() {
        _isLoading = false;
        _messages.add(_ChatMessage(text: content, isUser: false, type: type));
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(_ChatMessage(
          text: "❌ Failed to connect to server.\n$e",
          isUser: false,
          type: "text",
        ));
      });
    }
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    final isBot = !msg.isUser;
    final bubbleColor = msg.isUser ? Colors.deepPurple : Colors.white;
    final textColor = msg.isUser ? Colors.white : Colors.black87;

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: msg.type == "music"
            ? _buildMusicPlayer(msg.text)
            : MarkdownBody(
                data: msg.text,
                styleSheet:
                    MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: TextStyle(color: textColor, fontSize: 16),
                ),
              ),
      ),
    );
  }

  Widget _buildMusicPlayer(String filePath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🎧 Music Response",
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () async {
            try {
              final player = AudioPlayer();
              await player.setSource(DeviceFileSource(filePath));
              await player.resume();
            } catch (e) {
              print("Playback Error: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error playing audio")),
              );
            }
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text("Play"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: _sendMessage,
                decoration: const InputDecoration(
                  hintText: "Type your message...",
                  border: InputBorder.none,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _sendMessage(_controller.text),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple,
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            ),
            const SizedBox(width: 10),
            const Text("Generating...", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 230, 241),
      appBar: AppBar(
        title: const Text("ChatBot", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == 0) {
                  return _buildLoadingBubble();
                } else {
                  final msg = _messages[
                      _messages.length - 1 - (index - (_isLoading ? 1 : 0))];
                  return _buildChatBubble(msg);
                }
              },
            ),
          ),
          _buildInputField(),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final String type;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.type,
  });
}
