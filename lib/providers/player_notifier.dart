import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';

const _uuid = Uuid();

class PlayerListNotifier extends StateNotifier<List<String>> {
  PlayerListNotifier() : super([]);

  void addPlayer(String name) {
    if (name.trim().isEmpty) return;
    state = [...state, name.trim()];
  }

  void updatePlayer(int index, String newName) {
    if (newName.trim().isEmpty) return;
    if (index < 0 || index >= state.length) return;
    
    final newList = [...state];
    newList[index] = newName.trim();
    state = newList;
  }

  void removePlayer(int index) {
    if (index < 0 || index >= state.length) return;
    state = [...state]..removeAt(index);
  }

  void reorderPlayers(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    if (newIndex < 0 || newIndex > state.length) return;
    
    final newList = [...state];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    state = newList;
  }

  void clearPlayers() {
    state = [];
  }
}

final playerListProvider =
    StateNotifierProvider<PlayerListNotifier, List<String>>((ref) {
  return PlayerListNotifier();
});

// Active game players with full Player models (after game starts)
class ActivePlayersNotifier extends StateNotifier<List<Player>> {
  ActivePlayersNotifier() : super([]);

  void setPlayers(List<Player> players) {
    state = players;
  }

  void incrementVote(String playerId) {
    state = [
      for (final player in state)
        if (player.id == playerId)
          player.copyWith(voteCount: player.voteCount + 1)
        else
          player
    ];
  }

  void resetVotes() {
    state = [
      for (final player in state) player.copyWith(voteCount: 0)
    ];
  }

  void clearPlayers() {
    state = [];
  }
}

final activePlayersProvider =
    StateNotifierProvider<ActivePlayersNotifier, List<Player>>((ref) {
  return ActivePlayersNotifier();
});
