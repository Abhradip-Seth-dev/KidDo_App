// ─────────────────────────────────────────────────────────────────────────────
// FirebaseAuthService — production auth layer.
// ACTIVATION: Run `flutterfire configure` and uncomment all code below.
// ─────────────────────────────────────────────────────────────────────────────

// import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in anonymously so even guests can have progress saved.
  Future<String?> signInAnonymously() async {
    // final credential = await _auth.signInAnonymously();
    // return credential.user?.uid;
    throw UnimplementedError('Run flutterfire configure first.');
  }

  /// Sign in with email and password.
  Future<String?> signInWithEmail(String email, String password) async {
    // final credential = await _auth.signInWithEmailAndPassword(
    //   email: email,
    //   password: password,
    // );
    // return credential.user?.uid;
    throw UnimplementedError('Run flutterfire configure first.');
  }

  /// Register a new account with email and password.
  Future<String?> registerWithEmail(String email, String password) async {
    // final credential = await _auth.createUserWithEmailAndPassword(
    //   email: email,
    //   password: password,
    // );
    // return credential.user?.uid;
    throw UnimplementedError('Run flutterfire configure first.');
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    // await _auth.signOut();
    throw UnimplementedError('Run flutterfire configure first.');
  }

  /// Stream of auth state changes (null = signed out).
  // Stream<User?> get authStateChanges => _auth.authStateChanges();
}
