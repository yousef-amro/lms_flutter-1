import 'dart:collection';
import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide MultipartFile;

import '../../../../environments/app_environments.dart';
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

  /// Peer profile image URL for the current chat session (from session.student or session.call_center).
  final currentSessionPeerImage = RxnString();
  final incomingRequests = <JsonMap>[].obs;

  /// Sessions this agent has accepted (persisted so they survive app restart).
  final assignedSessions = <Map<String, String>>[].obs;

  /// All call-center sessions fetched from REST API.
  final callCenterSessions = <JsonMap>[].obs;
  final isLoadingCallCenterSessions = false.obs;
  final callCenterSessionsUpdated = 0.obs;

  final isLoadingCallCenterDashboard = false.obs;
  final callCenterWaitingCount = 0.obs;
  final callCenterActiveCount = 0.obs;
  final callCenterClosedCount = 0.obs;

  /// Bump when assignedSessions are updated with API data (e.g. peer_image) so list avatars rebuild.
  final assignedSessionsUpdated = 0.obs;
  final recentEventTypes = <String>[].obs;

  /// Avoid duplicates when backend emits both `message_sent` and `new_message`.
  final LinkedHashSet<String> _seenMessageKeys =
      LinkedHashSet<String>();
  final Set<String> _peerImageHydrationInFlight = <String>{};

  @override
  void onInit() {
    super.onInit();
    _loadAssignedSessions();
    loadCallCenterSessions();
    refreshCallCenterDashboard();
    _ws.isConnectedStream.listen((v) => isConnected.value = v);
    _ws.events.listen(_handleEvent);
    connect();
  }

  Future<void> refreshHome() async {
    _loadAssignedSessions();
    await loadCallCenterSessions();
    await refreshCallCenterDashboard();
    if (!isConnected.value) {
      await connect();
    }
  }

  Future<void> refreshCallCenterDashboard() async {
    if (isLoadingCallCenterDashboard.value) return;

    isLoadingCallCenterDashboard.value = true;
    try {
      final res = await _network.request(
        NetworkRequest(
          route: NetworkRouter.callCenterDashboard,
          requestType: RequestType.get,
          isAuthorizationRequired: true,
        ),
      );

      if (res.status != NetworkResponseStatus.success) return;
      final raw = res.data;
      if (raw is! Map) return;

      callCenterWaitingCount.value = _intFromJson(raw['waiting_count']);
      callCenterActiveCount.value = _intFromJson(raw['active_count']);
      callCenterClosedCount.value = _intFromJson(raw['closed_count']);
    } catch (e) {
      log('ChatController: refreshCallCenterDashboard exception: $e');
    } finally {
      isLoadingCallCenterDashboard.value = false;
    }
  }

  int _intFromJson(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = v?.toString();
    if (s == null) return 0;
    return int.tryParse(s) ?? 0;
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
    final directId =
        msg['id']?.toString() ?? msg['message_id']?.toString();
    if (directId != null && directId.trim().isNotEmpty) {
      return 'id:${directId.trim()}';
    }

    final sender = msg['sender'];
    final senderId = (sender is Map)
        ? sender['id']?.toString()
        : null;
    final sessionId =
        msg['session_id']?.toString() ?? currentSessionId.value;
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
    assignedSessions.assignAll(
      stored
          .map(
            (session) => {
              ...session,
              'peer_image':
                  _normalizeMediaUrl(session['peer_image']) ?? '',
            },
          )
          .toList(),
    );
  }

  Future<void> _persistAssignedSessions() async {
    await LocalStorageService().setAssignedChatSessions(
      assignedSessions.toList(),
    );
  }

  String? _normalizeMediaUrl(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    final baseUrl = AppEnvironmentHelper()
        .getEnvironmentVariable('BASE_URL')
        ?.toString()
        .trim();
    if (baseUrl == null || baseUrl.isEmpty) {
      return raw;
    }

    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = raw.startsWith('/') ? raw : '/$raw';
    return '$normalizedBase$normalizedPath';
  }

  JsonMap? getCallCenterSessionById(String? sessionId) {
    final id = sessionId?.trim() ?? '';
    if (id.isEmpty) return null;
    return callCenterSessions.firstWhereOrNull((session) {
      final currentId =
          (session['session_id'] ?? session['id']?.toString() ?? '')
              .toString()
              .trim();
      return currentId == id;
    });
  }

  String? _extractPeerImageFromSessionMap(
    Map<dynamic, dynamic>? session,
  ) {
    if (session == null) return null;

    final student = session['student'];
    if (student is Map) {
      final studentImage = _normalizeMediaUrl(
        student['image']?.toString(),
      );
      if (studentImage != null && studentImage.isNotEmpty)
        return studentImage;
    }

    final directPeerImage = _normalizeMediaUrl(
      session['peer_image']?.toString(),
    );
    if (directPeerImage != null && directPeerImage.isNotEmpty) {
      return directPeerImage;
    }

    final lastMessage = session['last_message'];
    if (lastMessage is Map) {
      final receiver = lastMessage['receiver'];
      if (receiver is Map) {
        final receiverImage = _normalizeMediaUrl(
          receiver['image']?.toString(),
        );
        if (receiverImage != null && receiverImage.isNotEmpty) {
          return receiverImage;
        }
      }
      final sender = lastMessage['sender'];
      if (sender is Map) {
        final senderImage = _normalizeMediaUrl(
          sender['image']?.toString(),
        );
        if (senderImage != null && senderImage.isNotEmpty) {
          return senderImage;
        }
      }
    }

    final callCenter = session['call_center'];
    if (callCenter is Map) {
      final callCenterImage = _normalizeMediaUrl(
        callCenter['image']?.toString(),
      );
      if (callCenterImage != null && callCenterImage.isNotEmpty) {
        return callCenterImage;
      }
    }

    return null;
  }

  String? getPeerImageForSession(
    String? sessionId, {
    Map<dynamic, dynamic>? fallback,
  }) {
    final fromApi = getCallCenterSessionById(sessionId);
    final apiImage = _extractPeerImageFromSessionMap(fromApi);
    if (apiImage != null && apiImage.isNotEmpty) return apiImage;

    final fallbackImage = _extractPeerImageFromSessionMap(fallback);
    if (fallbackImage != null && fallbackImage.isNotEmpty)
      return fallbackImage;

    return null;
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
          final sessionId =
              m['id']?.toString() ?? m['session_id']?.toString();
          final student = m['student'];
          final peerName = student is Map
              ? (student['full_name']?.toString() ?? '')
              : (m['peer_name']?.toString() ?? '');
          final lastMessage = m['last_message'];
          final nodeTitleFromLast = lastMessage is Map
              ? (lastMessage['text']?.toString() ?? '')
              : '';
          final peerImage =
              _normalizeMediaUrl(
                student is Map ? student['image']?.toString() : null,
              ) ??
              '';
          normalized.add({
            ...m,
            // Keep compatibility with existing UI code that expects these keys.
            'session_id': sessionId ?? '',
            'peer_name': peerName,
            'node_title':
                (m['node_title']?.toString() ?? nodeTitleFromLast),
            'peer_image': peerImage,
            if (student is Map)
              'student': {
                ...Map<String, dynamic>.from(student),
                'image': peerImage.isNotEmpty
                    ? peerImage
                    : _normalizeMediaUrl(
                        student['image']?.toString(),
                      ),
              },
          });
        }
        callCenterSessions.assignAll(normalized);
        callCenterSessionsUpdated.value++;
        // Merge peer_image (and name/title) into assignedSessions so avatars show immediately and after next app open.
        _mergeApiSessionDataIntoAssigned(normalized);
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

  void _applyPeerImageUpdate({
    required String sessionId,
    required String peerImage,
  }) {
    final id = sessionId.trim();
    final img = _normalizeMediaUrl(peerImage)?.trim() ?? '';
    if (id.isEmpty || img.isEmpty) return;

    var assignedChanged = false;
    final updatedAssigned = <Map<String, String>>[];
    for (final s in assignedSessions) {
      final sid = (s['session_id'] ?? '').trim();
      if (sid != id) {
        updatedAssigned.add(Map<String, String>.from(s));
        continue;
      }
      final existing = (s['peer_image'] ?? '').trim();
      if (existing == img) {
        updatedAssigned.add(Map<String, String>.from(s));
        continue;
      }
      // Only fill if empty; don't override a non-empty avatar.
      if (existing.isNotEmpty) {
        updatedAssigned.add(Map<String, String>.from(s));
        continue;
      }
      assignedChanged = true;
      updatedAssigned.add({...s, 'peer_image': img});
    }

    if (assignedChanged) {
      assignedSessions.assignAll(updatedAssigned);
      assignedSessionsUpdated.value++;
      _persistAssignedSessions();
    }

    // Update callCenterSessions list item if present (so HomeScreen can pick it up).
    final idx = callCenterSessions.indexWhere((s) {
      final sid = (s['session_id'] ?? s['id']?.toString() ?? '')
          .toString()
          .trim();
      return sid == id;
    });
    if (idx >= 0) {
      final old = callCenterSessions[idx];
      final m = Map<String, dynamic>.from(old);
      final existing = (m['peer_image']?.toString() ?? '').trim();
      if (existing.isEmpty) {
        m['peer_image'] = img;
      }
      final student = m['student'];
      if (student is Map) {
        final st = Map<String, dynamic>.from(student);
        final stImg = (st['image']?.toString() ?? '').trim();
        if (stImg.isEmpty) st['image'] = img;
        m['student'] = st;
      }
      callCenterSessions[idx] = m;
      callCenterSessionsUpdated.value++;
    }

    // Update pending WS requests if we can.
    final rIdx = incomingRequests.indexWhere(
      (r) => r['session_id']?.toString().trim() == id,
    );
    if (rIdx >= 0) {
      final old = incomingRequests[rIdx];
      final m = Map<String, dynamic>.from(old);
      final student = m['student'];
      if (student is Map) {
        final st = Map<String, dynamic>.from(student);
        final stImg = (st['image']?.toString() ?? '').trim();
        if (stImg.isEmpty) st['image'] = img;
        m['student'] = st;
      }
      incomingRequests[rIdx] = m;
    }
  }

  JsonMap? _extractSessionFromMessagesResponse(dynamic raw) {
    if (raw is Map) {
      final direct = raw['session'];
      if (direct is Map) return Map<String, dynamic>.from(direct);
      final data = raw['data'];
      if (data is Map) {
        final s = data['session'];
        if (s is Map) return Map<String, dynamic>.from(s);
        final inner = data['data'];
        if (inner is Map) {
          final ss = inner['session'];
          if (ss is Map) return Map<String, dynamic>.from(ss);
        }
      }
    }
    return null;
  }

  String? _peerImageFromSession(JsonMap session) {
    final student = session['student'];
    final callCenter = session['call_center'];
    final studentImage = _normalizeMediaUrl(
      student is Map ? student['image']?.toString() : null,
    );
    if (studentImage != null && studentImage.isNotEmpty)
      return studentImage;
    final callCenterImage = _normalizeMediaUrl(
      callCenter is Map ? callCenter['image']?.toString() : null,
    );
    if (callCenterImage != null && callCenterImage.isNotEmpty) {
      return callCenterImage;
    }
    return null;
  }

  Future<void> hydratePeerImageForSession(String sessionId) async {
    final id = sessionId.trim();
    if (id.isEmpty) return;
    if (_peerImageHydrationInFlight.contains(id)) return;
    _peerImageHydrationInFlight.add(id);
    try {
      final res = await _network.request(
        NetworkRequest(
          route: NetworkRouter.callCenterSessions,
          urlIdentifier: '/$id/messages',
          requestType: RequestType.get,
          isAuthorizationRequired: true,
        ),
      );
      if (res.status != NetworkResponseStatus.success) return;
      final session = _extractSessionFromMessagesResponse(res.data);
      if (session == null) return;
      final img = _peerImageFromSession(session);
      if (img == null || img.isEmpty) return;
      _applyPeerImageUpdate(sessionId: id, peerImage: img);
    } catch (e) {
      log(
        'ChatController: hydratePeerImageForSession($id) exception: $e',
      );
    } finally {
      _peerImageHydrationInFlight.remove(id);
    }
  }

  void _mergeApiSessionDataIntoAssigned(List<dynamic> apiSessions) {
    final byId = <String, JsonMap>{};
    for (final s in apiSessions) {
      if (s is! Map) continue;
      final id = (s['id'] ?? s['session_id'])?.toString().trim();
      if (id != null && id.isNotEmpty)
        byId[id] = Map<String, dynamic>.from(s);
    }
    if (byId.isEmpty) return;
    final updated = <Map<String, String>>[];
    for (final assigned in assignedSessions) {
      final sessionId = (assigned['session_id'] ?? '').trim();
      if (sessionId.isEmpty) {
        updated.add(Map<String, String>.from(assigned));
        continue;
      }
      final api = byId[sessionId];
      if (api == null) {
        updated.add(Map<String, String>.from(assigned));
        continue;
      }
      final student = api['student'];
      final peerName = student is Map
          ? (student['full_name']?.toString() ?? '').trim()
          : (api['peer_name']?.toString() ?? '').trim();
      final peerImage =
          _normalizeMediaUrl(
            student is Map
                ? student['image']?.toString()
                : api['peer_image']?.toString(),
          ) ??
          '';
      final lastMessage = api['last_message'];
      final nodeTitle = lastMessage is Map
          ? (lastMessage['text']?.toString() ?? '').trim()
          : (api['node_title']?.toString() ?? '').trim();
      updated.add({
        'session_id': sessionId,
        'peer_name': peerName.isNotEmpty
            ? peerName
            : (assigned['peer_name'] ?? ''),
        'node_title': nodeTitle.isNotEmpty
            ? nodeTitle
            : (assigned['node_title'] ?? ''),
        'peer_image': peerImage.isNotEmpty
            ? peerImage
            : (assigned['peer_image'] ?? ''),
      });
    }
    if (updated.isNotEmpty) {
      assignedSessions.assignAll(updated);
      assignedSessionsUpdated.value++;
      _persistAssignedSessions();
    }
  }

  String _previewTextFromMessage(JsonMap msg) {
    final text = msg['text']?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
    final fileUrl = msg['file_url']?.toString().trim() ?? '';
    if (fileUrl.isNotEmpty) return 'تم إرسال ملف';
    return msg['message_type']?.toString().trim() ?? '';
  }

  /// Update "chat list" preview text immediately when a new message is sent/received.
  /// Otherwise `home_screen.dart` keeps showing the old `node_title` until API refresh or open chat.
  void _updateChatListPreviewFromMessage(JsonMap msg) {
    final rawSessionId = msg['session_id']?.toString();
    final sessionId = (rawSessionId ?? currentSessionId.value)
        ?.trim();
    if (sessionId == null || sessionId.isEmpty) return;

    final preview = _previewTextFromMessage(msg);
    if (preview.isEmpty) return;

    var changed = false;

    // Update "assigned" rows (persisted).
    for (var i = 0; i < assignedSessions.length; i++) {
      if (assignedSessions[i]['session_id'] == sessionId) {
        final updated = Map<String, String>.from(assignedSessions[i]);
        updated['node_title'] = preview;
        assignedSessions[i] = updated;
        changed = true;
      }
    }

    // Update callCenterSessions so home_screen can show `fromApi['node_title']`.
    for (var i = 0; i < callCenterSessions.length; i++) {
      final s = callCenterSessions[i];
      final id = (s['session_id'] ?? s['id']?.toString())
          .toString()
          .trim();
      if (id == sessionId) {
        final updated = Map<String, dynamic>.from(s);
        updated['node_title'] = preview;
        callCenterSessions[i] = updated;
        changed = true;
      }
    }

    // Update "incoming" rows.
    for (var i = 0; i < incomingRequests.length; i++) {
      final r = incomingRequests[i];
      final id = r['session_id']?.toString().trim();
      if (id == sessionId) {
        final updated = Map<String, dynamic>.from(r);
        updated['node_title'] = preview;
        incomingRequests[i] = updated;
        changed = true;
      }
    }

    if (!changed) return;
    assignedSessionsUpdated.value++;
    callCenterSessions.refresh();
    assignedSessions.refresh();
    incomingRequests.refresh();
  }

  Future<void> requestChat({required String nodeId}) async {
    await _ws.sendAction('request_chat', {'node_id': nodeId});
  }

  Future<void> acceptChat({required String sessionId}) async {
    await _ws.sendAction('accept_chat', {'session_id': sessionId});
    // Best-effort: counts usually change immediately after accepting.
    unawaited(refreshCallCenterDashboard());
  }

  Future<void> sendText({
    required String sessionId,
    required String text,
  }) async {
    await _ws.sendAction('send_message', {
      'session_id': sessionId,
      'text': text,
    });
  }

  Future<String> uploadChatAttachment({
    required String sessionId,
    required String filePath,
    String? fileName,
  }) async {
    final normalizedSessionId = sessionId.trim();
    if (normalizedSessionId.isEmpty) {
      throw Exception('Missing session_id');
    }

    final normalizedPath = filePath.trim();
    if (normalizedPath.isEmpty) {
      throw Exception('Missing file path');
    }

    final pickedName = (fileName ?? '').trim();
    final safeName = pickedName.isNotEmpty
        ? pickedName
        : normalizedPath.split(RegExp(r'[\\/]')).last;

    final res = await _network.request(
      NetworkRequest(
        route: NetworkRouter.chatUpload,
        requestType: RequestType.post,
        isAuthorizationRequired: true,
        isFormData: true,
        data: {'session_id': normalizedSessionId},
        files: [
          MapEntry(
            'file',
            await MultipartFile.fromFile(
              normalizedPath,
              filename: safeName.isNotEmpty ? safeName : null,
            ),
          ),
        ],
      ),
    );

    if (res.status != NetworkResponseStatus.success) {
      final message = res.failure?.message ?? 'Failed to upload file';
      throw Exception(message);
    }

    final raw = res.data;
    if (raw is Map<String, dynamic>) {
      final id = raw['id']?.toString().trim();
      if (id != null && id.isNotEmpty) return id;

      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        final nestedId = data['id']?.toString().trim();
        if (nestedId != null && nestedId.isNotEmpty) return nestedId;
      }
    }

    throw Exception('Upload succeeded but attachment id is missing');
  }

  Future<void> sendAttachment({
    required String sessionId,
    required String attachmentId,
  }) async {
    await _ws.sendAction('send_message', {
      'session_id': sessionId,
      'attachment_id': attachmentId,
    });
  }

  void _markCallCenterSessionClosed(String sessionId) {
    final id = sessionId.trim();
    if (id.isEmpty) return;
    final idx = callCenterSessions.indexWhere((s) {
      final sid = (s['session_id'] ?? s['id']?.toString() ?? '')
          .toString()
          .trim();
      return sid == id;
    });
    if (idx < 0) return;
    final m = Map<String, dynamic>.from(callCenterSessions[idx]);
    m['status'] = 'closed';
    callCenterSessions[idx] = m;
    callCenterSessionsUpdated.value++;
  }

  Future<void> closeChat({
    required String sessionId,
    String? closeReasonId,
  }) async {
    final payload = <String, dynamic>{'session_id': sessionId};
    if (closeReasonId != null) {
      payload['close_reason_id'] = closeReasonId;
    }
    await _ws.sendAction('close_chat', payload);
    // Home list reads [callCenterSessions]; keep row and show "closed" without waiting for REST.
    _markCallCenterSessionClosed(sessionId);
    // Remove from lists immediately so UI updates when user navigates back
    incomingRequests.removeWhere(
      (r) => r['session_id']?.toString() == sessionId,
    );
    assignedSessions.removeWhere((s) => s['session_id'] == sessionId);
    _persistAssignedSessions();
    unawaited(refreshCallCenterDashboard());
  }

  Future<List<JsonMap>> fetchCloseReasons({
    required bool isStudentReason,
  }) async {
    List<JsonMap> parseReasons(dynamic raw) {
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      // Common fallback shapes.
      if (raw is Map && raw['data'] is List) {
        return (raw['data'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      return const [];
    }

    Future<NetworkResponse> request({required bool authRequired}) {
      return _network.request(
        NetworkRequest(
          route: NetworkRouter.closeReasonsStudent,
          requestType: RequestType.get,
          isAuthorizationRequired: authRequired,
          parameters: {
            // Backend expects this query parameter to decide the reason set.
            // Send as a boolean so Dio serializes to `true/false`.
            'is_student_reason': isStudentReason,
          },
        ),
      );
    }

    final first = await request(authRequired: true);
    if (first.status == NetworkResponseStatus.success) {
      return parseReasons(first.data);
    }

    // If auth isn't required for this endpoint, a missing/expired token
    // would make the list look empty. Retry without authorization.
    final second = await request(authRequired: false);
    if (second.status == NetworkResponseStatus.success) {
      return parseReasons(second.data);
    }

    final message =
        second.failure?.message ??
        first.failure?.message ??
        'Failed request';
    log('ChatController: fetchCloseReasons failed: $message');
    throw Exception(message);
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

  Future<void> loadSessionMessages({
    required String sessionId,
  }) async {
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

        // Extract peer profile image from session (call_center sees student, student sees call_center).
        if (raw is Map) {
          final session = raw['session'];
          if (session is Map) {
            final student = session['student'];
            final callCenter = session['call_center'];
            if (student is Map && student['image'] != null) {
              final img =
                  _normalizeMediaUrl(student['image']?.toString()) ??
                  '';
              currentSessionPeerImage.value = img;
              if (img.isNotEmpty) {
                _applyPeerImageUpdate(
                  sessionId: sessionId,
                  peerImage: img,
                );
              }
            } else if (callCenter is Map &&
                callCenter['image'] != null) {
              final img =
                  _normalizeMediaUrl(
                    callCenter['image']?.toString(),
                  ) ??
                  '';
              currentSessionPeerImage.value = img;
              if (img.isNotEmpty) {
                _applyPeerImageUpdate(
                  sessionId: sessionId,
                  peerImage: img,
                );
              }
            }
          }
        }

        if (fetchedList.isEmpty) {
          log(
            'ChatController: loadSessionMessages success but empty. rawType=${raw.runtimeType} keys=${raw is Map ? raw.keys.toList() : '—'}',
          );
        }
      } else {
        log('ChatController: loadSessionMessages failed.');
        log(
          'ChatController: status=failure message=${res.failure?.message}',
        );
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
          allowAttachments.value =
              current['allow_attachments'] == true;
        }
        break;

      case 'new_chat_request':
        // Call center only
        final normalizedEvent = Map<String, dynamic>.from(event);
        final student = normalizedEvent['student'];
        if (student is Map) {
          final studentMap = Map<String, dynamic>.from(student);
          studentMap['image'] = _normalizeMediaUrl(
            studentMap['image']?.toString(),
          );
          normalizedEvent['student'] = studentMap;
        }
        incomingRequests.insert(0, normalizedEvent);
        final sid = event['session_id']?.toString();
        if (sid != null && sid.trim().isNotEmpty) {
          // Refresh sessions so the request can pick up peer_image from REST API.
          loadCallCenterSessions();
          // Best-effort: some backends only include the avatar inside the messages payload.
          hydratePeerImageForSession(sid);
        }
        unawaited(refreshCallCenterDashboard());
        break;

      case 'chat_request_created':
        currentSessionId.value = event['session_id']?.toString();
        final session = event['session'];
        if (session is Map) {
          allowAttachments.value =
              session['allow_attachments'] == true;
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
          allowAttachments.value =
              session['allow_attachments'] == true;
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
          final sessionMap = session is Map ? session : null;
          final studentMap = sessionMap?['student'];
          String peerName = '';
          String nodeTitle = '';
          String peerImage = '';
          if (request != null) {
            final student = request['student'];
            peerName = student is Map
                ? (student['full_name']?.toString() ?? '')
                : '';
            nodeTitle = request['node_title']?.toString() ?? '';
            peerImage =
                _normalizeMediaUrl(
                  student is Map
                      ? student['image']?.toString()
                      : null,
                ) ??
                '';
            incomingRequests.removeWhere(
              (r) => r['session_id']?.toString() == sessionId,
            );
          }
          if (studentMap is Map) {
            if (peerName.isEmpty)
              peerName = studentMap['full_name']?.toString() ?? '';
            if (peerImage.isEmpty) {
              peerImage =
                  _normalizeMediaUrl(
                    studentMap['image']?.toString(),
                  ) ??
                  '';
            }
            final lastMsg = sessionMap?['last_message'];
            if (nodeTitle.isEmpty && lastMsg is Map) {
              nodeTitle = lastMsg['text']?.toString() ?? '';
            }
          }
          final entry = <String, String>{
            'session_id': sessionId,
            'peer_name': peerName,
            'node_title': nodeTitle,
            'peer_image': peerImage,
          };
          assignedSessions.removeWhere(
            (s) => s['session_id'] == sessionId,
          );
          assignedSessions.insert(0, entry);
          assignedSessionsUpdated.value++;
          _persistAssignedSessions();
          // Refetch sessions so new chat gets peer_image from API and list avatar updates.
          loadCallCenterSessions();
          if (peerImage.trim().isEmpty) {
            // Some backends only include the participant avatar in the messages endpoint.
            hydratePeerImageForSession(sessionId);
          }
        }
        unawaited(refreshCallCenterDashboard());
        break;

      case 'message_sent':
      case 'new_message':
        final msg = event['message'];
        if (msg is Map<String, dynamic>) {
          _addMessageDedup(msg);
          _updateChatListPreviewFromMessage(msg);
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
          _markCallCenterSessionClosed(closedSessionId);
          incomingRequests.removeWhere(
            (r) => r['session_id']?.toString() == closedSessionId,
          );
          assignedSessions.removeWhere(
            (s) => s['session_id'] == closedSessionId,
          );
          _persistAssignedSessions();
        }
        unawaited(refreshCallCenterDashboard());
        break;

      case 'error':
        final message = event['message']?.toString() ?? 'error';
        final lower = message.toLowerCase();
        // Avoid noisy "failed" snackbars when the backend already closed the chat.
        if (lower.contains('already_closed') ||
            lower.contains('already closed') ||
            lower.contains('chat_closed') ||
            lower == 'already_closed') {
          return;
        }
        Get.snackbar('WS', message, snackPosition: SnackPosition.TOP);
        break;
    }
  }

  /// User left the chat screen without accepting (لا) — do not notify the server;
  /// keep the request in [incomingRequests] and clear local session UI state.
  void abandonSessionOpenWithoutClosing() {
    currentSessionId.value = null;
    currentSessionPeerImage.value = null;
    messages.clear();
    _seenMessageKeys.clear();
    isLoadingMessages.value = false;
  }

  void openSession(
    String sessionId, {
    String? peerName,
    String? peerImage,
    bool loadMessages = true,
    bool requiresAcceptance = false,
  }) {
    currentSessionId.value = sessionId;
    currentSessionPeerImage.value = _normalizeMediaUrl(peerImage);
    messages.clear();
    _seenMessageKeys.clear();
    // Fetch old messages from REST so the chat isn't empty on open.
    // For pending requests we delay this until the user accepts.
    if (loadMessages) {
      loadSessionMessages(sessionId: sessionId);
    }
    Get.toNamed(
      '/chat/session',
      arguments: {
        'session_id': sessionId,
        if (peerName != null && peerName.isNotEmpty)
          'peer_name': peerName,
        if (_normalizeMediaUrl(peerImage) != null)
          'peer_image': _normalizeMediaUrl(peerImage),
        if (requiresAcceptance) 'requires_acceptance': true,
      },
    );
  }

  // Keep socket alive globally; don't disconnect here.
}
