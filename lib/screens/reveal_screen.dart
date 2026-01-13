import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_logic_provider.dart';
import '../providers/player_notifier.dart';
import '../providers/game_config_notifier.dart'; // Added to access game config
import '../models/game_mode.dart'; // Added to check GameMode

class RevealScreen extends ConsumerStatefulWidget {
  const RevealScreen({super.key});

  @override
  ConsumerState<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends ConsumerState<RevealScreen> {
  double _coverOffset = 0;
  bool _showWord = false;
  bool _hasPeeked = false;

  void _handleDragUpdate(DragUpdateDetails details) {
    double newOffset = _coverOffset + details.primaryDelta!;
    // Clamp limits
    newOffset = newOffset.clamp(-250.0, 0.0);

    // Threshold to reveal text
    final shouldShow = newOffset < -100;

    setState(() {
      _coverOffset = newOffset;
      _showWord = shouldShow;
      if (shouldShow) {
        _hasPeeked = true;
      }
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      // Snap back immediately
      _coverOffset = 0;
      // Hide word immediately
      _showWord = false;
    });
  }

  void _nextPlayer() {
    final players = ref.read(activePlayersProvider);
    final currentIndex = ref.read(currentPlayerIndexProvider);

    if (currentIndex < players.length - 1) {
      ref.read(currentPlayerIndexProvider.notifier).state = currentIndex + 1;
      setState(() {
        _coverOffset = 0;
        _showWord = false;
        _hasPeeked = false;
      });
    } else {
      context.go('/gameplay');
    }
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(activePlayersProvider);
    final currentIndex = ref.watch(currentPlayerIndexProvider);
    final config = ref.watch(gameConfigProvider); // Watch game config
    final theme = Theme.of(context);

    if (players.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Initializing game...', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    final currentPlayer = players[currentIndex];
    final isLastPlayer = currentIndex == players.length - 1;

    // Logic: Only show RED if it is Classic mode. 
    // In Undercover mode, Imposters should look like everyone else (Blue/Primary).
    final bool showImposterStatus = currentPlayer.isImposter && config.gameMode == GameMode.classic;

    final accentColor = showImposterStatus
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
        
    final textOnAccent = showImposterStatus 
        ? Colors.white 
        : theme.colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text('PLAYER ${currentIndex + 1} OF ${players.length}'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Reveal Stack
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Word Layer (Underneath)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(32),
                    height: 320,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          accentColor.withOpacity(showImposterStatus ? 0.9 : 0.82),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      // Shadow removed as requested
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 72,
                          color: textOnAccent,
                        ),
                        const SizedBox(height: 20),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 100),
                          opacity: _showWord ? 1 : 0,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              currentPlayer.assignedWord,
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: textOnAccent,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Cover Layer (Top)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    top: _coverOffset,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onVerticalDragUpdate: _handleDragUpdate,
                      onVerticalDragEnd: _handleDragEnd,
                      child: Container(
                        height: 320,
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.4),
                            width: 1.5,
                          ),
                          // Minimized shadow
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.swipe_up_alt,
                              size: 80,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'PASS PHONE TO',
                              style: theme.textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24, 
                                vertical: 16
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                currentPlayer.name.toUpperCase(),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.touch_app, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Hold Up to Reveal',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),
              
              // Instructions
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _hasPeeked ? 1.0 : 0.5,
                child: Text(
                  _hasPeeked
                      ? 'Memorize your word, then pass the phone!'
                      : 'Swipe up and hold to see your role.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Button
              ElevatedButton.icon(
                onPressed: _hasPeeked ? _nextPlayer : null,
                icon: Icon(isLastPlayer ? Icons.play_arrow : Icons.arrow_forward),
                label: Text(isLastPlayer ? 'START GAME' : 'I UNDERSTAND'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  disabledBackgroundColor: theme.colorScheme.surfaceVariant,
                  disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}