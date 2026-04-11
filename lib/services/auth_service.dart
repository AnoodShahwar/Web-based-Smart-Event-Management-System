import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  // These give us access to Firebase Auth and Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Returns the currently logged in user (null if nobody is logged in)
  User? get currentUser => _auth.currentUser;

  // LOGIN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      // Custom friendly error messages
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email. Please register first.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-disabled':
          return 'This account has been disabled. Contact support.';
        case 'invalid-credential':
          return 'Incorrect email or password. Please try again.';
        default:
          return e.message;
      }
    }
  }

  // REGISTER
  Future<String?> register(String name, String email, String password) async {
    try {
      // Create the user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Save extra user info in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': 'student', // default role
        'createdAt': DateTime.now(),
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // GET USER ROLE from Firestore
  Future<String> getUserRole(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return doc['role'] ?? 'student';
  }

  // GET ALL USERS (admin only)
  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }
}
