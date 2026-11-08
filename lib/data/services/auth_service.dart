import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

class AuthResult {
  const AuthResult.success(UserProfile this.user) : error = null;

  const AuthResult.failure(String this.error) : user = null;

  final UserProfile? user;
  final String? error;

  bool get isSuccess => user != null;
}

class AuthService {
  AuthService(this._users);

  static const String _dbError = 'Деректер қорымен жұмыс кезінде қате болды. Қайталап көріңіз.';

  final UserRepository _users;

  Future<AuthResult> login(String email, String password) async {
    try {
      final user = _users.byEmail(email);
      if (user == null || !_users.verify(user.id, password)) {
        return const AuthResult.failure('Электрондық пошта немесе құпиясөз қате');
      }
      return AuthResult.success(user);
    } catch (_) {
      return const AuthResult.failure(_dbError);
    }
  }

  Future<AuthResult> loginWithPhone(String phone) async {
    try {
      final user = _users.byPhone(phone);
      if (user == null) {
        return const AuthResult.failure('Бұл нөмірмен аккаунт табылмады. Алдымен тіркеліңіз');
      }
      return AuthResult.success(user);
    } catch (_) {
      return const AuthResult.failure(_dbError);
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final key = email.trim().toLowerCase();
      if (_users.byEmail(key) != null) {
        return const AuthResult.failure('Бұл электрондық пошта бұрын тіркелген');
      }
      final profile = UserProfile(
        id: 'u${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        email: key,
        phone: phone,
      );
      await _users.create(profile, password);
      return AuthResult.success(profile);
    } catch (_) {
      return const AuthResult.failure(_dbError);
    }
  }

  Future<String?> updateProfile(UserProfile profile) async {
    try {
      final existing = _users.byEmail(profile.email);
      if (existing != null && existing.id != profile.id) {
        return 'Бұл электрондық пошта басқа аккаунтқа тіркелген';
      }
      await _users.update(profile);
      return null;
    } catch (_) {
      return _dbError;
    }
  }

  Future<String?> changePassword(String userId, String current, String next) async {
    try {
      if (!_users.verify(userId, current)) {
        return 'Ағымдағы құпиясөз дұрыс емес';
      }
      await _users.setPassword(userId, next);
      return null;
    } catch (_) {
      return _dbError;
    }
  }
}
