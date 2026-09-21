import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  Profile? _profile;
  bool _loading = true;

  AuthService() {
    _client.auth.onAuthStateChange.listen((_) => _syncProfile());
    _syncProfile();
  }

  Profile? get profile => _profile;
  bool get isLoading => _loading;
  bool get isLoggedIn => _client.auth.currentSession != null;
  User? get currentUser => _client.auth.currentUser;

  Future<void> _syncProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _profile = null;
      _loading = false;
      notifyListeners();
      return;
    }
    try {
      final row =
          await _client.from('profiles').select().eq('id', user.id).single();
      _profile = Profile.fromMap(row);
    } catch (_) {
      _profile = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> refreshProfile() => _syncProfile();

  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      await _syncProfile();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Erreur de connexion : $e');
      return "Could not sign in. Check your internet connection and try again.";
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phone},
      );
      await _syncProfile();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Erreur d\'inscription : $e');
      return "Could not create the account. Check your internet connection and try again.";
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? Uri.base.toString() : null,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Erreur de connexion Google : $e');
      return "Could not sign in with Google. Try again.";
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    _profile = null;
    notifyListeners();
  }

  Future<String?> updateProfile({
    String? fullName,
    String? phone,
    String? city,
    String? address,
    String? gender,
  }) async {
    final user = currentUser;
    if (user == null) return 'Not signed in';
    try {
      await _client.from('profiles').update({
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (city != null) 'city': city,
        if (address != null) 'address': address,
        if (gender != null) 'gender': gender,
      }).eq('id', user.id);
      await _syncProfile();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteAccount() async {
    if (currentUser == null) return 'Not signed in';
    try {
      await _client.rpc('delete_own_account');
      await _client.auth.signOut();
      _profile = null;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
