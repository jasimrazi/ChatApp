import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart'; // Import NotificationService

class ChatService {
  // Instance of Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instance of NotificationService
  final NotificationService _notificationService = NotificationService();

  // Stream to fetch all users with real-time updates
  Stream<List<Map<String, dynamic>>> fetchUsers() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  // Helper function for generating uinque ChatIDs
  String generateChatID(String receiver) {
    String sender = _auth.currentUser!.uid;
    List<String> ids = [sender, receiver];
    ids.sort();
    return ids.join('_');
  }

  // Send a message
    // Send a message
  Future<void> sendMessage(String receiver, String message,
      {String? imageUrl, String? audioUrl}) async {
    // Ensure the message or one of the URLs is not empty
    if (message.trim().isEmpty &&
        (imageUrl == null || imageUrl.isEmpty) &&
        (audioUrl == null || audioUrl.isEmpty)) {
      print('Message, image, and audio are all empty.');
      return;
    }

    try {
      String sender = _auth.currentUser!.uid;
      String chatroomID = generateChatID(receiver);

      print(
          'Sending message: "$message" with imageUrl: $imageUrl and audioUrl: $audioUrl');

      // Add message to Firestore
      await _firestore
          .collection('Chats')
          .doc(chatroomID)
          .collection('Messages')
          .add({
        'sender': sender,
        'receiver': receiver,
        'message': message.trim(),
        'imageUrl': imageUrl ?? '', // Ensure non-null values for Firestore
        'audioUrl': audioUrl ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Reset typing status
      await _firestore.collection('Chats').doc(chatroomID).set({
        'isTyping': false,
      }, SetOptions(merge: true));

      // Send notification
      await _notificationService.sendNotification(
        receiverId: receiver,
        message: message.trim(),
        imageUrl: imageUrl,
      );

      print('Message sent successfully.');
    } catch (e) {
      print('Error sending message: $e');
    }
  }



  //Stream to get all messages
  Stream<List<Map<String, dynamic>>> getMessages(String receiver) {
    String chatroomID = generateChatID(receiver);
    return _firestore
        .collection('Chats')
        .doc(chatroomID)
        .collection('Messages')
        .orderBy('timestamp')
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }


  //Update typing status of current user
  Future<void> updateTypingStatus(String receiver, bool isTyping,
      {String? typingUserId}) async {
    String chatroomID = generateChatID(receiver);
    try {
      print('Typing user id 111111-- $typingUserId');
      await _firestore.collection('Chats').doc(chatroomID).set(
        {
          'isTyping': isTyping,
          'typingUserId': isTyping ? typingUserId : null,
        },
        SetOptions(merge: true),
      );
      print('Typing user id 222222-- $typingUserId');

    } catch (e) {
      print('Error updating typing status: $e');
    }
  }


  //Listen for the typing status
  Stream<Map<String, dynamic>> listenToTypingStatus(String receiver) {
    String chatroomID = generateChatID(receiver);
    return _firestore
        .collection('Chats')
        .doc(chatroomID)
        .snapshots()
        .map((snapshot) {
      var data = snapshot.data() ?? {};
      return {
        'isTyping': data['isTyping'] ?? false,  //Checking for both isTyping and UserID
        'typingUserId': data['typingUserId']
      };
    });
  }
}
