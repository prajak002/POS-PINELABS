import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../core/constants.dart';
import '../models/auth_models.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Save JWT token to SharedPreferences
  Future<bool> saveToken(String token) async {
    await init();
    return await _prefs!.setString(AppConstants.jwtTokenKey, token);
  }

  // Get JWT token from SharedPreferences
  Future<String?> getToken() async {
    await init();
    return _prefs!.getString(AppConstants.jwtTokenKey);
  }

  // Save user role to SharedPreferences
  Future<bool> saveUserRole(String role) async {
    await init();
    return await _prefs!.setString(AppConstants.userRoleKey, role);
  }

  // Get user role from SharedPreferences
  Future<String?> getUserRole() async {
    await init();
    return _prefs!.getString(AppConstants.userRoleKey);
  }

  // Save username to SharedPreferences
  Future<bool> saveUsername(String username) async {
    await init();
    return await _prefs!.setString(AppConstants.usernameKey, username);
  }

  // Get username from SharedPreferences
  Future<String?> getUsername() async {
    await init();
    return _prefs!.getString(AppConstants.usernameKey);
  }

  // Decode JWT token and extract user information
  User? decodeToken(String token) {
    try {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      
      // Extract role from cognito:groups or fallback to direct role field
      String role = '';
      if (payload['cognito:groups'] != null && payload['cognito:groups'] is List) {
        List<String> groups = List<String>.from(payload['cognito:groups']);
        if (groups.isNotEmpty) {
          role = groups.first; // Use the first group as the primary role
        }
      } else {
        role = payload['role'] ?? payload['user_role'] ?? '';
      }
      
      return User(
        username: payload['username'] ?? payload['sub'] ?? '',
        role: role,
        groups: payload['cognito:groups'] != null ? List<String>.from(payload['cognito:groups']) : null,
        email: payload['email'],
        fullName: payload['full_name'] ?? payload['name'],
      );
    } catch (e) {
      // Handle JWT decode error silently in production
      print('JWT decode error: $e'); // Add debug logging
      return null;
    }
  }

  // Check if token is expired
  bool isTokenExpired(String token) {
    try {
      return Jwt.isExpired(token);
    } catch (e) {
      return true;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    return !isTokenExpired(token);
  }

  // Get current user from stored token
  Future<User?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;
    
    if (isTokenExpired(token)) {
      await logout();
      return null;
    }
    
    return decodeToken(token);
  }

  // Logout - clear all stored data
  Future<bool> logout() async {
    await init();
    await _prefs!.remove(AppConstants.jwtTokenKey);
    await _prefs!.remove(AppConstants.userRoleKey);
    await _prefs!.remove(AppConstants.usernameKey);
    return true;
  }

  // Login and save token and user data
  Future<User?> loginAndSaveData(String token) async {
    final user = decodeToken(token);
    if (user == null) return null;

    await saveToken(token);
    await saveUserRole(user.role);
    await saveUsername(user.username);

    return user;
  }
}
