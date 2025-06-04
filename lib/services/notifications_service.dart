import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterNotificationsInit = false;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    //request permission
    await _requestPermission();
    //setup message handlers
    await _setMessageHandlers();

  final token = await _messaging.getToken();
  print("FCM Token: $token");

  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );

    print("Permission status: ${settings.authorizationStatus}");
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterNotificationsInit) {
      return;
    }
    //android setu[]
    const channel = AndroidNotificationChannel(
      "high_importance_channel",
      "high_importance_notifications",
      description: "this is a channel for important notifications",
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    const initializationSettingAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    //ios setup
    // final initializationSettingsDrawin = DarwinInitializationSettings(
    //   onDidReceiveLocalNotification: (id,title,body,payload) async{

    //   }
    // );
    final initializationSettings = InitializationSettings(
      android: initializationSettingAndroid,
      // iOS: initializationSettingsDrawin
    );
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // on tap for notification
      },
    );
    _isFlutterNotificationsInit = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            "high_importance_channel",
            "high_importance_notifications",
            channelDescription: "this is a channel for important notifications",
            importance: Importance.high,
            priority: Priority.high,
            icon: "@mipmap/ic_launcher",
          ),
          // iOS: const DarwinNotificationDetails(
          //   presentAlert: true,
          //   presentBadge: true,
          //   presentSound: true,
          // )
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _setMessageHandlers() async {
    //foreground message
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });
    //background message
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    //opened app
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data["type"] == 'chat') {
      //open chat screen
    }
  }
  Future<String?> getFcmToken() async {
    return await _messaging.getToken();
  }
}
