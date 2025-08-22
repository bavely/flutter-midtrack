import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/medication.dart';
import '../models/chat_message.dart';
import '../services/auth_service.dart';
import '../services/medication_service.dart';
import '../services/secure_storage.dart';

// Theme Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
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
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuthStatus();
  }

  final _authService = AuthService();
  final _storage = SecureStorage();

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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
final medicationProvider = StateNotifierProvider<MedicationNotifier, MedicationState>((ref) {
  return MedicationNotifier();
});

class MedicationNotifier extends StateNotifier<MedicationState> {
  MedicationNotifier() : super(const MedicationState()) {
    _loadMedications();
  }

  final _medicationService = MedicationService();

  Future<void> _loadMedications() async {
    state = state.copyWith(isLoading: true);
    try {
      final medications = await _medicationService.getMedications();
      final upcomingDoses = await _medicationService.getUpcomingDoses();
      state = state.copyWith(
        medications: medications,
        upcomingDoses: upcomingDoses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addMedication(Medication medication) async {
    try {
      final newMedication = await _medicationService.addMedication(medication);
      state = state.copyWith(
        medications: [...state.medications, newMedication],
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> markDoseTaken(String doseId) async {
    try {
      await _medicationService.markDoseTaken(doseId);
      await _loadMedications(); // Refresh data
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markDoseSkipped(String doseId) async {
    try {
      await _medicationService.markDoseSkipped(doseId);
      await _loadMedications(); // Refresh data
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
  final bool isLoading;
  final String? error;

  const MedicationState({
    this.medications = const [],
    this.upcomingDoses = const [],
    this.isLoading = false,
    this.error,
  });

  MedicationState copyWith({
    List<Medication>? medications,
    List<Dose>? upcomingDoses,
    bool? isLoading,
    String? error,
  }) {
    return MedicationState(
      medications: medications ?? this.medications,
      upcomingDoses: upcomingDoses ?? this.upcomingDoses,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Assistant Provider
final assistantProvider = StateNotifierProvider<AssistantNotifier, AssistantState>((ref) {
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