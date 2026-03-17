// import 'dart:async';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:lms_app/core/data/data_sources/core_data_remote_data_source.dart';
// import 'package:lms_app/core/domain/utils/alerts.dart';
// import 'package:lms_app/core/services/session_manager_service.dart';
// import 'package:lms_app/core/utils/device_info_utils.dart';

// class NotificationService extends GetxService with Alerts {
//   final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   final _messageStreamController = StreamController<RemoteMessage>.broadcast();

//   final SessionManagerService _sessionManager;
//   final CoreDataRemoteDataSourceAbstraction _coreDataSource;

//   NotificationService({
//     required SessionManagerService sessionManager,
//     required CoreDataRemoteDataSourceAbstraction coreDataSource,
//   }) : _sessionManager = sessionManager,
//        _coreDataSource = coreDataSource;

//   Future<void> initPlatformState() async {
//     await _initializeFirebase();
//     await _initializeLocalNotifications();
//     await _configureFirebaseMessaging();
//   }

//   Future<void> _initializeFirebase() async {
//     printFirebaseProject();
//   }

//   void printFirebaseProject() {
//     final app = Firebase.app();
//     if (kDebugMode) {
//       print('Firebase projectId: ${app.options.projectId}');
//       print('Firebase appId: ${app.options.appId}');
//       print('Firebase senderId: ${app.options.messagingSenderId}');
//     }
//   }

//   Future<void> _initializeLocalNotifications() async {
//     const initializationSettingsAndroid = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );

//     const initializationSettingsDarwin = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       defaultPresentAlert: true,
//       defaultPresentBadge: true,
//       defaultPresentSound: true,
//     );

//     const initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsDarwin,
//     );

//     // Initialize with the callback for notification click
//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         // Handle notification tap
//         if (kDebugMode) {
//           print('Notification tapped: ${response.payload}');
//         }
//         // TODO: Navigate to specific screen based on notification data
//       },
//     );

//     // Request iOS notification permissions explicitly
//     if (defaultTargetPlatform == TargetPlatform.iOS) {
//       await _flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin
//           >()
//           ?.requestPermissions(alert: true, badge: true, sound: true);
//     }

//     await _createAndroidNotificationChannel();
//   }

//   Future<void> _createAndroidNotificationChannel() async {
//     // Create notification channel matching backend configuration
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'noise_alarm', // Must match channel_id in backend Python code
//       'Noise Alarm Notifications',
//       description: 'This channel is used for noise alarm notifications.',
//       importance: Importance.max, // High importance for alarm sounds
//       playSound: true,
//       enableVibration: true,
//       sound: RawResourceAndroidNotificationSound('noise_alarm_28s'),
//     );

//     await _flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin
//         >()
//         ?.createNotificationChannel(channel);
//   }

//   Future<void> _configureFirebaseMessaging() async {
//     final messaging = FirebaseMessaging.instance;

//     // ✅ IMPORTANT: Set up foreground message handler FIRST before anything else
//     // This ensures we receive messages even if permission flow has issues
//     _setForegroundMessageHandler();

//     // iOS: allow system notification banner/sound while app is foreground
//     await messaging.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // Request permission from user
//     final settings = await messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );

//     final isGranted =
//         settings.authorizationStatus == AuthorizationStatus.authorized;

//     if (isGranted) {
//       // ✅ iOS: Ensure APNs token is available
//       if (defaultTargetPlatform == TargetPlatform.iOS) {
//         String? apnsToken;
//         int retries = 0;
//         do {
//           apnsToken = await messaging.getAPNSToken();
//           if (apnsToken == null) {
//             await Future.delayed(const Duration(milliseconds: 300));
//           }
//         } while (apnsToken == null && retries++ < 10);

//         if (apnsToken == null) {
//           if (kDebugMode) {
//             print("APNs token still not available after retry.");
//           }
//           // Don't return here - foreground handler is already set up
//         }
//       }

//       // ✅ Get FCM token now
//       final token = await messaging.getToken();
//       await _handleToken(token);
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       if (kDebugMode) {
//         print('User granted provisional permission');
//       }
//     } else {
//       if (kDebugMode) {
//         print('User declined or has not accepted permission');
//       }
//     }

//     // Handle notification when app is opened from terminated state
//     final initialMessage = await messaging.getInitialMessage();
//     if (initialMessage != null) {
//       _handleNotificationTap(initialMessage);
//     }

//     // Handle notification when app is opened from background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       _handleNotificationTap(message);
//     });

//     FirebaseMessaging.instance.onTokenRefresh.listen(_handleToken).onError((
//       err,
//     ) {
//       if (kDebugMode) {
//         print("Error refreshing FCM Token: $err");
//       }
//     });
//   }

//   void _setForegroundMessageHandler() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (!_messageStreamController.isClosed) {
//         _messageStreamController.add(message);
//       }

//       final isIos = defaultTargetPlatform == TargetPlatform.iOS;
//       final hasNotification = message.notification != null;

//       // On iOS, when a "notification" payload exists, the system already shows
//       // the banner/sound because setForegroundNotificationPresentationOptions
//       // is enabled. Skip showing local notification to avoid duplicates.
//       if (isIos && hasNotification) {
//         // iOS handles it automatically, do nothing
//         if (kDebugMode) {
//           print(
//             'iOS notification handled by system (no local notification needed)',
//           );
//         }
//       } else if (hasNotification) {
//         // Android: Show local notification
//         _showForegroundNotification(
//           message.notification?.title ?? 'إشعار جديد',
//           message.notification?.body ?? '',
//           message.data,
//         );
//       } else if (message.data.isNotEmpty) {
//         // Data-only message: Show local notification on both platforms
//         _showForegroundNotification(
//           message.data['title'] ?? 'إشعار جديد',
//           message.data['body'] ?? message.data['message'] ?? '',
//           message.data,
//         );
//       }

//       if (kDebugMode) {
//         print('Foreground message received: ${message.messageId}');
//         print('Message data: ${message.data}');
//         print('Message notification: ${message.notification?.title}');
//       }
//     });
//   }

//   Future<void> _showForegroundNotification(
//     String? title,
//     String? body,
//     Map<String, dynamic> data,
//   ) async {
//     // Ensure we have at least a default title
//     final notificationTitle = title ?? 'إشعار جديد';
//     final notificationBody = body ?? '';

//     // Use custom sound for Android (file in res/raw/)
//     // Channel ID must match backend Python code: "noise_alarm"
//     const androidSound = RawResourceAndroidNotificationSound('noise_alarm_28s');

//     final androidDetails = AndroidNotificationDetails(
//       'noise_alarm', // Must match channel_id in backend and channel creation
//       'Noise Alarm Notifications',
//       channelDescription: 'This channel is used for noise alarm notifications.',
//       importance: Importance.max,
//       priority: Priority.high,
//       ticker: 'ticker',
//       showWhen: true,
//       enableVibration: true,
//       playSound: true,
//       sound: androidSound,
//     );

//     // Use custom sound for iOS (file in Runner directory)
//     // Note: On iOS, use filename with .aiff extension for custom sounds
//     const iOSDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//       sound: 'noise_alarm_28s.aiff',
//       interruptionLevel: InterruptionLevel.timeSensitive,
//     );

//     final NotificationDetails platformDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iOSDetails,
//     );

//     try {
//       await _flutterLocalNotificationsPlugin.show(
//         DateTime.now().millisecondsSinceEpoch.remainder(100000),
//         notificationTitle,
//         notificationBody,
//         platformDetails,
//         payload: data.toString(),
//       );

//       if (kDebugMode) {
//         print('✅ Foreground notification shown: $notificationTitle');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('❌ Error showing foreground notification: $e');
//       }
//     }
//   }

//   void _handleNotificationTap(RemoteMessage message) {
//     if (kDebugMode) {
//       print('Notification tapped - App opened from notification');
//       print('Message data: ${message.data}');
//       print('Message notification: ${message.notification?.title}');
//     }
//   }

//   Future<void> _handleToken(String? token) async {
//     try {
//       if (token != null) {
//         // Print FCM Token for testing
//         if (kDebugMode) {
//           print('🔥 FCM Token: $token');
//         }

//         final isLoggedIn = await _sessionManager.isUserLoggedIn();
//         if (isLoggedIn) {
//           final success = await _registerDeviceToken(token);
//           if (!success) {
//             if (kDebugMode) {
//               print("Failed to send FCM Token");
//             }
//           } else {
//             if (kDebugMode) {
//               print("✅ FCM Token registered successfully: $token");
//             }
//           }
//         }
//       }
//     } on Exception catch (e) {
//       if (kDebugMode) {
//         print('_handleToken: ${e.toString()}');
//       }
//       rethrow;
//     }
//   }

//   Future<bool> _registerDeviceToken(String token) async {
//     try {
//       final deviceInfoUtils = DeviceInfoUtils();
//       final deviceId = await deviceInfoUtils.getDeviceId();
//       final deviceType = deviceInfoUtils.getDeviceType();

//       if (kDebugMode) {
//         print('Registering FCM Token...');
//         print('Device ID: $deviceId');
//         print('Device Type: $deviceType');
//         print('Registration ID: $token');
//       }

//       final result = await _coreDataSource.registerFcmToken(
//         registrationId: token,
//         deviceType: deviceType,
//         deviceId: deviceId,
//       );

//       return result.fold(
//         (failure) {
//           if (kDebugMode) {
//             print("❌ Failed to register FCM Token: ${failure.message}");
//           }
//           return false;
//         },
//         (success) {
//           if (kDebugMode) {
//             print("✅ FCM Token registered successfully");
//           }
//           return true;
//         },
//       );
//     } on Exception catch (e) {
//       if (kDebugMode) {
//         print("❌ Exception during FCM Token registration: $e");
//       }
//       return false;
//     }
//   }

//   Stream<RemoteMessage> get messageStream => _messageStreamController.stream;

//   @override
//   void onClose() {
//     _messageStreamController.close();
//     super.onClose();
//   }
// }
