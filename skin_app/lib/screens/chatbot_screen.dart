import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ChatbotScreen extends StatefulWidget {
  final String? category; // 'acne', 'melanoma', 'wound'
  const ChatbotScreen({super.key, this.category});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  String? _userId;

  bool _isSending = false;
  bool _isLoadingHistory = false;
  List<String> _suggestions = [];

  // Premium color palette for consistency
  static const Color deepNavy = Color(0xFF0A1828);
  static const Color richBurgundy = Color(0xFF8B2635);
  static const Color warmGold = Color(0xFFD4AF37);
  static const Color softCream = Color(0xFFFAF9F6);
  static const Color paleGray = Color(0xFFF5F5F0);
  static const Color charcoal = Color(0xFF2D3748);
  static const Color mutedTeal = Color(0xFF1B5B6B);

  @override
  void initState() {
    super.initState();
    _sessionSetup();
  }

  Future<void> _sessionSetup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId') ?? 'guest';
    });
    _loadHistory();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    try {
      String urlStr = "${ApiService.chatbotUrl}/suggestions";
      if (widget.category != null) {
        urlStr += "?category=${widget.category}";
      }
      final url = Uri.parse(urlStr);
      final response = await http.get(url, headers: {"Bypass-Tunnel-Reminder": "true"});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _suggestions = List<String>.from(data["suggestions"]);
        });
      }
    } catch (e) {
      debugPrint("Error loading suggestions: $e");
    }
  }

  Future<void> _loadHistory() async {
    if (_userId == null || _userId == 'guest') {
      setState(() {
        _messages.add({
          "sender": "bot",
          "text": "Hello! I am your AI Skin Specialist. I see you're browsing as a guest. Log in to save your chat history!"
        });
      });
      return;
    }

    setState(() => _isLoadingHistory = true);

    try {
      final url = Uri.parse("${ApiService.chatbotUrl}/history/$_userId");
      final response = await http.get(url, headers: {"Bypass-Tunnel-Reminder": "true"});

      if (response.statusCode == 200) {
        final List<dynamic> historyData = json.decode(response.body);
        setState(() {
          _messages.clear();
          for (var item in historyData) {
            _messages.add({
              "sender": item["sender"],
              "text": item["message"]
            });
          }
          if (_messages.isEmpty) {
            _messages.add({
              "sender": "bot",
              "text": "Hello! I am your AI Skin Specialist. How can I assist you today?"
            });
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint("Error loading history: $e");
    } finally {
      setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _sendMessage({String? customText}) async {
    final text = (customText ?? _controller.text).trim();
    if (text.isEmpty) return;

    if (customText == null) _controller.clear();

    // Simplified for the new Hybrid Server

    setState(() {
      _messages.add({"sender": "user", "text": text});
      _isSending = true;
    });

    _scrollToBottom();

    try {
      final url = Uri.parse(ApiService.chatbotUrl);
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "question": text,
          "userId": _userId,
        }),
      ).timeout(const Duration(seconds: 20));

      String answer;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        answer = data["answer"] ?? "I'm sorry, I couldn't formulate a response.";
      } else {
        answer = "I'm currently experiencing a high volume of inquiries. Please try again.";
      }

      setState(() {
        _messages.add({"sender": "bot", "text": answer});
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({"sender": "bot", "text": "Connectivity issue detected. Please check your internet connection."});
      });
      _scrollToBottom();
    }

    setState(() => _isSending = false);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paleGray,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        leading: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: paleGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: deepNavy, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [richBurgundy, richBurgundy.withOpacity(0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: richBurgundy.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SKIN AI',
                  style: TextStyle(
                    color: deepNavy,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  _isSending ? 'AI is thinking...' : 'Direct Assistance',
                  style: TextStyle(
                    color: _isSending ? richBurgundy : mutedTeal,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: deepNavy),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index], index);
              },
            ),
          ),
          if (_isSending)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              child: _buildTypingIndicator(),
            ),
          
          // Suggested Chips
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                    if (_suggestions.isEmpty) ...[
                      _buildSuggestChip("Melanoma Signs"),
                      _buildSuggestChip("Acne Advice"),
                      _buildSuggestChip("Wound Care"),
                    ] else
                      ..._suggestions.map((s) => _buildSuggestChip(s)).toList(),
                ],
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildSuggestChip(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(customText: text),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: richBurgundy.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: deepNavy.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: richBurgundy,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: deepNavy.withOpacity(0.04),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) => _buildDot(i)),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: richBurgundy.withOpacity(0.4 + (index * 0.2)),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message, int index) {
    final bool isUser = message["sender"] == "user";
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isUser ? richBurgundy : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser 
                  ? richBurgundy.withOpacity(0.15) 
                  : deepNavy.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          message["text"]!,
          style: TextStyle(
            color: isUser ? Colors.white : charcoal,
            fontSize: 14.5,
            height: 1.5,
            fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: deepNavy.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: paleGray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: deepNavy, fontWeight: FontWeight.w600, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Ask about your skin...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isSending ? null : () => _sendMessage(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isSending ? paleGray : richBurgundy,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!_isSending)
                    BoxShadow(
                      color: richBurgundy.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                ],
              ),
              child: Icon(
                _isSending ? Icons.hourglass_empty_rounded : Icons.send_rounded,
                color: _isSending ? Colors.grey : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
