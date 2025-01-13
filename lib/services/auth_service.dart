import 'package:chat_app/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Making Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final NotificationService _notification = NotificationService();

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign in: ${e.message}');
      rethrow; // Rethrow the FirebaseAuthException for the caller to handle
    } catch (e) {
      print('General error during sign in: $e');
      rethrow; // Rethrow any other exceptions
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      // Create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get OneSignal Player ID
      String? playerId = await _notification.getOneSignalPlayerId();

      // Add user data to Firestore
      await _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'oneSignalPlayerId':
            playerId ?? '', // Store Player ID or empty string if null
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign up: ${e.message}');
      rethrow;
    } catch (e) {
      print('General error during sign up: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign out: ${e.message}');
      rethrow; // Rethrow the FirebaseAuthException for the caller to handle
    } catch (e) {
      print('General error during sign out: $e');
      rethrow; // Rethrow any other exceptions
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
