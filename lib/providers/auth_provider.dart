import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

/// Firebase Auth provider
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _isRestoringSession = true;
  String? _errorMessage;
  ApplicationStatus? _applicationStatus;
  String? _rejectionReason;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isRestoringSession => _isRestoringSession;
  String? get errorMessage => _errorMessage;
  ApplicationStatus? get applicationStatus => _applicationStatus;
  String? get rejectionReason => _rejectionReason;
  bool get isApproved =>
      _applicationStatus == ApplicationStatus.approved ||
      _currentUser?.isDirectApproved == true ||
      _currentUser?.role == UserRole.admin ||
      _currentUser?.role == UserRole.developer;

  StreamSubscription? _authStateSubscription;

  AuthProvider() {
    _listenAuthState();
  }

  void _listenAuthState() {
    _authStateSubscription = _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _fetchUserData(user.uid);
        _isAuthenticated = true;
      } else {
        _currentUser = null;
        _isAuthenticated = false;
        _applicationStatus = null;
        _rejectionReason = null;
      }
      _isRestoringSession = false;
      notifyListeners();
    });
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = AppUser.fromJson(doc.data()!, uid);

        // Check application status
        try {
          final appDoc = await _firestore
              .collection('applications')
              .doc(uid)
              .get();
          if (appDoc.exists) {
            final data = appDoc.data()!;
            final status = data['status'] as String?;
            _applicationStatus = ApplicationStatus.values.firstWhere(
              (e) => e.name == status,
              orElse: () => ApplicationStatus.pending,
            );
            _rejectionReason = data['rejectionReason'] as String?;
          } else if (_currentUser?.isDirectApproved == true) {
            _applicationStatus = ApplicationStatus.approved;
          } else {
            _applicationStatus = ApplicationStatus.approved; // Default to approved
          }
        } catch (e) {
          debugPrint('Error fetching application status: $e');
          _applicationStatus = ApplicationStatus.approved; // Default on error
        }
      } else {
        // User doc doesn't exist — create fallback from auth
        final authUser = _auth.currentUser;
        if (authUser != null) {
          _currentUser = AppUser(
            id: uid,
            email: authUser.email ?? '',
            name: authUser.displayName ?? authUser.email?.split('@').first ?? '',
            role: UserRole.member,
          );
          _applicationStatus = ApplicationStatus.approved;
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      // Firestore permission denied — create fallback user from FirebaseAuth
      final authUser = _auth.currentUser;
      if (authUser != null) {
        _currentUser = AppUser(
          id: uid,
          email: authUser.email ?? '',
          name: authUser.displayName ?? authUser.email?.split('@').first ?? '',
          role: UserRole.member,
        );
        _applicationStatus = ApplicationStatus.approved;
      }
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Create user document
      final user = AppUser(
        id: uid,
        email: email,
        name: name,
        role: UserRole.member,
      );

      await _firestore.collection('users').doc(uid).set(user.toJson());

      // Create application
      await _firestore.collection('applications').doc(uid).set({
        'userId': uid,
        'name': name,
        'email': email,
        'status': ApplicationStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    _isAuthenticated = false;
    _applicationStatus = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
