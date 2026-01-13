import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/player.dart';
import '../providers/player_notifier.dart';
import '../providers/game_logic_provider.dart';
import '../providers/game_config_notifier.dart';

class GameOverScreen extends ConsumerWidget {
  final String winner;
  final Player? votedOutPlayer;

  const GameOverScreen({
    super.key,
    required this.winner,
    this.votedOutPlayer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPlayers = ref.watch(activePlayersProvider);
    final theme = Theme.of(context);

    final civilianWon = winner == 'Civilians';

    return Scaffold(
      appBar: AppBar(
        title: const Text('GAME OVER'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Winner Announcement
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        civilianWon ? Icons.groups : Icons.dangerous,
                        size: 100,
                        color: civilianWon
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$winner WIN!',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: civilianWon
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (votedOutPlayer != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: votedOutPlayer!.isImposter
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'VOTED OUT:',
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                votedOutPlayer!.name.toUpperCase(),
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: votedOutPlayer!.isImposter
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  votedOutPlayer!.isImposter
                                      ? '🎯 THE IMPOSTER!'
                                      : '😇 INNOCENT',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Reveal All Roles
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ALL ROLES REVEALED',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: allPlayers.length,
                        itemBuilder: (context, index) {
                          final player = allPlayers[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: player.isImposter
                                  ? theme.colorScheme.error.withOpacity(0.2)
                                  : theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: player.isImposter
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  player.isImposter
                                      ? Icons.dangerous
                                      : Icons.check_circle,
                                  color: player.isImposter
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.primary,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        player.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        player.assignedWord,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: player.isImposter
                                              ? theme.colorScheme.error
                                              : theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: player.isImposter
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    player.isImposter ? 'IMPOSTER' : 'CIVILIAN',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Reset game state but keep players
                      ref.read(gameLogicProvider.notifier).resetGame();
                      ref.read(gameConfigProvider.notifier).reset();
                      ref.read(currentPlayerIndexProvider.notifier).state = 0;
                      context.go('/config');
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('PLAY AGAIN'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(gameLogicProvider.notifier).resetGame();
                      ref.read(gameConfigProvider.notifier).reset();
                      ref.read(currentPlayerIndexProvider.notifier).state = 0;
                      context.go('/');
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('BACK TO HOME'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
