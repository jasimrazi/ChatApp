import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {

  //Make instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // OneSignal API credentials
  static const String _oneSignalAppId = '377e5a36-e5c1-43bf-ba50-02c78d7772a9';
  static const String _oneSignalRestApiKey =
      'os_v2_app_g57funxfyfb37osqaldy253svhm7dzoubfae4pfnpr6ih4gp63n2qukrunxkgjimbaoumv4akgqvz7wk6srj6m4ekwqclpzpc6r52ci'; // Replace with your actual REST API key


// Helper method to get OneSignal Player ID
  Future<String?> getOneSignalPlayerId() async {
  try {
    // Get the current user's push subscription ID
    String? playerId = await OneSignal.User.pushSubscription.id;
    
    return playerId;
  } catch (e) {
    print('Error getting OneSignal Player ID: $e');
    return null;
  }
}


  // Get user's OneSignal Player ID from firestore
  Future<String?> getReceiverPlayerId(String receiverId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(receiverId).get();
      return userDoc.get('oneSignalPlayerId') as String?;
    } catch (e) {
      print('Error getting receiver player ID: $e');
      return null;
    }
  }

  // Save user's OneSignal Player ID
  Future<void> saveUserPushToken() async {
    try {
      // Get external user ID
      String? externalUserId = _auth.currentUser?.uid;

      if (externalUserId != null) {
        // Get the current user's push token
        String? pushToken = await OneSignal.User.pushSubscription.id;

        if (pushToken != null) {
          await _firestore.collection('Users').doc(externalUserId).update({
            'oneSignalPlayerId': pushToken,
          });
        }
      }
    } catch (e) {
      print('Error saving push token: $e');
    }
  }

  // Send notification using OneSignal REST API
  Future<bool> sendNotification({
    required String receiverId,
    required String message,
    String? imageUrl,
  }) async {
    try {
      // Get receiver's OneSignal Player ID
      final receiverPlayerId = await getReceiverPlayerId(receiverId);
      if (receiverPlayerId == null) return false;

      // Get sender's name
      final senderDoc = await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .get();
      final senderName = senderDoc.get('name') ?? 'Someone';

      // Create notification content
      String notificationMessage = imageUrl != null && imageUrl.isNotEmpty
          ? '$senderName sent you an image'
          : message;

      // Prepare notification payload
      final Map<String, dynamic> notification = {
        'app_id': _oneSignalAppId,
        'include_player_ids': [receiverPlayerId],
        'contents': {'en': notificationMessage},
        'headings': {'en': "New message from $senderName"},
        'data': {
          'type': 'chat_message',
          'senderId': _auth.currentUser!.uid,
          'receiverId': receiverId,
        }
      };

      // Add image if available
      if (imageUrl != null && imageUrl.isNotEmpty) {
        notification['big_picture'] = imageUrl;
      }

      // Send notification via HTTP POST
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $_oneSignalRestApiKey'
        },
        body: json.encode(notification),
      );

      // Check response
      if (response.statusCode == 200) {
        print('Notification sent successfully');
        return true;
      } else {
        print('Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // Initialize OneSignal (call this in your app's initialization)
  Future<void> initOneSignal(String oneSignalAppId) async {
    // Initialize OneSignal
    OneSignal.initialize(oneSignalAppId);

    // Configure notification permissions
    await OneSignal.Notifications.requestPermission(true);
  }

  // Setup notification handlers
  void setupNotificationHandlers() {
    // Handle notification when app is opened
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      if (data != null) {
        print('Notification clicked with data: $data');
        // Add your navigation logic here
      }
    });

    // Handle notification when app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      // Prevent default display of notification
      event.preventDefault();

      // You can customize how to handle foreground notifications
      print('Foreground notification received');
    });
  }
}
