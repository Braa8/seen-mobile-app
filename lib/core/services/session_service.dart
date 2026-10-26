import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SessionService extends ChangeNotifier {
  SessionService._();
  static final SessionService instance = SessionService._();

  bool firebaseAvailable = false;
  User? get user => firebaseAvailable ? FirebaseAuth.instance.currentUser : null;
  bool get isSignedIn => user != null;
  String? get displayName => user?.displayName;
  String? get email => user?.email;

  Future<void> initialize({required bool firebaseAvailable}) async {
    this.firebaseAvailable = firebaseAvailable;
    if (firebaseAvailable) {
      FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
    }
  }

  Future<String?> idToken({bool forceRefresh = false}) async {
    if (!firebaseAvailable) return null;
    return FirebaseAuth.instance.currentUser?.getIdToken(forceRefresh);
  }

  Future<void> signOut() async {
    if (firebaseAvailable) await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}
