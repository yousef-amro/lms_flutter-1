import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool _promptShown = false;
  bool _requiresAcceptance = false;
  bool _isAccepted = true;
  bool _isChatClosed = false;
  bool _isUploadingAttachment = false;
  String _sessionId = '';

  static const String _noCloseReasonSentinel = '__NO_CLOSE_REASON__';

  static const Color _onlineGreen = Color(0xFF00CD83);
  static const Color _bubbleOut = Color(0xFFFFFFFF);
  static const Color _userBubbleGreen = Color(0xFF3185ff);
  static const Color _sendButtonBg = Color(0xFFE8F5E9);
  static const Color _sendButtonIcon = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    final controller = Get.find<ChatController>();

    final args = (Get.arguments is Map)
        ? (Get.arguments as Map)
        : <dynamic, dynamic>{};

    _sessionId =
        (args['session_id']?.toString() ??
                controller.currentSessionId.value ??
                '')
            .trim();
    _requiresAcceptance =
        args['requires_acceptance'] == true ||
        args['requires_acceptance']?.toString().toLowerCase() ==
            'true';

    // If it doesn't require acceptance, enable the chat right away.
    _isAccepted = !_requiresAcceptance;

    // Safety-net: if the session is already closed, disable sending/closing UI.
    if (_sessionId.isNotEmpty) {
      final session = controller.getCallCenterSessionById(_sessionId);
      final status =
          session?['status']?.toString().trim().toLowerCase() ?? '';
      _isChatClosed = status == 'closed';
      if (_isChatClosed) {
        _isAccepted = false;
      }
    }

    if (!_requiresAcceptance || _sessionId.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _promptShown) return;

      // Ensure we have the latest status before showing the "accept" dialog.
      // This prevents calling `acceptChat` on sessions that were closed
      // between the last refresh and this screen opening.
      await controller.loadCallCenterSessions();
      if (!mounted) return;

      final session = controller.getCallCenterSessionById(_sessionId);
      final ccStatus = session?['status']
          ?.toString()
          .trim()
          .toLowerCase();
      String? reqStatus;
      for (final r in controller.incomingRequests) {
        final sid = r['session_id']?.toString().trim();
        if (sid == _sessionId) {
          reqStatus = r['status']?.toString().trim().toLowerCase();
          break;
        }
      }
      _isChatClosed = ccStatus == 'closed' || reqStatus == 'closed';
      if (_isChatClosed) {
        setState(() {
          _isAccepted = false;
        });
        await controller.loadSessionMessages(sessionId: _sessionId);
        return;
      }

      _promptShown = true;

      final shouldAccept = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('تأكيد القبول'),
            content: const Text('هل تريد قبول هذه المحادثة؟'),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(false),
                child: const Text('لا'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(true),
                child: const Text('نعم'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (shouldAccept == true) {
        try {
          await controller.acceptChat(sessionId: _sessionId);
          await controller.loadSessionMessages(sessionId: _sessionId);
          if (!mounted) return;
          setState(() {
            _isAccepted = true;
          });
        } catch (e) {
          // If backend says it's already closed, don't show the failure snackbar.
          final updatedSession = controller.getCallCenterSessionById(
            _sessionId,
          );
          final updatedStatusCallCenter = updatedSession?['status']
              ?.toString()
              .trim()
              .toLowerCase();

          String? updatedStatusIncoming;
          for (final r in controller.incomingRequests) {
            final sid = r['session_id']?.toString().trim();
            if (sid == _sessionId) {
              updatedStatusIncoming = r['status']
                  ?.toString()
                  .trim()
                  .toLowerCase();
              break;
            }
          }

          final err = e.toString().toLowerCase();
          final isClosed =
              updatedStatusCallCenter == 'closed' ||
              updatedStatusIncoming == 'closed' ||
              err.contains('already_closed') ||
              err.contains('chat_closed') ||
              err.contains('already closed');

          if (isClosed) return;

          Get.snackbar(
            'خطأ',
            'تعذر قبول المحادثة. حاول مرة أخرى.',
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        // لا — only go back; do not close on server or remove from incoming list.
        controller.abandonSessionOpenWithoutClosing();
        if (mounted) Get.back();
      }
    });
  }

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

    final sessionData = controller.getCallCenterSessionById(
      sessionId,
    );
    final argsPeerImage = args['peer_image']?.toString().trim();
    final currentPeerImage = controller.currentSessionPeerImage.value
        ?.trim();
    final sheetPeerImage =
        (argsPeerImage != null && argsPeerImage.isNotEmpty)
        ? argsPeerImage
        : currentPeerImage;

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: colors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: colors.cardBackground,
          elevation: 0,
          // Place "close chat" next to the back button (like the screenshot).
          leadingWidth: sessionId.isNotEmpty ? 188 : 56,
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
              if (sessionId.isNotEmpty && !_isChatClosed) ...[
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
                              sessionId: sessionId,
                              peerName: peerName,
                              peerImageUrl: sheetPeerImage,
                              sessionData: sessionData,
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
                Obx(() {
                  final allow = controller.allowAttachments.value;
                  return IconButton(
                    onPressed: () async {
                      if (!mounted) return;
                      final nextAllow = !allow;

                      // Optimistic UI update; backend will confirm via WS event.
                      controller.allowAttachments.value = nextAllow;
                      try {
                        await controller.setAttachmentPermission(
                          sessionId: sessionId,
                          allow: nextAllow,
                        );
                        if (!mounted) return;
                        if (nextAllow) {
                          controller.sendText(
                            sessionId: sessionId,
                            text: 'تم السماح لرفع المرفقات',
                          );
                        } else {
                          controller.sendText(
                            sessionId: sessionId,
                            text: 'تم إلغاء السماح لرفع المرفقات',
                          );
                        }
                      } catch (e) {
                        controller.allowAttachments.value = allow;
                        if (!mounted) return;
                        Get.snackbar(
                          'خطأ',
                          'تعذر تغيير إذن المرفقات. حاول مرة أخرى.',
                          snackPosition: SnackPosition.TOP,
                        );
                      }
                    },
                    icon: Icon(
                      Icons.attach_file_rounded,
                      size: 22,
                      color: allow ? colors.primary : colors.textMuted,
                    ),
                  );
                }),
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
                      textDirection: ui.TextDirection.rtl,
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
                          textDirection: ui.TextDirection.rtl,
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
              // Pending accept: no Obx here — GetX errors if Obx returns without
              // reading any .obs (e.g. before messages / loading are touched).
              child:
                  _requiresAcceptance &&
                      !_isAccepted &&
                      !_isChatClosed
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'اختر قبول أو إلغاء المحادثة للبدء',
                          style: AppTypography.bodyM.copyWith(
                            color: colors.textDark.withValues(
                              alpha: 0.65,
                            ),
                          ),
                          textDirection: ui.TextDirection.rtl,
                        ),
                      ),
                    )
                  : Obx(() {
                      final loading =
                          controller.isLoadingMessages.value;
                      final msgs = controller.messages;
                      WidgetsBinding.instance.addPostFrameCallback((
                        _,
                      ) {
                        if (_scroll.hasClients) {
                          _scroll.jumpTo(
                            _scroll.position.maxScrollExtent,
                          );
                        }
                      });

                      final listChildren = <Widget>[
                        _DateSeparator(colors: colors),
                        const SizedBox(height: 16),
                      ];

                      if (msgs.isEmpty) {
                        // While we fetch history, show a spinner instead of the empty-state text.
                        if (loading) {
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
                                textDirection: ui.TextDirection.rtl,
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
                          final senderName = isFromMe
                              ? (controller.userName.value?.trim() ??
                                    '')
                              : ((sender?['full_name'] ??
                                                sender?['name'])
                                            ?.toString()
                                            .trim() ??
                                        '')
                                    .trim();
                          final text = (m['text']?.toString() ?? '')
                              .trim();
                          final fileUrl = m['file_url']?.toString();
                          final messageType = m['message_type']?.toString();
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
                                  DateTime.tryParse(sentAt) ??
                                  timestamp;
                            }
                          }

                          listChildren.add(
                            _ChatBubble(
                              text: content,
                              fileUrl: fileUrl,
                              messageType: messageType,
                              isFromMe: isFromMe,
                              timestamp: timestamp,
                              senderName: senderName.isNotEmpty
                                  ? senderName
                                  : peerName,
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
                child: Obx(() {
                  final allowAttachments = controller.allowAttachments.value;
                  final isCallCenter =
                      controller.role.value == 'call_center';
                  // Student uploads follow session allow_attachments; agents can
                  // still attach regardless (same as backend: permission is for the student).
                  final attachmentsEnabled =
                      (isCallCenter || allowAttachments) &&
                      _isAccepted &&
                      !_isUploadingAttachment;
                  return _ChatInputBar(
                    textController: _textController,
                    enabled: _isAccepted && !_isUploadingAttachment,
                    attachmentsEnabled: attachmentsEnabled,
                    onSend: () {
                      if (!_isAccepted || _isUploadingAttachment) return;
                      final text = _textController.text.trim();
                      if (text.isEmpty || sessionId.isEmpty) return;
                      _textController.clear();
                      controller.sendText(
                        sessionId: sessionId,
                        text: text,
                      );
                    },
                    onAttach: () async {
                      if (_isUploadingAttachment) return;
                      if (sessionId.isEmpty) return;

                      final picked = await FilePicker.platform.pickFiles(
                        allowMultiple: false,
                        withData: false,
                      );
                      if (!mounted ||
                          picked == null ||
                          picked.files.isEmpty) {
                        return;
                      }

                      final file = picked.files.first;
                      final path = file.path?.trim() ?? '';
                      if (path.isEmpty) {
                        Get.snackbar(
                          'خطأ',
                          'تعذر قراءة الملف المختار.',
                          snackPosition: SnackPosition.TOP,
                        );
                        return;
                      }

                      setState(() => _isUploadingAttachment = true);
                      try {
                        final attachmentId =
                            await controller.uploadChatAttachment(
                              sessionId: sessionId,
                              filePath: path,
                              fileName: file.name,
                            );

                        await controller.sendAttachment(
                          sessionId: sessionId,
                          attachmentId: attachmentId,
                        );
                      } catch (e) {
                        if (!mounted) return;
                        Get.snackbar(
                          'خطأ',
                          'تعذر إرسال المرفق. حاول مرة أخرى.',
                          snackPosition: SnackPosition.TOP,
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isUploadingAttachment = false);
                        }
                      }
                    },
                    colors: colors,
                    sendButtonBg: _sendButtonBg,
                    sendButtonIcon: _sendButtonIcon,
                  );
                }),
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
            textDirection: ui.TextDirection.rtl,
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
    this.fileUrl,
    this.messageType,
    required this.isFromMe,
    required this.timestamp,
    required this.senderName,
    required this.bubbleOutColor,
    required this.bubbleInColor,
    required this.colors,
  });

  final String text;
  final String? fileUrl;
  final String? messageType;
  final bool isFromMe;
  final DateTime timestamp;
  final String senderName;
  final Color bubbleOutColor;
  final Color bubbleInColor;
  final ColorManager colors;

  static bool _isImageAttachment(String? url, String? type) {
    if (url == null || url.trim().isEmpty) return false;
    final t = (type ?? '').toLowerCase();
    if (t == 'image') return true;
    final lower = url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  static bool _isVideoAttachment(String? url, String? type) {
    if (url == null || url.trim().isEmpty) return false;
    final t = (type ?? '').toLowerCase();
    if (t == 'video') return true;
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv');
  }

  static bool _isPdfAttachment(String? url, String? type) {
    if (url == null || url.trim().isEmpty) return false;
    final t = (type ?? '').toLowerCase();
    if (t == 'pdf') return true;
    final lower = url.toLowerCase();
    return lower.endsWith('.pdf');
  }

  static String _formatTime12h(DateTime t) {
    final hour = t.hour > 12
        ? t.hour - 12
        : (t.hour == 0 ? 12 : t.hour);
    final amPm = t.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $amPm';
  }

  static String _formatDateArabic(DateTime t) {
    return DateFormat('d MMMM y', 'ar').format(t.toLocal());
  }

  static void _showFullScreenImage(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.of(ctx).pop(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  width: MediaQuery.sizeOf(ctx).width,
                  height: MediaQuery.sizeOf(ctx).height,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showFullScreenVideo(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _VideoPlayerDialog(videoUrl: url),
    );
  }

  static String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final segs = uri.pathSegments;
      if (segs.isNotEmpty) return segs.last;
    } catch (_) {}
    final parts = url.split('/');
    return parts.isNotEmpty ? parts.last : url;
  }

  static Future<void> _openPdfInBrowser(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      Get.snackbar('PDF', 'Invalid PDF url', snackPosition: SnackPosition.TOP);
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      Get.snackbar('PDF', 'تعذر فتح ملف الـ PDF', snackPosition: SnackPosition.TOP);
    }
  }

  Widget _buildPdfThumbnail(double maxWidth, VoidCallback onOpen) {
    const double width = 200;
    const double height = 180;
    final name = _extractFileName(fileUrl ?? '');
    return GestureDetector(
      onTap: onOpen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          height: height,
          color: Colors.white.withValues(alpha: 0.06),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Positioned.fill(
                child: Container(
                  color: colors.divider.withValues(alpha: 0.55),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 18,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 56,
                          color: colors.textMuted,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: AppFonts.ffShamelFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.open_in_full_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(double maxWidth, VoidCallback onPlay) {
    const double width = 200;
    const double height = 180;
    return GestureDetector(
      onTap: onPlay,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          height: height,
          color: Colors.black.withValues(alpha: 0.7),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                size: 64,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.open_in_full_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(double maxWidth, VoidCallback? onExpand) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CachedNetworkImage(
            imageUrl: fileUrl!,
            fit: BoxFit.cover,
            width: (maxWidth * 0.78).clamp(160.0, 260.0),
            height: 180,
            placeholder: (_, __) => Container(
              width: 200,
              height: 180,
              color: colors.divider.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 200,
              height: 120,
              color: colors.divider,
              child: Icon(Icons.broken_image_outlined, color: colors.textMuted),
            ),
          ),
          if (onExpand != null)
            GestureDetector(
              onTap: onExpand,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.open_in_full_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isImage = _isImageAttachment(fileUrl, messageType);
    final isVideo = _isVideoAttachment(fileUrl, messageType);
    final isPdf = _isPdfAttachment(fileUrl, messageType);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxBubbleWidth = screenWidth * 0.78;

    if (isFromMe) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'أنت',
                    style: const TextStyle(
                      fontFamily: AppFonts.ffShamelFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textDirection: ui.TextDirection.rtl,
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.done_all_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isImage)
                _buildImageThumbnail(
                  screenWidth,
                  () => _showFullScreenImage(context, fileUrl!),
                )
              else if (isVideo)
                _buildVideoThumbnail(
                  screenWidth,
                  () => _showFullScreenVideo(context, fileUrl!),
                )
              else if (isPdf)
                _buildPdfThumbnail(
                  screenWidth,
                  () {
                    _openPdfInBrowser(fileUrl!);
                  },
                )
              else
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
                        textDirection: ui.TextDirection.rtl,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: ui.TextDirection.ltr,
                children: [
                  Text(
                    _formatDateArabic(timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    textDirection: ui.TextDirection.rtl,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime12h(timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    textDirection: ui.TextDirection.ltr,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.9,
        ),
        decoration: BoxDecoration(
          color: bubbleOutColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: colors.black.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (senderName.trim().isNotEmpty) ...[
              Text(
                senderName.trim(),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: AppFonts.ffShamelFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textDark,
                  height: 1.35,
                ),
                textDirection: ui.TextDirection.rtl,
              ),
              const SizedBox(height: 6),
            ],
            if (isImage)
              _buildImageThumbnail(
                screenWidth,
                () => _showFullScreenImage(context, fileUrl!),
              )
            else if (isVideo)
              _buildVideoThumbnail(
                screenWidth,
                () => _showFullScreenVideo(context, fileUrl!),
              )
            else if (isPdf)
              _buildPdfThumbnail(
                screenWidth,
                () {
                  _openPdfInBrowser(fileUrl!);
                },
              )
            else
              Text(
                text,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: AppFonts.ffShamelFamily,
                  fontSize: 16,
                  color: colors.textDark,
                  height: 1.45,
                ),
                textDirection: ui.TextDirection.rtl,
              ),
            const SizedBox(height: 14),
            Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: ui.TextDirection.ltr,
              children: [
                Text(
                  _formatDateArabic(timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                  textDirection: ui.TextDirection.rtl,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime12h(timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                  textDirection: ui.TextDirection.ltr,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlayerDialog extends StatefulWidget {
  const _VideoPlayerDialog({required this.videoUrl});

  final String videoUrl;

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
          _controller.setLooping(false);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 8,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.textController,
    required this.onSend,
    required this.onAttach,
    required this.enabled,
    required this.attachmentsEnabled,
    required this.colors,
    required this.sendButtonBg,
    required this.sendButtonIcon,
  });

  final TextEditingController textController;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final bool enabled;
  final bool attachmentsEnabled;
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
              textAlign: TextAlign.right,
              controller: textController,
              textDirection: ui.TextDirection.rtl,
              maxLines: 4,
              minLines: 1,
              enabled: enabled,
              decoration: InputDecoration(
                hintText: '…اكتب رسالة',
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
              onSubmitted: enabled ? (_) => onSend() : null,
            ),
          ),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(vertical: 12),
            color: colors.divider,
          ),

          IconButton(
            onPressed: attachmentsEnabled ? onAttach : null,
            icon: Icon(
              Icons.attach_file_rounded,
              color: attachmentsEnabled
                  ? colors.textDark
                  : colors.textMuted,
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
                onTap: enabled ? onSend : null,
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
    required this.sessionId,
    required this.peerName,
    required this.peerImageUrl,
    required this.sessionData,
  });

  final ChatController controller;
  final ColorManager colors;
  final String sessionId;
  final String peerName;
  final String? peerImageUrl;
  final JsonMap? sessionData;

  @override
  State<_CloseChatReasonSheet> createState() =>
      _CloseChatReasonSheetState();
}

class _CloseChatReasonSheetState
    extends State<_CloseChatReasonSheet> {
  static const Color _closeRed = Color(0xFFD10009);
  static const Color _sheetBackground = Color(0xFFF7F6F3);
  static const Color _tileBorder = Color(0xFFEFEEEB);
  static const Color _tileShadow = Color(0x14000000);
  static const Color _mutedText = Color(0xFF98938D);

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

  JsonMap? get _resolvedSessionData =>
      widget.sessionData ??
      widget.controller.getCallCenterSessionById(widget.sessionId);

  String get _startedAtLabel {
    final session = _resolvedSessionData;
    final rawCandidates = [
      session?['started_at'],
      session?['created_at'],
      session?['assigned_at'],
      session?['accepted_at'],
      session?['updated_at'],
    ];

    String? rawValue;
    for (final candidate in rawCandidates) {
      final normalized = candidate?.toString().trim();
      if (normalized != null &&
          normalized.isNotEmpty &&
          normalized.toLowerCase() != 'null') {
        rawValue = normalized;
        break;
      }
    }

    if (rawValue == null) return 'تم بدء الجلسة حديثاً';

    final parsed = DateTime.tryParse(rawValue);
    if (parsed == null) return rawValue;

    final formatted = DateFormat(
      'd MMMM y',
      'ar',
    ).format(parsed.toLocal());
    return 'تم البدء في $formatted';
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              'إغلاق الجلسة',
              style: AppTypography.bodyM.bold.copyWith(
                fontFamily: AppFonts.ffShamelFamily,
                color: widget.colors.textDark,
                fontSize: 18,
              ),
              textDirection: ui.TextDirection.rtl,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: () => Navigator.pop(context, null),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                Icons.close_rounded,
                color: widget.colors.infoBlue,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCard() {
    final imageUrl = widget.peerImageUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: widget.colors.forceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: _tileShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: hasImage
                ? null
                : widget.colors.primary.withValues(alpha: 0.10),
            backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
            child: hasImage
                ? null
                : Icon(
                    Icons.person_rounded,
                    color: widget.colors.infoBlue,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.peerName.trim().isNotEmpty
                      ? widget.peerName.trim()
                      : 'الطالب',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyM.bold.copyWith(
                    fontFamily: AppFonts.ffShamelFamily,
                    color: widget.colors.textDark,
                  ),
                  textDirection: ui.TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 2),
                Text(
                  _startedAtLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionM.copyWith(
                    fontFamily: AppFonts.ffShamelFamily,
                    color: _mutedText,
                  ),
                  textDirection: ui.TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioIndicator(bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isSelected
            ? _closeRed.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? _closeRed
                  : widget.colors.divider.withValues(alpha: 0.95),
              width: isSelected ? 1.8 : 1.2,
            ),
          ),
          child: isSelected
              ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _closeRed,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildReasonTile(JsonMap reason) {
    final id = reason['id']?.toString() ?? '';
    final name = reason['name']?.toString().trim() ?? '';
    final isSelected = _selectedReasonId == id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          setState(() {
            _selectedReasonId = id;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: widget.colors.forceWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? _closeRed.withValues(alpha: 0.35)
                  : _tileBorder,
            ),
            boxShadow: const [
              BoxShadow(
                color: _tileShadow,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildRadioIndicator(isSelected),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyS.semiBold.copyWith(
                    fontFamily: AppFonts.ffShamelFamily,
                    color: isSelected
                        ? _closeRed
                        : widget.colors.textDark,
                    height: 1.3,
                  ),
                  textDirection: ui.TextDirection.rtl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: widget.colors.safe),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: AppTypography.bodyS.copyWith(
            color: widget.colors.error,
            fontFamily: AppFonts.ffShamelFamily,
          ),
          textDirection: ui.TextDirection.rtl,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_reasons.isEmpty) {
      return Center(
        child: Text(
          'لا توجد أسباب متاحة للإغلاق',
          style: AppTypography.bodyS.copyWith(
            color: widget.colors.textMuted,
            fontFamily: AppFonts.ffShamelFamily,
          ),
          textDirection: ui.TextDirection.rtl,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: _reasons.length,
      shrinkWrap: true,
      primary: false,
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) =>
          const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildReasonTile(_reasons[index]),
    );
  }

  Widget _buildBodySection(double screenHeight) {
    if (_isLoading || _errorMessage != null || _reasons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: _buildSheetBody(),
      );
    }

    return Flexible(
      fit: FlexFit.loose,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.34),
        child: _buildSheetBody(),
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      width: 54,
      height: 54,
      child: Material(
        color: const ui.Color.fromARGB(255, 219, 219, 219),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.pop(context, null),
          child: Center(
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: widget.colors.textDark.withValues(alpha: 0.82),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
                if (_selectedReasonId != null) {
                  Navigator.pop(context, _selectedReasonId);
                  return;
                }

                Navigator.pop(
                  context,
                  _ChatSessionScreenState._noCloseReasonSentinel,
                );
              },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: widget.colors.safe,
          foregroundColor: widget.colors.forceWhite,
          disabledBackgroundColor: widget.colors.safe.withValues(
            alpha: 0.45,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تأكيد ومتابعة',
              style: AppTypography.bodyM.semiBold.copyWith(
                fontFamily: AppFonts.ffShamelFamily,
                color: widget.colors.forceWhite,
              ),
              textDirection: ui.TextDirection.rtl,
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: widget.colors.forceWhite.withValues(alpha: 0.96),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.80,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
              decoration: const BoxDecoration(
                color: _sheetBackground,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(34),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _buildParticipantCard(),
                  const SizedBox(height: 18),
                  Text(
                    'يرجى تحديد سبب إغلاق الجلسة المذكورة مع بيان السبب التوضيحي إن أمكن:',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyS.copyWith(
                      fontFamily: AppFonts.ffShamelFamily,
                      color: const ui.Color.fromARGB(255, 0, 0, 0),
                      height: 1.45,
                    ),
                    textDirection: ui.TextDirection.rtl,
                  ),
                  const SizedBox(height: 18),
                  _buildBodySection(screenHeight),
                  const SizedBox(height: 18),
                  Row(
                    textDirection: ui.TextDirection.ltr,
                    children: [
                      _buildBackButton(),
                      const SizedBox(width: 14),
                      Expanded(child: _buildConfirmButton()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
