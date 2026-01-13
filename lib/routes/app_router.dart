import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/player_management_screen.dart';
import '../screens/game_config_screen.dart';
import '../screens/reveal_screen.dart';
import '../screens/gameplay_screen.dart';
import '../screens/voting_screen.dart';
import '../screens/game_over_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'player-management',
      builder: (context, state) => const PlayerManagementScreen(),
    ),
    GoRoute(
      path: '/config',
      name: 'game-config',
      builder: (context, state) => const GameConfigScreen(),
    ),
    GoRoute(
      path: '/reveal',
      name: 'reveal',
      builder: (context, state) => const RevealScreen(),
    ),
    GoRoute(
      path: '/gameplay',
      name: 'gameplay',
      builder: (context, state) => const GameplayScreen(),
    ),
    GoRoute(
      path: '/voting',
      name: 'voting',
      builder: (context, state) => const VotingScreen(),
    ),
    GoRoute(
      path: '/game-over',
      name: 'game-over',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return GameOverScreen(
          winner: extra?['winner'] ?? 'Unknown',
          votedOutPlayer: extra?['votedOutPlayer'],
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
