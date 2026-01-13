import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_logic_provider.dart';
import '../providers/player_notifier.dart';
import '../providers/game_config_notifier.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  const GameplayScreen({super.key});

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    final config = ref.read(gameConfigProvider);
    _remainingSeconds = config.timerDurationMinutes * 60;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      }

      if (_remainingSeconds == 0) {
        _timer?.cancel();
        _showTimeUpDialog();
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('TIME\'S UP!'),
        content: const Text('The discussion time has ended. Time to vote!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/voting');
            },
            child: const Text('PROCEED TO VOTE'),
          ),
        ],
      ),
    );
  }

  void _showAbortDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ABORT GAME?'),
        content: const Text('Are you sure you want to end this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _timer?.cancel();
              ref.read(gameLogicProvider.notifier).resetGame();
              ref.read(gameConfigProvider.notifier).reset();
              ref.read(playerListProvider.notifier).clearPlayers();
              ref.read(currentPlayerIndexProvider.notifier).state = 0;
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('ABORT'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(activePlayersProvider);
    final firstPlayerIndex = ref.watch(firstPlayerIndexProvider);
    final theme = Theme.of(context);

    final firstPlayer = players.isNotEmpty ? players[firstPlayerIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GAMEPLAY'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showAbortDialog,
            tooltip: 'Abort Game',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timer Display
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _remainingSeconds < 60
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_remainingSeconds < 60
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary)
                          .withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isPaused ? 'PAUSED' : 'TIME REMAINING',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _isPaused
                            ? theme.colorScheme.onSecondary
                            : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 80,
                        color: _remainingSeconds < 60
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isPaused ? _resumeTimer : _pauseTimer,
                          icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                          label: Text(_isPaused ? 'RESUME' : 'PAUSE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            _timer?.cancel();
                            context.push('/voting');
                          },
                          icon: const Icon(Icons.how_to_vote),
                          label: const Text('VOTE NOW'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // First Player Info
            if (firstPlayer != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.secondary,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_pin,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${firstPlayer.name.toUpperCase()} STARTS!',
                      style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Player List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
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
                      child: Text(
                        'PLAYERS (${players.length})',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: players.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final player = players[index];
                          final isFirst = index == firstPlayerIndex;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isFirst
                                  ? theme.colorScheme.secondary.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isFirst
                                  ? Border.all(
                                      color: theme.colorScheme.secondary,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isFirst
                                      ? theme.colorScheme.secondary
                                      : theme.colorScheme.primary,
                                  foregroundColor: isFirst
                                      ? theme.colorScheme.onSecondary
                                      : theme.colorScheme.onPrimary,
                                  child: Text('${index + 1}'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    player.name,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                if (isFirst)
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.secondary,
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
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
