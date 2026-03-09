import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final Logger _logger = Logger();

  bool _googleSignInInitialized = false;

  // Stream for auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.e("SignUp Error: ${e.message}");
      rethrow;
    } catch (e) {
      _logger.e("SignUp Error: $e");
      rethrow;
    }
  }

  // Login with email and password
  Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.e("Login Error: ${e.message}");
      rethrow;
    } catch (e) {
      _logger.e("Login Error: $e");
      rethrow;
    }
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (!_googleSignInInitialized) {
        await _googleSignIn.initialize(
          serverClientId:
              '1045860641831-9k28neonaqolgbuj8iideaoi520jorgn.apps.googleusercontent.com',
        );
        _googleSignInInitialized = true;
      }

      // Trigger the authentication flow (throws if canceled)
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Obtain the authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a Firebase credential using only the ID token
      // (Google Sign In v7 separates authentication from authorization,
      // so we use the idToken for Firebase authentication)
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      _logger.e("Google SignIn Error: $e");
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      if (_googleSignInInitialized) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      _logger.e("Logout Error: $e");
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _logger.e("ResetPassword Error: $e");
      rethrow;
    }
  }
}
