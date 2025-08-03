import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  Future<UserCredential?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      print('✅ User signed in anonymously: ${credential.user?.uid}');
      return credential;
    } catch (e) {
      print('❌ Error signing in anonymously: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ User signed out');
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<void> ensureAuthenticated() async {
    if (!isAuthenticated) {
      await signInAnonymously();
    }
  }
}
