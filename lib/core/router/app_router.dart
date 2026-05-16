import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trade_journal_app/features/auth/presentation/pages/login_page.dart';
import 'package:trade_journal_app/features/auth/presentation/pages/splash_page.dart';
import 'package:trade_journal_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:trade_journal_app/features/home/presentation/pages/home_page.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(Ref ref) {
  // Use listenable to trigger refresh without recreating the router
  final listenable = ValueNotifier<AsyncValue<User?>>(ref.read(authStateProvider));
  
  // Update the listenable whenever auth state changes
  ref.listen<AsyncValue<User?>>(
    authStateProvider,
    (_, next) {
      listenable.value = next;
    },
  );

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = listenable.value;
      final path = state.matchedLocation;

      debugPrint('Router: path=$path, loading=${authState.isLoading}, hasValue=${authState.hasValue}');

      if (authState.isLoading) {
        return path == '/splash' ? null : '/splash';
      }

      final isLoggedIn = authState.value != null;

      if (!isLoggedIn) {
        if (path == '/login') return null;
        return '/login';
      }

      if (isLoggedIn) {
        if (path == '/login' || path == '/splash') return '/';
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
