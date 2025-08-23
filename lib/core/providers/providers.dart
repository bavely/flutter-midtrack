import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/user.dart';
import '../models/medication.dart';
import '../models/chat_message.dart';
import '../services/auth_service.dart';
import '../services/medication_service.dart';
import '../services/secure_storage.dart';

// App Config Provider
final appConfigProvider = Provider<AppConfig>((ref) {
  return const AppConfig(apiBaseUrl: 'http://192.168.50.5:8000/graphql');
});

// Service Providers
final graphQLClientProvider = Provider<GraphQLClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final link = HttpLink(config.apiBaseUrl);
  return GraphQLClient(
    link: link,
    cache: GraphQLCache(store: InMemoryStore()),
  );
});

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(graphQLClientProvider);
  return AuthService(client: client);
});

final medicationServiceProvider = Provider<MedicationService>((ref) {
  final client = ref.watch(graphQLClientProvider);
  return MedicationService(client: client);
});

final dosesForDateProvider =
    FutureProvider.family<List<Dose>, DateTime>((ref, date) async {
  final service = ref.watch(medicationServiceProvider);
  return service.getDosesForDate(date);
});

// Theme Provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    state = ThemeMode.values[themeIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    state = mode;
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  final AuthService _authService;
  final _storage = SecureStorage();

  String _parseError(Object error) {
    debugPrint('Auth error: $error');
    if (error is OperationException) {
      if (error.linkException != null) {
        return 'Unable to connect. Please check your internet connection.';
      }
      if (error.graphqlErrors.isNotEmpty) {
        final message = error.graphqlErrors.first.message;
        if (message.contains('Invalid credentials') ||
            message.contains('Login failed')) {
          return 'Invalid email or password.';
        }
        if (message.contains('User already exists') ||
            message.contains('Email already in use')) {
          return 'An account with this email already exists.';
        }
        return message;
      }
    }
    if (error is SocketException) {
      return 'Unable to connect. Please check your internet connection.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _checkAuthStatus() async {
    final token = await _storage.readToken();
    if (token != null) {
      // Verify token validity and load user data
      try {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(isLoggedIn: true, user: user);
      } catch (e) {
        await _storage.deleteToken();
        state = state.copyWith(isLoggedIn: false);
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _authService.login(email, password);
      await _storage.saveToken(result.token);
      state = state.copyWith(
        isLoggedIn: true,
        user: result.user,
        isLoading: false,
      );
      return true;
    } catch (e, st) {
      debugPrint('Login failed: $e\n$st');
      final message = _parseError(e);
      state = state.copyWith(isLoading: false, error: message);
      return false;
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _authService.signup(email, password, name);
      await _storage.saveToken(result.token);
      state = state.copyWith(
        isLoggedIn: true,
        user: result.user,
        isLoading: false,
      );
      return true;
    } catch (e, st) {
      debugPrint('Signup failed: $e\n$st');
      final message = _parseError(e);
      state = state.copyWith(isLoading: false, error: message);
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteToken();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

// Medication Provider
final medicationProvider =
    StateNotifierProvider<MedicationNotifier, MedicationState>((ref) {
  final service = ref.watch(medicationServiceProvider);
  return MedicationNotifier(service);
});

class MedicationNotifier extends StateNotifier<MedicationState> {
  MedicationNotifier(this._medicationService) : super(const MedicationState()) {
    _loadMedications();
  }

  final MedicationService _medicationService;

  Future<void> _loadMedications() async {
    state = state.copyWith(isLoading: true);
    try {
      final dashboard = await _medicationService.getDashboard();
      state = state.copyWith(
        medications: dashboard.medications,
        upcomingDoses: dashboard.upcomingDoses,
        missedDoses: dashboard.missedDoses,
        refillAlerts: dashboard.refillAlerts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Public method to refresh medications and upcoming doses
  Future<void> reload() async {
    await _loadMedications();
  }

  Future<bool> addMedication(Medication medication) async {
    try {
      await _medicationService.addMedication(medication);
      await _loadMedications();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> markDoseTaken(String doseId) async {
    try {
      await _medicationService.markDoseTaken(doseId);
      await reload(); // Refresh data
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markDoseSkipped(String doseId) async {
    try {
      await _medicationService.markDoseSkipped(doseId);
      await reload(); // Refresh data
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class MedicationState {
  final List<Medication> medications;
  final List<Dose> upcomingDoses;
  final List<Dose> missedDoses;
  final List<Medication> refillAlerts;
  final bool isLoading;
  final String? error;

  const MedicationState({
    this.medications = const [],
    this.upcomingDoses = const [],
    this.missedDoses = const [],
    this.refillAlerts = const [],
    this.isLoading = false,
    this.error,
  });

  MedicationState copyWith({
    List<Medication>? medications,
    List<Dose>? upcomingDoses,
    List<Dose>? missedDoses,
    List<Medication>? refillAlerts,
    bool? isLoading,
    String? error,
  }) {
    return MedicationState(
      medications: medications ?? this.medications,
      upcomingDoses: upcomingDoses ?? this.upcomingDoses,
      missedDoses: missedDoses ?? this.missedDoses,
      refillAlerts: refillAlerts ?? this.refillAlerts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Assistant Provider
final assistantProvider =
    StateNotifierProvider<AssistantNotifier, AssistantState>((ref) {
  return AssistantNotifier();
});

class AssistantNotifier extends StateNotifier<AssistantState> {
  AssistantNotifier() : super(const AssistantState());

  void sendMessage(String content) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, message],
      isLoading: true,
    );

    // Simulate AI response
    _generateResponse(content);
  }

  Future<void> _generateResponse(String userMessage) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final responses = [
      "I understand you're asking about $userMessage. Let me help you with that.",
      "Based on your medication history, I'd recommend consulting with your healthcare provider.",
      "That's a great question! Here are some things to consider...",
      "I can help you track that information. Would you like me to set up a reminder?",
    ];

    final response = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: responses[DateTime.now().millisecond % responses.length],
      isFromUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, response],
      isLoading: false,
    );
  }

  void clearMessages() {
    state = const AssistantState();
  }
}

class AssistantState {
  final List<ChatMessage> messages;
  final bool isLoading;

  const AssistantState({
    this.messages = const [],
    this.isLoading = false,
  });

  AssistantState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
