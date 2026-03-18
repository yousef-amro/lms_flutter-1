import 'dart:developer';

import 'package:get/get.dart';

import '../../../../core/cache/local_storage_service.dart';
import '../../../../core/services/chat_websocket_service.dart';

typedef JsonMap = Map<String, dynamic>;

class ChatController extends GetxController {
  final ChatWebSocketService _ws;

  ChatController({required ChatWebSocketService ws}) : _ws = ws;

  final isConnected = false.obs;
  final role = RxnString();
  final userId = RxnString();
  final userName = RxnString();
  final currentSessionId = RxnString();
  final allowAttachments = false.obs;

  final messages = <JsonMap>[].obs;
  final incomingRequests = <JsonMap>[].obs;
  /// Sessions this agent has accepted (persisted so they survive app restart).
  final assignedSessions = <Map<String, String>>[].obs;
  final recentEventTypes = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAssignedSessions();
    _ws.isConnectedStream.listen((v) => isConnected.value = v);
    _ws.events.listen(_handleEvent);
    connect();
  }

  void _loadAssignedSessions() {
    final stored = LocalStorageService().getAssignedChatSessions();
    assignedSessions.assignAll(stored);
  }

  Future<void> _persistAssignedSessions() async {
    await LocalStorageService().setAssignedChatSessions(assignedSessions.toList());
  }

  Future<void> connect() async {
    try {
      await _ws.connect();
    } catch (e) {
      log('ChatController: connect failed: $e');
    }
  }

  Future<void> requestChat({required String nodeId}) async {
    await _ws.sendAction('request_chat', {'node_id': nodeId});
  }

  Future<void> acceptChat({required String sessionId}) async {
    await _ws.sendAction('accept_chat', {'session_id': sessionId});
  }

  Future<void> sendText({required String sessionId, required String text}) async {
    await _ws.sendAction('send_message', {'session_id': sessionId, 'text': text});
  }

  Future<void> closeChat({required String sessionId, String? closeReasonId}) async {
    final payload = <String, dynamic>{'session_id': sessionId};
    if (closeReasonId != null) {
      payload['close_reason_id'] = closeReasonId;
    }
    await _ws.sendAction('close_chat', payload);
    // Remove from lists immediately so UI updates when user navigates back
    incomingRequests.removeWhere(
      (r) => r['session_id']?.toString() == sessionId,
    );
    assignedSessions.removeWhere((s) => s['session_id'] == sessionId);
    _persistAssignedSessions();
  }

  Future<void> setAttachmentPermission({
    required String sessionId,
    required bool allow,
  }) async {
    await _ws.sendAction('set_attachment_permission', {
      'session_id': sessionId,
      'allow': allow,
    });
  }

  void _handleEvent(JsonMap event) {
    final type = event['type']?.toString();
    if (type == null) return;

    recentEventTypes.insert(0, type);
    if (recentEventTypes.length > 12) {
      recentEventTypes.removeRange(12, recentEventTypes.length);
    }

    switch (type) {
      case 'connected':
        role.value = event['role']?.toString();
        if (event['user'] is Map) {
          userId.value = event['user']['id']?.toString();
          userName.value = event['user']['full_name']?.toString();
        } else {
          userId.value = null;
          userName.value = null;
        }
        final current = event['current_session'];
        if (current is Map) {
          currentSessionId.value = current['session_id']?.toString();
          allowAttachments.value = current['allow_attachments'] == true;
        }
        break;

      case 'new_chat_request':
        // Call center only
        incomingRequests.insert(0, event);
        break;

      case 'chat_request_created':
        currentSessionId.value = event['session_id']?.toString();
        final session = event['session'];
        if (session is Map) {
          allowAttachments.value = session['allow_attachments'] == true;
        }
        break;

      case 'chat_assigned':
        if (event['assigned_to_other'] == true) {
          // ignore for now (other agents)
          break;
        }
        final sessionId = event['session_id']?.toString();
        currentSessionId.value = sessionId;
        final session = event['session'];
        if (session is Map) {
          allowAttachments.value = session['allow_attachments'] == true;
        }
        // Persist this accepted session so it survives app restart
        if (sessionId != null && sessionId.isNotEmpty) {
          JsonMap? request;
          for (final r in incomingRequests) {
            if (r['session_id']?.toString() == sessionId) {
              request = r;
              break;
            }
          }
          String peerName = '';
          String nodeTitle = '';
          if (request != null) {
            final student = request['student'];
            peerName = student is Map
                ? (student['full_name']?.toString() ?? '')
                : '';
            nodeTitle = request['node_title']?.toString() ?? '';
            incomingRequests.removeWhere(
              (r) => r['session_id']?.toString() == sessionId,
            );
          }
          final entry = <String, String>{
            'session_id': sessionId,
            'peer_name': peerName,
            'node_title': nodeTitle,
          };
          assignedSessions.removeWhere(
            (s) => s['session_id'] == sessionId,
          );
          assignedSessions.insert(0, entry);
          _persistAssignedSessions();
        }
        break;

      case 'message_sent':
      case 'new_message':
        final msg = event['message'];
        if (msg is Map<String, dynamic>) {
          messages.add(msg);
        }
        break;

      case 'attachment_permission_changed':
        allowAttachments.value = event['allow'] == true;
        break;

      case 'chat_closed':
        final closedSessionId = event['session_id']?.toString();
        if (closedSessionId == currentSessionId.value) {
          currentSessionId.value = null;
        }
        if (closedSessionId != null && closedSessionId.isNotEmpty) {
          incomingRequests.removeWhere(
            (r) => r['session_id']?.toString() == closedSessionId,
          );
          assignedSessions.removeWhere(
            (s) => s['session_id'] == closedSessionId,
          );
          _persistAssignedSessions();
        }
        break;

      case 'error':
        final message = event['message']?.toString() ?? 'error';
        Get.snackbar('WS', message, snackPosition: SnackPosition.TOP);
        break;
    }
  }

  void openSession(String sessionId, {String? peerName}) {
    currentSessionId.value = sessionId;
    messages.clear();
    Get.toNamed(
      '/chat/session',
      arguments: {
        'session_id': sessionId,
        if (peerName != null && peerName.isNotEmpty) 'peer_name': peerName,
      },
    );
  }

  // Keep socket alive globally; don't disconnect here.
}

