import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
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
      backgroundColor: AppColors.darkBg0,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.amber, AppColors.peach]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NeuroFi AI',
                    style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
                Text('Your finance assistant',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.darkText3, size: 20),
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
              gradient: const LinearGradient(colors: [AppColors.amber, AppColors.peach]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 40))),
          ),
          const SizedBox(height: 20),
          Text('NeuroFi AI Assistant',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.lightGrey)),
          const SizedBox(height: 8),
          Text('Ask me anything about your finances',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText2)),
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
              color: AppColors.darkBg1,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Text(q, style: AppTextStyles.labelMedium.copyWith(color: AppColors.sage)),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildInputBar(bool isSending) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.darkBg0,
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkBg1,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: TextField(
                controller: _controller,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ask about your finances...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkText3),
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
                gradient: isSending
                    ? const LinearGradient(colors: [AppColors.darkBg2, AppColors.darkBg2])
                    : const LinearGradient(colors: [AppColors.forest, AppColors.green]),
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            color: AppColors.lightGrey, strokeWidth: 2),
                      ))
                  : const Icon(Icons.send_rounded, color: AppColors.lightGrey, size: 20),
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
        decoration: BoxDecoration(
          color: AppColors.darkBg1,
          borderRadius: const BorderRadius.only(
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
      builder: (_, v, __) => Opacity(
        opacity: v,
        child: Container(
          width: 7, height: 7,
          decoration: BoxDecoration(color: AppColors.sage, shape: BoxShape.circle),
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
          gradient: isUser
              ? const LinearGradient(colors: [AppColors.forest, AppColors.green])
              : null,
          color: isUser ? null : AppColors.darkBg1,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(18),
            topRight:    const Radius.circular(18),
            bottomLeft:  Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser ? null : Border.all(color: AppColors.darkBorder),
        ),
        child: Text(text,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.lightGrey, height: 1.5)),
      ),
    );
  }
}
