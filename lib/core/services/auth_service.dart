import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class AuthService {
  final String baseUrl;

  AuthService({required this.baseUrl});

  Future<AuthResult> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AuthResult.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Login failed');
    }
  }

  Future<AuthResult> signup(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return AuthResult.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Signup failed');
    }
  }

  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to send reset email');
    }
  }

  Future<User> getCurrentUser() async {
    // This would typically use the stored token to fetch current user
    // For now, return a mock user
    return User(
      id: '1',
      email: 'user@example.com',
      name: 'John Doe',
      createdAt: DateTime(2000, 1, 1),
    );
  }

  Future<String> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Token refresh failed');
    }
  }
}
