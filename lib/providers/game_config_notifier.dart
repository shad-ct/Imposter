import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_mode.dart';

class GameConfig {
  final List<String> selectedCategories;
  final int imposterCount;
  final GameMode gameMode;
  final int timerDurationMinutes;

  const GameConfig({
    this.selectedCategories = const [],
    this.imposterCount = 1,
    this.gameMode = GameMode.classic,
    this.timerDurationMinutes = 5,
  });

  GameConfig copyWith({
    List<String>? selectedCategories,
    int? imposterCount,
    GameMode? gameMode,
    int? timerDurationMinutes,
  }) {
    return GameConfig(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      imposterCount: imposterCount ?? this.imposterCount,
      gameMode: gameMode ?? this.gameMode,
      timerDurationMinutes: timerDurationMinutes ?? this.timerDurationMinutes,
    );
  }
}

class GameConfigNotifier extends StateNotifier<GameConfig> {
  GameConfigNotifier() : super(const GameConfig());

  void toggleCategory(String category) {
    final currentCategories = [...state.selectedCategories];
    if (currentCategories.contains(category)) {
      currentCategories.remove(category);
    } else {
      currentCategories.add(category);
    }
    state = state.copyWith(selectedCategories: currentCategories);
  }

  void setImposterCount(int count) {
    state = state.copyWith(imposterCount: count);
  }

  void setGameMode(GameMode mode) {
    state = state.copyWith(gameMode: mode);
  }

  void setTimerDuration(int minutes) {
    state = state.copyWith(timerDurationMinutes: minutes);
  }

  void reset() {
    state = const GameConfig();
  }
}

final gameConfigProvider =
    StateNotifierProvider<GameConfigNotifier, GameConfig>((ref) {
  return GameConfigNotifier();
});
