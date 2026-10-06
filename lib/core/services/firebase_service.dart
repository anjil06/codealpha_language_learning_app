import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return;
      }

      await Firebase.initializeApp();
      _isInitialized = true;
      debugPrint('Firebase successfully initialized.');
    } catch (e) {
      _isInitialized = false;
      debugPrint('Firebase initialization skipped/offline mode active: $e');
    }
  }

  static FirebaseAuth? get auth {
    if (!_isInitialized) return null;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseFirestore? get firestore {
    if (!_isInitialized) return null;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }
}

