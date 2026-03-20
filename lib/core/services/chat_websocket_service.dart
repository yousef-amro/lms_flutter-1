import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../environments/app_environments.dart';
import '../cache/secure_storage_service.dart';
import 'token_manager_service.dart';

typedef JsonMap = Map<String, dynamic>;

/// Maps low-level IO/WebSocket failures to a short UI/snackbar code.
String _mapWebSocketFailure(Object err) {
  final s = err.toString();
  if (s.contains('Failed host lookup') ||
      s.contains('No address associated with hostname')) {
    return 'ws_dns_failed';
  }
  if (s.contains('Network is unreachable') ||
      s.contains('Connection refused') ||
      s.contains('timed out')) {
    return 'ws_network_unreachable';
  }
  return 'socket_error';
}

class ChatWebSocketService {
  final SecureStorageService _secureStorage;
  final TokenManagerService _tokenManager;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final _events = StreamController<JsonMap>.broadcast();
  Stream<JsonMap> get events => _events.stream;

  final _connectionState = StreamController<bool>.broadcast();
  Stream<bool> get isConnectedStream => _connectionState.stream;
  bool get isConnected => _channel != null;

  bool _isConnecting = false;
  bool _isClosedByUser = false;

  int _reconnectAttempt = 0;
  Timer? _reconnectTimer;

  ChatWebSocketService({
    required SecureStorageService secureStorage,
    required TokenManagerService tokenManager,
  }) : _secureStorage = secureStorage,
       _tokenManager = tokenManager;

  Future<void> connect() async {
    if (_isConnecting || isConnected) return;
    _isConnecting = true;
    _isClosedByUser = false;

    try {
      final tokenOk = await _tokenManager.ensureValidToken();
      if (!tokenOk) {
        throw StateError('No valid token available for WebSocket connect');
      }

      final token = (await _secureStorage.fetchAccessToken()) ?? '';
      if (token.isEmpty) {
        throw StateError('Access token missing');
      }

      final baseUrl = AppEnvironmentHelper().getEnvironmentVariable('BASE_URL');
      final wsUrl = _buildChatWsUrl(baseUrl.toString(), token);

      log('ChatWS: connecting to $wsUrl');
      try {
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      } catch (e, st) {
        log('ChatWS: connect() threw: $e', stackTrace: st);
        _connectionState.add(false);
        if (!_isClosedByUser) {
          _events.add({'type': 'error', 'message': _mapWebSocketFailure(e)});
          _scheduleReconnect();
        }
        return;
      }

      _connectionState.add(true);
      _reconnectAttempt = 0;

      _subscription = _channel!.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data.toString());
            if (decoded is Map<String, dynamic>) {
              _events.add(decoded);
            } else {
              _events.add({'type': 'error', 'message': 'invalid_event'});
            }
          } catch (e) {
            _events.add({'type': 'error', 'message': 'invalid_json'});
          }
        },
        onError: (err, st) {
          log('ChatWS: stream error: $err');
          _events.add({'type': 'error', 'message': _mapWebSocketFailure(err)});
          _handleDisconnect();
        },
        onDone: () {
          log('ChatWS: closed');
          _handleDisconnect();
        },
        cancelOnError: true,
      );
    } on StateError catch (e) {
      log('ChatWS: token/state error: $e');
      _connectionState.add(false);
      if (!_isClosedByUser) {
        _events.add({
          'type': 'error',
          'message': e.message,
        });
        _scheduleReconnect();
      }
    } catch (e, st) {
      log('ChatWS: unexpected connect error: $e', stackTrace: st);
      _connectionState.add(false);
      if (!_isClosedByUser) {
        _events.add({'type': 'error', 'message': _mapWebSocketFailure(e)});
        _scheduleReconnect();
      }
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> disconnect() async {
    _isClosedByUser = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    final ch = _channel;
    _channel = null;
    _connectionState.add(false);

    await _subscription?.cancel();
    _subscription = null;

    try {
      await ch?.sink.close();
    } catch (_) {}
  }

  Future<void> sendAction(String action, [JsonMap? payload]) async {
    if (!isConnected) {
      await connect();
    }
    if (!isConnected) {
      _events.add({'type': 'error', 'message': 'not_connected'});
      return;
    }

    final msg = <String, dynamic>{
      'action': action,
      if (payload != null) 'payload': payload else 'payload': <String, dynamic>{},
    };
    _channel!.sink.add(jsonEncode(msg));
  }

  void _handleDisconnect() {
    if (_channel == null) return;

    _channel = null;
    _connectionState.add(false);

    _subscription?.cancel();
    _subscription = null;

    if (_isClosedByUser) return;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectAttempt++;
    final seconds = (_reconnectAttempt * 2).clamp(2, 20);
    _reconnectTimer = Timer(Duration(seconds: seconds), () async {
      if (_isClosedByUser) return;
      try {
        await connect();
      } catch (e) {
        _scheduleReconnect();
      }
    });
  }

  String _buildChatWsUrl(String baseUrl, String token) {
    final base = Uri.parse(baseUrl);
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    return Uri(
      scheme: scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/ws/chat/',
      queryParameters: {'token': token},
    ).toString();
  }
}

