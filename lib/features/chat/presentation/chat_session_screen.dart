import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/presentation/theme/color_manager.dart';
import '../../../core/presentation/theme/text_manager.dart';
import 'controllers/chat_controller.dart';

class ChatSessionScreen extends StatefulWidget {
  const ChatSessionScreen({super.key});

  @override
  State<ChatSessionScreen> createState() => _ChatSessionScreenState();
}

class _ChatSessionScreenState extends State<ChatSessionScreen> {
  final _textController = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();
    AppTypography.init();
    final controller = Get.find<ChatController>();

    final args = (Get.arguments is Map) ? (Get.arguments as Map) : <dynamic, dynamic>{};
    final sessionId = (args['session_id']?.toString() ?? controller.currentSessionId.value ?? '').trim();

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: colors.scaffoldBackground,
        elevation: 0,
        title: Text(
          'جلسة محادثة',
          style: AppTypography.subheadingM.copyWith(color: colors.textDark),
        ),
        actions: [
          IconButton(
            onPressed: sessionId.isEmpty
                ? null
                : () async {
                    await controller.closeChat(sessionId: sessionId);
                    Get.back();
                  },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final msgs = controller.messages;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scroll.hasClients) {
                  _scroll.jumpTo(_scroll.position.maxScrollExtent);
                }
              });

              if (msgs.isEmpty) {
                return Center(
                  child: Text(
                    'ابدأ المحادثة الآن',
                    style: AppTypography.bodyM.copyWith(
                      color: colors.textDark.withValues(alpha: 0.65),
                    ),
                  ),
                );
              }

              return ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: msgs.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final m = msgs[index];
                  final sender = (m['sender'] is Map)
                      ? (m['sender']['full_name']?.toString() ?? '')
                      : '';
                  final text = (m['text']?.toString() ?? '').trim();
                  final fileUrl = m['file_url']?.toString();
                  final content = text.isNotEmpty ? text : (fileUrl ?? '');

                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 520),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (sender.isNotEmpty) ...[
                            Text(
                              sender,
                              style: AppTypography.captionM.bold.copyWith(
                                color: colors.textDark.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            content,
                            style: AppTypography.bodyM.copyWith(
                              color: colors.textDark,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: sessionId.isEmpty
                        ? null
                        : () async {
                            final text = _textController.text.trim();
                            if (text.isEmpty) return;
                            _textController.clear();
                            await controller.sendText(
                              sessionId: sessionId,
                              text: text,
                            );
                          },
                    icon: Icon(Icons.send, color: colors.primary),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة…',
                        filled: true,
                        fillColor: colors.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colors.primary.withValues(alpha: 0.12),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colors.primary.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

