import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/llm/llm_provider.dart';
import '../../../../core/agent/agent_provider.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/assessment_page.dart';
import '../../features/home/presentation/pages/ranking_page.dart';
import '../../features/home/presentation/pages/settings_page.dart';
import '../../features/home/presentation/pages/api_config_page.dart';
import '../../features/home/presentation/widgets/custom_task_view.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => HomePage(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const AssessmentPage()),
          ),
          GoRoute(
            path: '/ranking',
            name: 'ranking',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const RankingPage()),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const SettingsPage()),
          ),
          GoRoute(
            path: '/api-config',
            name: 'api-config',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const ApiConfigPage()),
          ),
          GoRoute(
            path: '/custom-task',
            name: 'custom-task',
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(child: const CustomTaskView()),
          ),
        ],
      ),
    ],
    errorBuilder:
        (context, state) =>
            Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
}
