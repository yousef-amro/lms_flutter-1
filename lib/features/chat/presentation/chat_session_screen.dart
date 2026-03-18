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

  static const Color _onlineGreen = Color(0xFF00CD83);
  static const Color _bubbleOut = Color(0xFFDCF8C6);
  static const Color _userBubbleGreen = Color(0xFF0BAC4B);
  static const Color _sendButtonBg = Color(0xFFE8F5E9);
  static const Color _sendButtonIcon = Color(0xFF2E7D32);

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
    final isArabic = Get.locale?.languageCode.toLowerCase() == 'ar';

    final args =
        (Get.arguments is Map) ? (Get.arguments as Map) : <dynamic, dynamic>{};
    final sessionId = (args['session_id']?.toString() ??
            controller.currentSessionId.value ??
            '')
        .trim();
    final peerName = args['peer_name']?.toString() ?? 'محادثة مباشرة';

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: colors.cardBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              isArabic
                  ? Icons.arrow_back_ios_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: 20,
              color: colors.textDark,
            ),
            onPressed: () => Get.back(),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      peerName,
                      style: TextStyle(
                        fontFamily: AppFonts.ffShamelFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textDark,
                      ),
                      textDirection: TextDirection.rtl,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _onlineGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'متصل الآن',
                          style: TextStyle(
                            fontFamily: AppFonts.ffShamelFamily,
                            fontSize: 10,
                            color: colors.textMuted,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.primary.withValues(alpha: 0.12),
                child: Icon(
                  Icons.person_rounded,
                  color: colors.infoBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          actions: [
            if (sessionId.isNotEmpty)
              IconButton(
                onPressed: () async {
                  await controller.closeChat(sessionId: sessionId);
                  Get.back();
                },
                icon: Icon(Icons.close, color: colors.textDark, size: 22),
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

                final listChildren = <Widget>[
                  _DateSeparator(colors: colors),
                  const SizedBox(height: 16),
                ];

                if (msgs.isEmpty) {
                  listChildren.add(
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'ابدأ المحادثة الآن',
                          style: AppTypography.bodyM.copyWith(
                            color: colors.textDark.withValues(alpha: 0.65),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),
                  );
                } else {
                  for (final m in msgs) {
                    final sender = (m['sender'] is Map)
                        ? (m['sender'] as Map<String, dynamic>)
                        : null;
                    final senderId = sender?['id']?.toString();
                    final isFromMe = controller.userId.value != null &&
                        senderId == controller.userId.value;
                    final text = (m['text']?.toString() ?? '').trim();
                    final fileUrl = m['file_url']?.toString();
                    final content =
                        text.isNotEmpty ? text : (fileUrl ?? '');
                    final sentAt = m['sent_at'];
                    DateTime timestamp = DateTime.now();
                    if (sentAt != null) {
                      if (sentAt is DateTime) {
                        timestamp = sentAt;
                      } else if (sentAt is String) {
                        timestamp = DateTime.tryParse(sentAt) ?? timestamp;
                      }
                    }

                    listChildren.add(
                      _ChatBubble(
                        text: content,
                        isFromMe: isFromMe,
                        timestamp: timestamp,
                        bubbleOutColor: _bubbleOut,
                        bubbleInColor: _userBubbleGreen,
                        colors: colors,
                      ),
                    );
                  }
                }

                return ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  children: listChildren,
                );
              }),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                color: colors.scaffoldBackground,
                child: _ChatInputBar(
                  textController: _textController,
                  onSend: () {
                    final text = _textController.text.trim();
                    if (text.isEmpty || sessionId.isEmpty) return;
                    _textController.clear();
                    controller.sendText(
                      sessionId: sessionId,
                      text: text,
                    );
                  },
                  colors: colors,
                  sendButtonBg: _sendButtonBg,
                  sendButtonIcon: _sendButtonIcon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.colors});

  final ColorManager colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: colors.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'اليوم',
            style: AppTypography.bodyS.withColor(colors.textMuted),
            textDirection: TextDirection.rtl,
          ),
        ),
        Expanded(child: Divider(color: colors.divider, thickness: 1)),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.text,
    required this.isFromMe,
    required this.timestamp,
    required this.bubbleOutColor,
    required this.bubbleInColor,
    required this.colors,
  });

  final String text;
  final bool isFromMe;
  final DateTime timestamp;
  final Color bubbleOutColor;
  final Color bubbleInColor;
  final ColorManager colors;

  static String _formatTime12h(DateTime t) {
    final hour =
        t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final amPm = t.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $amPm';
  }

  static String _formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (isFromMe) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          decoration: BoxDecoration(
            color: bubbleInColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أنت',
                style: const TextStyle(
                  fontFamily: AppFonts.ffShamelFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontFamily: AppFonts.ffShamelFamily,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime12h(timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleOutColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontFamily: AppFonts.ffShamelFamily,
                fontSize: 15,
                color: colors.textDark,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(timestamp),
              style: TextStyle(fontSize: 11, color: colors.textMuted),
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.textController,
    required this.onSend,
    required this.colors,
    required this.sendButtonBg,
    required this.sendButtonIcon,
  });

  final TextEditingController textController;
  final VoidCallback onSend;
  final ColorManager colors;
  final Color sendButtonBg;
  final Color sendButtonIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              textDirection: TextDirection.rtl,
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'اكتب رسالة…',
                hintStyle: AppTypography.bodyS.withColor(colors.hintGray),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(vertical: 12),
            color: colors.divider,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.mic_none_outlined,
              color: colors.textDark,
              size: 22,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.attach_file_rounded,
              color: colors.textDark,
              size: 22,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6, top: 6, bottom: 6),
            child: Material(
              color: sendButtonBg,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: onSend,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.send_rounded,
                    color: sendButtonIcon,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
