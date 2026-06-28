// lib/data/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Email Register ───────────────────────────────────────────────
  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required int avatarIndex,
    required int colorIndex,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(name);

    // Save to Realtime DB
    final user = UserModel(
      uid: cred.user!.uid,
      name: name,
      email: email,
      avatarIndex: avatarIndex,
      colorIndex: colorIndex,
    );
    await _db.ref('users/${cred.user!.uid}').set(user.toMap());
    return cred;
  }

  // ─── Email Login ──────────────────────────────────────────────────
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ─── Google Sign In ───────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential);

    // Create user in DB if new
    final snapshot = await _db.ref('users/${cred.user!.uid}').get();
    if (!snapshot.exists) {
      final user = UserModel(
        uid: cred.user!.uid,
        name: cred.user!.displayName ?? 'Player',
        email: cred.user!.email ?? '',
        photoUrl: cred.user!.photoURL,
        avatarIndex: 0,
        colorIndex: 0,
      );
      await _db.ref('users/${cred.user!.uid}').set(user.toMap());
    }
    return cred;
  }

  // ─── Forgot Password ──────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── Sign Out ─────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── Get User Profile ─────────────────────────────────────────────
  Future<UserModel?> getUserProfile(String uid) async {
    final snapshot = await _db.ref('users/$uid').get();
    if (!snapshot.exists) return null;
    return UserModel.fromMap(
      snapshot.value as Map<dynamic, dynamic>,
      uid,
    );
  }

  // ─── Update User Profile ──────────────────────────────────────────
  Future<void> updateUserProfile(UserModel user) async {
    await _db.ref('users/${user.uid}').update(user.toMap());
  }
}
