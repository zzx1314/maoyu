import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatGptPage extends StatefulWidget {
  const ChatGptPage({super.key});

  @override
  State<ChatGptPage> createState() => _ChatGptPageState();
}

class _ChatGptPageState extends State<ChatGptPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_Message> _messages = [];
  bool _isTyping = false;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _Message(
          text: text,
          isMe: true,
          time: DateFormat('HH:mm').format(DateTime.now()),
        ),
      );
      _controller.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // 模拟 ChatGPT 回复
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _messages.add(
          _Message(
            text: "🤖 ChatGPT：你刚才说的是 \"$text\"。\n这是一条模拟的回复内容。",
            isMe: false,
            time: DateFormat('HH:mm').format(DateTime.now()),
          ),
        );
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('毛语'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          // 背景图片
          Positioned.fill(
            child: Image.asset(
              'assets/chatgpt_background.png',
              fit: BoxFit.cover,
            ),
          ),
          // 内容层
          Column(
            children: [
              // 消息列表
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isTyping && index == _messages.length) {
                      // 打字动画
                      return _TypingIndicator();
                    }

                    final msg = _messages[index];
                    return _ChatBubble(message: msg);
                  },
                ),
              ),
              // 输入框
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: "发送消息...",
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.green),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 💬 消息气泡组件
class _ChatBubble extends StatelessWidget {
  final _Message message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe)
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/chatgpt_icon.png'),
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.green.shade100 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: isMe
                      ? const Radius.circular(14)
                      : const Radius.circular(0),
                  bottomRight: isMe
                      ? const Radius.circular(0)
                      : const Radius.circular(14),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe)
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/user_icon.png'),
            ),
        ],
      ),
    );
  }
}

// ⌛ 打字动画组件
class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundImage: AssetImage('assets/chatgpt_icon.png'),
        ),
        const SizedBox(width: 8),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = (_controller.value * 3).floor() + 1;
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 4),
                ],
              ),
              child: Text('.' * t, style: const TextStyle(fontSize: 20)),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _Message {
  final String text;
  final bool isMe;
  final String time;

  _Message({required this.text, required this.isMe, required this.time});
}
