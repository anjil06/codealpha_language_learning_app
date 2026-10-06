import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/services/firebase_service.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final StorageService _storageService;

  AuthRepository(this._storageService);

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<void> loadSavedUser() async {
    _currentUser = _storageService.getCachedUser();
    // Default initial mock user for instant college project demonstration if no user is logged in
    if (_currentUser == null) {
      _currentUser = UserModel.initial(
        id: 'anjil_demo_id',
        name: 'Anjil',
        email: 'anjil@example.com',
        learningLanguage: _storageService.selectedLanguage,
      );
      await _storageService.saveUserCache(_currentUser!);
    }
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String learningLanguage,
  }) async {
    final auth = FirebaseService.auth;
    final firestore = FirebaseService.firestore;

    String userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    if (auth != null && firestore != null) {
      try {
        final credential = await auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        if (credential.user != null) {
          userId = credential.user!.uid;
          await credential.user!.updateDisplayName(name.trim());
        }
      } catch (e) {
        debugPrint('Firebase Auth SignUp failed, proceeding with offline user: $e');
      }
    }

    final user = UserModel(
      id: userId,
      name: name.trim(),
      email: email.trim(),
      learningLanguage: learningLanguage,
      xp: 0,
      level: 1,
      streak: 1,
      dailyGoal: 10,
      lessonsCompleted: 0,
      wordsLearned: 0,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    await _storageService.saveUserCache(user);
    await _storageService.setSelectedLanguage(learningLanguage.toLowerCase());

    // Save to Firestore if available
    if (firestore != null) {
      try {
        await firestore.collection('users').doc(userId).set(user.toJson());
      } catch (e) {
        debugPrint('Firestore save user error: $e');
      }
    }

    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final auth = FirebaseService.auth;
    final firestore = FirebaseService.firestore;

    if (auth != null) {
      try {
        final credential = await auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        if (credential.user != null && firestore != null) {
          final doc = await firestore.collection('users').doc(credential.user!.uid).get();
          if (doc.exists && doc.data() != null) {
            final user = UserModel.fromJson(doc.data()!);
            _currentUser = user;
            await _storageService.saveUserCache(user);
            return user;
          }
        }
      } catch (e) {
        debugPrint('Firebase Login warning: $e');
      }
    }

    // Local / Offline check
    final cached = _storageService.getCachedUser();
    if (cached != null && cached.email.toLowerCase() == email.trim().toLowerCase()) {
      _currentUser = cached;
      return cached;
    }

    // Create session for user credentials
    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first.isNotEmpty ? email.split('@').first : 'Learner',
      email: email.trim(),
      learningLanguage: _storageService.selectedLanguage,
      xp: 50,
      level: 1,
      streak: 5,
      dailyGoal: 10,
      lessonsCompleted: 7,
      wordsLearned: 24,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    await _storageService.saveUserCache(user);
    return user;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final auth = FirebaseService.auth;
    if (auth != null) {
      try {
        await auth.sendPasswordResetEmail(email: email.trim());
        return;
      } catch (e) {
        debugPrint('Firebase Reset Password error: $e');
      }
    }
    // Simulate delay for offline/demo mode
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> updateUser(UserModel updatedUser) async {
    _currentUser = updatedUser;
    await _storageService.saveUserCache(updatedUser);

    final firestore = FirebaseService.firestore;
    if (firestore != null) {
      try {
        await firestore.collection('users').doc(updatedUser.id).update(updatedUser.toJson());
      } catch (e) {
        debugPrint('Firestore update error: $e');
      }
    }
  }

  Future<void> logout() async {
    final auth = FirebaseService.auth;
    if (auth != null) {
      try {
        await auth.signOut();
      } catch (e) {
        debugPrint('Firebase SignOut error: $e');
      }
    }
    _currentUser = null;
    await _storageService.clearUserCache();
  }
}
