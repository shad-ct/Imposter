import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../models/game_mode.dart';
import '../models/word_pair.dart';
import '../repositories/word_repository.dart';
import 'player_notifier.dart';
import 'game_config_notifier.dart';
import 'custom_categories_notifier.dart';

const _uuid = Uuid();

class GameLogicNotifier extends StateNotifier<AsyncValue<List<Player>>> {
  final Ref ref;

  GameLogicNotifier(this.ref) : super(const AsyncValue.data([]));

  Future<void> initializeGame() async {
    state = const AsyncValue.loading();

    try {
      final playerNames = ref.read(playerListProvider);
      final config = ref.read(gameConfigProvider);
      final customCategories = ref.read(customCategoriesProvider);

      if (playerNames.length < 3) {
        throw Exception('At least 3 players required');
      }

      if (config.selectedCategories.isEmpty) {
        throw Exception('At least one category must be selected');
      }

      if (config.imposterCount >= playerNames.length) {
        throw Exception('Imposter count must be less than total players');
      }

      // Get a random word pair (include custom categories)
      final wordPair = WordRepository.getRandomPair(
        config.selectedCategories,
        customPacks: customCategories,
      );

      // Shuffle players and assign roles
      final shuffledIndices = List.generate(playerNames.length, (i) => i);
      shuffledIndices.shuffle();

      final imposterIndices = shuffledIndices.take(config.imposterCount).toSet();

      final players = List.generate(playerNames.length, (index) {
        final isImposter = imposterIndices.contains(index);
        final assignedWord = _getAssignedWord(
          isImposter: isImposter,
          wordPair: wordPair,
          gameMode: config.gameMode,
        );

        return Player(
          id: _uuid.v4(),
          name: playerNames[index],
          isImposter: isImposter,
          assignedWord: assignedWord,
        );
      });

      // Update active players
      ref.read(activePlayersProvider.notifier).setPlayers(players);

      state = AsyncValue.data(players);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  String _getAssignedWord({
    required bool isImposter,
    required WordPair wordPair,
    required GameMode gameMode,
  }) {
    if (!isImposter) {
      return wordPair.civilian;
    }

    // Imposter logic
    if (gameMode == GameMode.classic) {
      return 'YOU ARE THE IMPOSTER';
    } else {
      // Undercover mode
      return wordPair.imposter;
    }
  }

  void resetGame() {
    state = const AsyncValue.data([]);
    ref.read(activePlayersProvider.notifier).clearPlayers();
  }
}

final gameLogicProvider =
    StateNotifierProvider<GameLogicNotifier, AsyncValue<List<Player>>>((ref) {
  return GameLogicNotifier(ref);
});

// Current player index for reveal screen
final currentPlayerIndexProvider = StateProvider<int>((ref) => 0);

// Random first player for gameplay
final firstPlayerIndexProvider = Provider<int>((ref) {
  final players = ref.watch(activePlayersProvider);
  if (players.isEmpty) return 0;
  return DateTime.now().millisecondsSinceEpoch % players.length;
});

// Timer state
class TimerState {
  final int remainingSeconds;
  final bool isRunning;
  final bool isPaused;

  const TimerState({
    required this.remainingSeconds,
    this.isRunning = false,
    this.isPaused = false,
  });

  TimerState copyWith({
    int? remainingSeconds,
    bool? isRunning,
    bool? isPaused,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier(int initialSeconds)
      : super(TimerState(remainingSeconds: initialSeconds));

  void start() {
    state = state.copyWith(isRunning: true, isPaused: false);
  }

  void pause() {
    state = state.copyWith(isPaused: true);
  }

  void resume() {
    state = state.copyWith(isPaused: false);
  }

  void tick() {
    if (state.isRunning && !state.isPaused && state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    }
  }

  void reset(int seconds) {
    state = TimerState(remainingSeconds: seconds);
  }
}

final timerProvider =
    StateNotifierProvider.family<TimerNotifier, TimerState, int>((ref, initialSeconds) {
  return TimerNotifier(initialSeconds);
});
