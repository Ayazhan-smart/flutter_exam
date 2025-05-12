import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AppUser {
  final String id;
  final String email;
  final String? displayName;

  AppUser({required this.id, required this.email, this.displayName});

  factory AppUser.fromFirebaseUser(firebase_auth.User user) {
    return AppUser(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName,
    );
  }
}

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _authController = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  AuthService() {
    _auth.authStateChanges().listen((firebase_auth.User? user) {
      if (user != null) {
        final appUser = AppUser.fromFirebaseUser(user);
        _currentUser = appUser;
        _authController.add(appUser);
      } else {
        _currentUser = null;
        _authController.add(null);
      }
    });
  }

  Stream<AppUser?> get authStateChanges => _authController.stream;

  AppUser? get currentUser => _currentUser;

  Future<AppUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        final appUser = AppUser.fromFirebaseUser(user);
        await _db.collection('users').doc(user.uid).set({
          'email': user.email,
          'displayName': user.displayName,
          'lastSignIn': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return appUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<AppUser?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      print('AuthService: Starting registration for email: $email');
      // Persist the auth instance
      await firebase_auth.FirebaseAuth.instance.setPersistence(firebase_auth.Persistence.LOCAL);
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('AuthService: User credential created');
      final user = userCredential.user;
      if (user != null) {
        print('AuthService: Firebase user created with ID: ${user.uid}');
        final appUser = AppUser.fromFirebaseUser(user);
        print('AuthService: Creating user document in Firestore');
        try {
          await _db.collection('users').doc(user.uid).set({
            'email': user.email,
            'displayName': user.displayName,
            'createdAt': FieldValue.serverTimestamp(),
            'lastSignIn': FieldValue.serverTimestamp(),
          });
          print('AuthService: User document created in Firestore');
        } catch (firestoreError) {
          print('AuthService: Error creating Firestore document: $firestoreError');
          // Don't rethrow Firestore errors, as the user is already created
        }
        _currentUser = appUser;
        _authController.add(appUser);
        return appUser;
      }
      print('AuthService: Failed to get user after registration');
      return null;
    } catch (e) {
      print('AuthService: Registration error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _authController.close();
  }
}
