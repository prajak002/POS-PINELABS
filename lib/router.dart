import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/topup/topup_dashboard.dart';
import 'features/stall/stall_dashboard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final user = authState.user;

      // Show loading screen while checking auth
      if (isLoading) {
        return null;
      }

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && state.uri.toString() != '/login') {
        return '/login';
      }

      // If authenticated and on login page, redirect based on role
      if (isAuthenticated && state.uri.toString() == '/login' && user != null) {
        if (user.isTopupUser) {
          return '/topup-dashboard';
        } else if (user.isStallUser) {
          return '/stall-dashboard'; // Redirect to stall dashboard
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/topup-dashboard',
        name: 'topup-dashboard',
        builder: (context, state) => const TopupDashboard(),
      ),
      GoRoute(
        path: '/stall-dashboard',
        name: 'stall-dashboard',
        builder: (context, state) => const StallDashboard(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
});
