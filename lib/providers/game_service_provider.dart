import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../services/game_service.dart';

final gameServiceProvider = Provider<GameService>((ref) {
  return GameService();
});

// Generate a unique ID for this session
final myUserIdProvider = Provider<String>((ref) {
  return const Uuid().v4();
});

final currentRoomProvider = StateProvider<String?>((ref) => null);

final roomStreamProvider = StreamProvider<DatabaseEvent>((ref) {
  final gameService = ref.watch(gameServiceProvider);
  final roomCode = ref.watch(currentRoomProvider);

  if (roomCode == null) {
    return const Stream.empty();
  }

  return gameService.getRoomStream(roomCode);
});
