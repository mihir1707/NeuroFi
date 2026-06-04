import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/ai_provider.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller   = TextEditingController();
  final _scrollCtrl   = ScrollController();

  static const _quickQuestions = [
    'How am I spending?',
    'Budget tips for me',
    'Savings advice',
    'This month summary',
  ];

  void _send([String? text]) {
    final msg = (text ?? _controller.text).trim();
    if (msg.isEmpty) return;
    _controller.clear();
    context.read<AiProvider>().sendMessage(msg);
    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider    = context.watch<AiProvider>();
    final history     = provider.chatHistory;
    final isSending   = provider.isSendingMessage;
    final isEmpty     = history.isEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NeuroFi AI',
                    style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                Text('Your finance assistant',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.4))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: Colors.white.withValues(alpha: 0.6), size: 20),
            onPressed: () => context.read<AiProvider>().clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isEmpty
                ? _buildWelcome()
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: history.length + (isSending ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (isSending && i == history.length) return _typingBubble();
                      final msg    = history[i];
                      final isUser = msg['role'] == 'user';
                      return _ChatBubble(
                        text: msg['content'] ?? '',
                        isUser: isUser,
                      );
                    },
                  ),
          ),
          if (isEmpty) _buildQuickQuestions(),
          _buildInputBar(isSending),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 40))),
          ),
          const SizedBox(height: 20),
          Text('NeuroFi AI Assistant',
              style: AppTextStyles.headingMedium.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text('Ask me anything about your finances',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  Widget _buildQuickQuestions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: _quickQuestions.map((q) => GestureDetector(
          onTap: () => _send(q),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Text(q, style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInputBar(bool isSending) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Color(0x26FFFFFF))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: TextField(
                controller: _controller,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ask about your finances...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.4)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: isSending ? null : _send,
            child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: isSending ? const Color(0xFF111111) : Colors.white,
                shape: BoxShape.circle,
                border: isSending ? Border.all(color: const Color(0x33FFFFFF)) : null,
              ),
              child: isSending
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      ))
                  : const Icon(Icons.send_rounded, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18), topRight: Radius.circular(18),
            bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _dot(0), const SizedBox(width: 4),
          _dot(200), const SizedBox(width: 4),
          _dot(400),
        ]),
      ),
    );
  }

  Widget _dot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (_, v, _) => Opacity(
        opacity: v,
        child: Container(
          width: 7, height: 7,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool   isUser;
  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? Colors.white : const Color(0xFF111111),
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(18),
            topRight:    const Radius.circular(18),
            bottomLeft:  Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser ? null : Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Text(text,
            style: AppTextStyles.bodyMedium.copyWith(
                color: isUser ? Colors.black : Colors.white, 
                fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                height: 1.5)),
      ),
    );
  }
}
