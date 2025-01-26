import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:chat_app/views/auth_check.dart';

Future<void> main() async {
  try {
    // Ensure Flutter binding is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp();

    // Create an instance of NotificationService
    NotificationService notificationService = NotificationService();

    // Initialize OneSignal
    await notificationService
        .initOneSignal("377e5a36-e5c1-43bf-ba50-02c78d7772a9");


    // Setup notification handlers
    notificationService.setupNotificationHandlers();

    // Additional OneSignal configuration
    OneSignal.Notifications.addForegroundWillDisplayListener(
        (OSNotificationWillDisplayEvent event) {
      // Get the notification payload
      final notification = event.notification;
      print('Notification received: ${notification.body}');
      print('Notification title: ${notification.title}');
      print('Custom data: ${notification.additionalData}');

      // Display notification
      event.notification.display();
    });

    OneSignal.Notifications.addClickListener((OSNotificationClickEvent event) {
      print('Notification clicked: ${event.notification.body}');
      print('Click notification data: ${event.notification.additionalData}');

      // Handle navigation based on notification data
      final route = event.notification.additionalData?['route'] as String?;
      if (route != null) {
        // Note: Store the route and handle navigation after app initialization
        // You might want to use a state management solution or global navigation key
      }
    });

    runApp(const MainApp());
  } catch (e) {
    print('Initialization error: $e');
    // Handle initialization errors appropriately
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthCheck(),
    );
  }
}
