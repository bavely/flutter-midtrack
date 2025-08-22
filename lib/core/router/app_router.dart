import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../../ui/auth/login_page.dart';
import '../../ui/auth/signup_page.dart';
import '../../ui/auth/forgot_password_page.dart';
import '../../ui/tabs/tabs_scaffold.dart';
import '../../ui/tabs/home_page.dart';
import '../../ui/tabs/calendar_page.dart';
import '../../ui/tabs/assistant_page.dart';
import '../../ui/tabs/profile_page.dart';
import '../../ui/medication/add_medication_page.dart';
import '../../ui/medication/scan_page.dart';
import '../../ui/medication/voice_input_page.dart';
import '../../ui/medication/manual_entry_page.dart';
import '../../ui/medication/confirm_page.dart';
import '../../ui/medication/medication_detail_page.dart';
import '../../ui/modal/about_meditrack_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isLoggingIn = state.matchedLocation.startsWith('/auth');
      
      if (!isLoggedIn && !isLoggingIn) {
        return '/auth/login';
      }
      
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }
      
      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/auth',
        redirect: (context, state) => '/auth/login',
      ),
      GoRoute(
        path: '/auth/login',
        pageBuilder: (context, state) => const MaterialPage(
          child: LoginPage(),
        ),
      ),
      GoRoute(
        path: '/auth/signup',
        pageBuilder: (context, state) => const MaterialPage(
          child: SignupPage(),
        ),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        pageBuilder: (context, state) => const MaterialPage(
          child: ForgotPasswordPage(),
        ),
      ),
      
      // Main App Routes with Tab Navigation
      ShellRoute(
        builder: (context, state, child) => TabsScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/calendar',
            name: 'calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarPage(),
            ),
          ),
          GoRoute(
            path: '/assistant',
            name: 'assistant',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AssistantPage(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),
      
      // Medication Routes
      GoRoute(
        path: '/medication/add',
        pageBuilder: (context, state) => const MaterialPage(
          child: AddMedicationPage(),
        ),
      ),
      GoRoute(
        path: '/medication/scan',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: ScanPage(),
        ),
      ),
      GoRoute(
        path: '/medication/voice',
        pageBuilder: (context, state) => const MaterialPage(
          child: VoiceInputPage(),
        ),
      ),
      GoRoute(
        path: '/medication/manual',
        pageBuilder: (context, state) => const MaterialPage(
          child: ManualEntryPage(),
        ),
      ),
      GoRoute(
        path: '/medication/confirm',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MaterialPage(
            child: ConfirmPage(medicationData: extra),
          );
        },
      ),
      GoRoute(
        path: '/medication/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialPage(
            child: MedicationDetailPage(medicationId: id),
          );
        },
      ),
      
      // Modal Routes
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: AboutMediTrackPage(),
        ),
      ),
    ],
  );
});