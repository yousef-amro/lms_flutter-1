import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  static const String _noCloseReasonSentinel = '__NO_CLOSE_REASON__';

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

    final args = (Get.arguments is Map)
        ? (Get.arguments as Map)
        : <dynamic, dynamic>{};
    final sessionId =
        (args['session_id']?.toString() ??
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
          // Place "close chat" next to the back button (like the screenshot).
          leadingWidth: sessionId.isNotEmpty ? 120 : 56,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isArabic
                      ? Icons.arrow_back_ios_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: 20,
                  color: colors.textDark,
                ),
                onPressed: () => Get.back(),
              ),
              if (sessionId.isNotEmpty) ...[
                IconButton(
                  onPressed: () async {
                    final closeReasonId =
                        await showModalBottomSheet<String?>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (sheetContext) {
                            return _CloseChatReasonSheet(
                              controller: controller,
                              colors: colors,
                            );
                          },
                        );

                    if (!mounted) return;
                    if (closeReasonId == null) return;

                    if (closeReasonId ==
                        _ChatSessionScreenState
                            ._noCloseReasonSentinel) {
                      await controller.closeChat(
                        sessionId: sessionId,
                      );
                    } else {
                      await controller.closeChat(
                        sessionId: sessionId,
                        closeReasonId: closeReasonId,
                      );
                    }
                    if (mounted) Get.back();
                  },
                  icon: SvgPicture.asset(
                    'assets/images/svg/message-tick.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ],
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
              Obx(() {
                final argsImage = args['peer_image']
                    ?.toString()
                    .trim();
                final apiImage = controller
                    .currentSessionPeerImage
                    .value
                    ?.trim();
                final imageUrl =
                    (argsImage != null && argsImage.isNotEmpty)
                    ? argsImage
                    : apiImage;
                final hasImage =
                    imageUrl != null && imageUrl.isNotEmpty;
                return CircleAvatar(
                  radius: 22,
                  backgroundColor: hasImage
                      ? null
                      : colors.primary.withValues(alpha: 0.12),
                  backgroundImage: hasImage
                      ? NetworkImage(imageUrl)
                      : null,
                  child: hasImage
                      ? null
                      : Icon(
                          Icons.person_rounded,
                          color: colors.infoBlue,
                          size: 28,
                        ),
                );
              }),
              const SizedBox(width: 12),
            ],
          ),
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
                  // While we fetch history, show a spinner instead of the empty-state text.
                  if (controller.isLoadingMessages.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  listChildren.add(
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'ابدأ المحادثة الآن',
                          style: AppTypography.bodyM.copyWith(
                            color: colors.textDark.withValues(
                              alpha: 0.65,
                            ),
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
                    final isFromMe =
                        controller.userId.value != null &&
                        senderId == controller.userId.value;
                    final text = (m['text']?.toString() ?? '').trim();
                    final fileUrl = m['file_url']?.toString();
                    final content = text.isNotEmpty
                        ? text
                        : (fileUrl ?? '');
                    final sentAt = m['sent_at'];
                    DateTime timestamp = DateTime.now();
                    if (sentAt != null) {
                      if (sentAt is DateTime) {
                        timestamp = sentAt;
                      } else if (sentAt is String) {
                        timestamp =
                            DateTime.tryParse(sentAt) ?? timestamp;
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
    final hour = t.hour > 12
        ? t.hour - 12
        : (t.hour == 0 ? 12 : t.hour);
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
                hintStyle: AppTypography.bodyS.withColor(
                  colors.hintGray,
                ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 12,
            ),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.attach_file_rounded,
              color: colors.textDark,
              size: 22,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 12,
            ),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 6,
              top: 6,
              bottom: 6,
            ),
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

class _CloseChatReasonSheet extends StatefulWidget {
  const _CloseChatReasonSheet({
    required this.controller,
    required this.colors,
  });

  final ChatController controller;
  final ColorManager colors;

  @override
  State<_CloseChatReasonSheet> createState() =>
      _CloseChatReasonSheetState();
}

class _CloseChatReasonSheetState
    extends State<_CloseChatReasonSheet> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedReasonId;
  List<JsonMap> _reasons = const [];

  @override
  void initState() {
    super.initState();
    _loadReasons();
  }

  Future<void> _loadReasons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    List<JsonMap> reasons;
    try {
      reasons = await widget.controller.fetchCloseReasons(
        isStudentReason: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        final msg = e.toString();
        _errorMessage = msg.isNotEmpty
            ? msg
            : 'تعذر تحميل أسباب الإغلاق';
      });
      return;
    }

    final activeReasons = reasons
        .where((r) {
          final v = r['is_active'];
          return v == true ||
              (v is String && v.toLowerCase() == 'true');
        })
        .toList(growable: false);

    setState(() {
      _reasons = activeReasons;
      _selectedReasonId = activeReasons.isNotEmpty
          ? activeReasons.first['id']?.toString()
          : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.68;
    final primary = widget.colors.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: SizedBox(
          height: sheetHeight,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: widget.colors.cardBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.colors.divider,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'لماذا تريد إغلاق المحادثة؟',
                    style: AppTypography.bodyM.bold.copyWith(
                      fontFamily: AppFonts.ffShamelFamily,
                      color: widget.colors.textDark,
                      fontSize: 16,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _errorMessage != null
                      ? Center(
                          child: Text(
                            _errorMessage!,
                            style: AppTypography.bodyS.copyWith(
                              color: widget.colors.error,
                              fontFamily: AppFonts.ffShamelFamily,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        )
                      : _reasons.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد أسباب متاحة للإغلاق',
                            style: AppTypography.bodyS.copyWith(
                              color: widget.colors.textMuted,
                              fontFamily: AppFonts.ffShamelFamily,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        )
                      : ListView.separated(
                          itemCount: _reasons.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final reason = _reasons[index];
                            final id = reason['id']?.toString() ?? '';
                            final name =
                                reason['name']?.toString() ?? '';
                            final isSelected =
                                _selectedReasonId == id;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                  16,
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedReasonId = id;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primary.withValues(
                                            alpha: 0.08,
                                          )
                                        : widget
                                              .colors
                                              .cardBackground,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? primary
                                          : widget.colors.divider,
                                    ),
                                  ),
                                  child: Row(
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons
                                                  .radio_button_checked_rounded
                                            : Icons
                                                  .radio_button_off_rounded,
                                        color: isSelected
                                            ? primary
                                            : widget.colors.textMuted,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: AppTypography
                                              .bodyS
                                              .semiBold
                                              .copyWith(
                                                fontFamily: AppFonts
                                                    .ffShamelFamily,
                                                color: widget
                                                    .colors
                                                    .textDark,
                                              ),
                                          textDirection:
                                              TextDirection.rtl,
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, null);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: widget.colors.textDark,
                          side: BorderSide(
                            color: widget.colors.divider,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          'الإلغاء',
                          style: AppTypography.bodyM.semiBold
                              .copyWith(
                                fontFamily: AppFonts.ffShamelFamily,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_selectedReasonId != null) {
                                  Navigator.pop(
                                    context,
                                    _selectedReasonId,
                                  );
                                } else {
                                  Navigator.pop(
                                    context,
                                    _ChatSessionScreenState
                                        ._noCloseReasonSentinel,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.colors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          disabledBackgroundColor: widget.colors.error
                              .withValues(alpha: 0.45),
                        ),
                        child: Text(
                          _selectedReasonId != null
                              ? 'تأكيد إغلاق'
                              : 'تأكيد إغلاق بدون سبب',
                          style: AppTypography.bodyM.semiBold
                              .copyWith(
                                fontFamily: AppFonts.ffShamelFamily,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
