import 'dart:collection';
import 'dart:developer';

import 'package:get/get.dart';

import '../../../../core/cache/local_storage_service.dart';
import '../../../../core/data/networking/data/network_request.dart';
import '../../../../core/data/networking/data/network_response.dart';
import '../../../../core/data/networking/data/network_router.dart';
import '../../../../core/data/networking/network_adapter.dart';
import '../../../../core/services/chat_websocket_service.dart';

typedef JsonMap = Map<String, dynamic>;

class ChatController extends GetxController {
  final ChatWebSocketService _ws;
  final NetworkAdapterAbstraction _network;

  ChatController({
    required ChatWebSocketService ws,
    required NetworkAdapterAbstraction network,
  }) : _ws = ws,
       _network = network;

  final isConnected = false.obs;
  final role = RxnString();
  final userId = RxnString();
  final userName = RxnString();
  final currentSessionId = RxnString();
  final allowAttachments = false.obs;

  final messages = <JsonMap>[].obs;
  final isLoadingMessages = false.obs;
  final incomingRequests = <JsonMap>[].obs;
  /// Sessions this agent has accepted (persisted so they survive app restart).
  final assignedSessions = <Map<String, String>>[].obs;
  /// All call-center sessions fetched from REST API.
  final callCenterSessions = <JsonMap>[].obs;
  final isLoadingCallCenterSessions = false.obs;
  final recentEventTypes = <String>[].obs;

  /// Avoid duplicates when backend emits both `message_sent` and `new_message`.
  final LinkedHashSet<String> _seenMessageKeys = LinkedHashSet<String>();

  @override
  void onInit() {
    super.onInit();
    _loadAssignedSessions();
    loadCallCenterSessions();
    _ws.isConnectedStream.listen((v) => isConnected.value = v);
    _ws.events.listen(_handleEvent);
    connect();
  }

  Future<void> refreshHome() async {
    _loadAssignedSessions();
    await loadCallCenterSessions();
    if (!isConnected.value) {
      await connect();
    }
  }

  void _addMessageDedup(JsonMap msg) {
    final key = _messageKey(msg);
    if (key.isNotEmpty) {
      if (_seenMessageKeys.contains(key)) return;
      _seenMessageKeys.add(key);
      if (_seenMessageKeys.length > 400) {
        final toRemove = _seenMessageKeys.length - 250;
        for (var i = 0; i < toRemove; i++) {
          _seenMessageKeys.remove(_seenMessageKeys.first);
        }
      }
    }
    messages.add(msg);
  }

  String _messageKey(JsonMap msg) {
    final directId = msg['id']?.toString() ?? msg['message_id']?.toString();
    if (directId != null && directId.trim().isNotEmpty) {
      return 'id:${directId.trim()}';
    }

    final sender = msg['sender'];
    final senderId = (sender is Map) ? sender['id']?.toString() : null;
    final sessionId = msg['session_id']?.toString() ?? currentSessionId.value;
    final text = (msg['text']?.toString() ?? '').trim();
    final fileUrl = (msg['file_url']?.toString() ?? '').trim();
    final sentAt = msg['sent_at']?.toString() ?? '';

    final composite = [
      if (sessionId != null) sessionId.trim(),
      if (senderId != null) senderId.trim(),
      text,
      fileUrl,
      sentAt.trim(),
    ].where((e) => e.isNotEmpty).join('|');

    return composite.isEmpty ? '' : 'c:$composite';
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

  Future<void> loadCallCenterSessions() async {
    if (isLoadingCallCenterSessions.value) return;
    isLoadingCallCenterSessions.value = true;
    try {
      final res = await _network.request(
        NetworkRequest(
          route: NetworkRouter.callCenterSessions,
          requestType: RequestType.get,
          isAuthorizationRequired: true,
        ),
      );

      if (res.status == NetworkResponseStatus.success) {
        final raw = res.data;
        List list = const [];
        if (raw is List) {
          list = raw;
        } else if (raw is Map && raw['data'] is List) {
          // backend shape: { next, previous, count, data: [...] }
          list = raw['data'] as List;
        } else if (raw is Map && raw['results'] is List) {
          // common pagination shape
          list = raw['results'] as List;
        }

        final normalized = <JsonMap>[];
        for (final item in list.whereType<Map>()) {
          final m = Map<String, dynamic>.from(item);
          final sessionId = m['id']?.toString() ?? m['session_id']?.toString();
          final student = m['student'];
          final peerName = student is Map
              ? (student['full_name']?.toString() ?? '')
              : (m['peer_name']?.toString() ?? '');
          final lastMessage = m['last_message'];
          final nodeTitleFromLast =
              lastMessage is Map ? (lastMessage['text']?.toString() ?? '') : '';
          normalized.add({
            ...m,
            // Keep compatibility with existing UI code that expects these keys.
            'session_id': sessionId ?? '',
            'peer_name': peerName,
            'node_title': (m['node_title']?.toString() ?? nodeTitleFromLast),
          });
        }
        callCenterSessions.assignAll(normalized);
      } else {
        log(
          'ChatController: loadCallCenterSessions failed: ${res.failure?.message}',
        );
      }
    } catch (e) {
      log('ChatController: loadCallCenterSessions exception: $e');
    } finally {
      isLoadingCallCenterSessions.value = false;
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

  Future<void> loadSessionMessages({required String sessionId}) async {
    if (sessionId.trim().isEmpty) return;
    if (isLoadingMessages.value) return;
    isLoadingMessages.value = true;
    try {
      final res = await _network.request(
        NetworkRequest(
          route: NetworkRouter.callCenterSessions,
          urlIdentifier: '/$sessionId/messages',
          requestType: RequestType.get,
          isAuthorizationRequired: true,
        ),
      );

      if (res.status == NetworkResponseStatus.success) {
        final raw = res.data;
        List list = const [];
        if (raw is List) {
          list = raw;
        } else if (raw is Map) {
          // Common backend shapes (including nested pagination).
          if (raw['data'] is List) {
            list = raw['data'] as List;
          } else if (raw['results'] is List) {
            list = raw['results'] as List;
          } else if (raw['messages'] is List) {
            list = raw['messages'] as List;
          } else if (raw['messages'] is Map) {
            // backend shape: { session: {...}, messages: { next, ..., data: [...] } }
            final m = raw['messages'] as Map;
            if (m['data'] is List) {
              list = m['data'] as List;
            } else if (m['results'] is List) {
              list = m['results'] as List;
            }
          } else if (raw['data'] is Map) {
            final inner = raw['data'] as Map;
            if (inner['data'] is List) {
              list = inner['data'] as List;
            } else if (inner['results'] is List) {
              list = inner['results'] as List;
            } else if (inner['messages'] is List) {
              list = inner['messages'] as List;
            } else if (inner['messages'] is Map) {
              final im = inner['messages'] as Map;
              if (im['data'] is List) {
                list = im['data'] as List;
              } else if (im['results'] is List) {
                list = im['results'] as List;
              }
            }
          }
        }

        final fetchedList = list.whereType<Map>().map((e) {
          final msg = Map<String, dynamic>.from(e);
          // Normalize keys so existing UI can render timestamps + dedupe reliably.
          msg['session_id'] ??= sessionId;
          msg['sent_at'] ??= msg['created_at'];
          return msg;
        }).toList();

        DateTime parseTime(dynamic v) {
          if (v is DateTime) return v;
          if (v is String) return DateTime.tryParse(v) ?? DateTime(0);
          return DateTime(0);
        }

        fetchedList.sort((a, b) {
          final ta = parseTime(a['created_at'] ?? a['sent_at']);
          final tb = parseTime(b['created_at'] ?? b['sent_at']);
          return ta.compareTo(tb);
        });

        messages.assignAll(fetchedList);
        _seenMessageKeys.clear();
        for (final m in fetchedList) {
          final k = _messageKey(m);
          if (k.isNotEmpty) _seenMessageKeys.add(k);
        }

        if (fetchedList.isEmpty) {
          log(
            'ChatController: loadSessionMessages success but empty. rawType=${raw.runtimeType} keys=${raw is Map ? raw.keys.toList() : '—'}',
          );
        }
      } else {
        log('ChatController: loadSessionMessages failed.');
        log('ChatController: status=failure message=${res.failure?.message}');
        if (res.data != null) {
          log('ChatController: failure data=${res.data}');
        }
      }
    } catch (e) {
      log('ChatController: loadSessionMessages exception: $e');
    } finally {
      isLoadingMessages.value = false;
    }
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
          _addMessageDedup(msg);
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
    _seenMessageKeys.clear();
    // Fetch old messages from REST so the chat isn't empty on open.
    loadSessionMessages(sessionId: sessionId);
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

