import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../repositories/word_repository.dart';
import '../models/word_pair.dart';

class GameService {
  // Explicitly set the URL because the DB is in asia-southeast1
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Generate a random 4-letter room code (A-Z)
  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        4, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // Create a new room
  Future<String> createRoom(String playerName, String avatar, String userId) async {
    String roomCode = _generateRoomCode();
    DatabaseReference roomRef = _database.ref().child('rooms').child(roomCode);

    // Check if room code already exists (though unlikely)
    final snapshot = await roomRef.get();
    if (snapshot.exists) {
      // Retry if collision occurs
      return createRoom(playerName, avatar, userId);
    }

    await roomRef.set({
      'host_id': userId,
      'status': 'waiting',
      'status': 'waiting',
      'config': {
        'imposterCount': 1,
        'selectedCategories': ['General'], // Default
        'timerDuration': 60, // Default 60 seconds
        'gameMode': 'undercover', // or 'classic'
        'customCategories': [], // List of {name: 'MyCat', words: ['a','b']}
      },
      'players': {
        userId: {
          'name': playerName,
          'avatar': avatar,
          'is_ready': true,
        }
      }
    });

    return roomCode;
  }

  // Join an existing room
  Future<void> joinRoom(String roomCode, String playerName, String avatar, String userId) async {
    DatabaseReference roomRef = _database.ref().child('rooms').child(roomCode);

    final snapshot = await roomRef.get();
    if (!snapshot.exists) {
      throw Exception('Room not found');
    }

    final roomData = snapshot.value as Map;
    if (roomData['status'] != 'waiting') {
       // Allow re-joining if player is already in game_state (reconnection logic)
       final gameState = roomData['game_state'];
       if (gameState != null && 
           gameState['players'] != null && 
           (gameState['players'] as Map).containsKey(userId)) {
         return; // Already in game, just let UI handle it
       }
       throw Exception('Game already started');
    }

    // Add player to lobby
    await roomRef.child('players').child(userId).set({
      'name': playerName,
      'avatar': avatar,
      'is_ready': true,
    });

    // Remove player on disconnect (ghost handling)
    roomRef.child('players').child(userId).onDisconnect().remove();
  }

  // Host updates game config
  Future<void> updateConfig(String roomCode, int imposterCount, List<String> categories, int timerDuration, String gameMode, [List<Map<String, dynamic>>? customCategories]) async {
    final updates = {
      'imposterCount': imposterCount,
      'selectedCategories': categories,
      'timerDuration': timerDuration,
      'gameMode': gameMode,
    };
    if (customCategories != null) {
      updates['customCategories'] = customCategories;
    }
    await _database.ref().child('rooms').child(roomCode).child('config').update(updates);
  }

  // Start the game
  Future<void> startGame(String roomCode) async {
    final roomRef = _database.ref().child('rooms').child(roomCode);
    
    // 1. Fetch current lobby players and config
    final snapshot = await roomRef.get();
    if (!snapshot.exists) return; // Should not happen

    final roomData = snapshot.value as Map;
    final lobbyPlayersMap = roomData['players'] as Map<dynamic, dynamic>;
    final config = roomData['config'] as Map<dynamic, dynamic>?;
    
    // Default config fallback
    final int imposterCount = config?['imposterCount'] ?? 1;
    final int timerDuration = config?['timerDuration'] ?? 60;
    final String gameMode = config?['gameMode'] ?? 'undercover';
    final List<String> categories = config?['selectedCategories'] != null 
        ? List<String>.from(config!['selectedCategories']) 
        : ['General', 'Food & Drinks', 'Animals', 'Technology']; // Fallback

    if (lobbyPlayersMap.length < 3) {
      // throw Exception("Need at least 3 players"); // Optional: enforce min players
    }

    // Parse custom packs for repository
    final rawCustom = config?['customCategories'] as List?;
    final List<CustomCategoryPack> customPacks = [];
    if (rawCustom != null) {
      for (var item in rawCustom) {
        final map = Map<String, dynamic>.from(item as Map);
        customPacks.add(CustomCategoryPack(
          categoryName: map['categoryName'],
          words: List<String>.from(map['words']),
        ));
      }
    }

    // 2. Assign Roles
    final playerIds = lobbyPlayersMap.keys.toList();
    playerIds.shuffle();
    final imposters = playerIds.take(imposterCount).toSet();
    
    // 3. Pick Word
    WordPair wordPair;
    try {
      // Use Custom Packs alongside standard ones
      // We pass the RAW categories list (which might include custom names)
      // WordRepository logic should check standard first, then custom.
      // But verify WordRepository accepts customPacks.
      wordPair = WordRepository.getRandomPair(categories, customPacks: customPacks);


    } catch (e) {
      wordPair = WordPair(civilian: 'Civilian Word', imposter: 'Imposter Word'); // Fallback
    }

    // 4. Build Game State Players
    final Map<String, dynamic> gameStatePlayers = {};
    
    for (var userId in playerIds) {
      final isImposter = imposters.contains(userId);
      
      String assignedWord;
      if (!isImposter) {
        assignedWord = wordPair.civilian;
      } else {
         if (gameMode == 'classic') {
           assignedWord = "YOU ARE THE IMPOSTER";
         } else {
           // Undercover
           assignedWord = wordPair.imposter;
         }
      }

      gameStatePlayers[userId.toString()] = {
        'name': lobbyPlayersMap[userId]['name'],
        'avatar': lobbyPlayersMap[userId]['avatar'],
        'role': isImposter ? 'imposter' : 'citizen',
        'word': assignedWord,
        'is_alive': true,
      };
    }

    // 5. Atomic Update
    await roomRef.update({
      'status': 'playing',
      'game_state': {
        'players': gameStatePlayers,
        'phase': 'playing', // playing, voting, result
        'started_at': ServerValue.timestamp,
        'round_end_time': ServerValue.timestamp, // Will calculate offset in UI or cloud function if needed, but simple timestamp is better:
        // Actually, just store 'round_start_time' and we know the duration from config.
        // Let's store current round number too
        'round': 1,
        'word_pair': { // Store for reference/reveal later
           'civilian': wordPair.civilian,
           'imposter': wordPair.imposter
        }
      }
    });
  }

  // Voting Logic
  Future<void> setGamePhase(String roomCode, String phase) async {
    final updates = <String, Object?>{
      'game_state/phase': phase,
    };
    if (phase == 'playing') {
       // Reset round timer start when going back to playing
       updates['game_state/started_at'] = ServerValue.timestamp;
    }
    await _database.ref().child('rooms').child(roomCode).update(updates);
  }

  Future<void> castVote(String roomCode, String voterId, String targetId) async {
    final roomRef = _database.ref().child('rooms').child(roomCode);
    
    // Check current votes for this user
    final snapshot = await roomRef.child('game_state/votes/$voterId').get();
    int currentVotes = 0;
    if (snapshot.exists) {
      currentVotes = (snapshot.value as Map).length;
    }
    
    // Check max allowed (imposterCount)
    final configSnap = await roomRef.child('config').get();
    final imposterCount = (configSnap.value as Map)['imposterCount'] as int? ?? 1;
    
    if (currentVotes < imposterCount) {
       // Push new vote
       await roomRef.child('game_state/votes/$voterId').push().set(targetId);
    }
  }

  // Host calculates verdict
  Future<void> calculateVerdict(String roomCode) async {
    final roomRef = _database.ref().child('rooms').child(roomCode);
    final snapshot = await roomRef.child('game_state').get();
    
    if (!snapshot.exists) return;
    final gameState = snapshot.value as Map;

    // Tally votes
    final votesSnapshot = await roomRef.child('game_state/votes').get();
    final voteCounts = <String, int>{};

    if (votesSnapshot.exists) {
      final votesMap = Map<dynamic, dynamic>.from(votesSnapshot.value as Map);
      
      votesMap.forEach((voterId, userVotes) {
         if (userVotes is Map) {
            // New format: Map of voteIds -> targetId
            userVotes.forEach((_, targetId) {
               voteCounts[targetId as String] = (voteCounts[targetId] ?? 0) + 1;
            });
         } else if (userVotes is String) {
            // Legacy format: just targetId
            voteCounts[userVotes] = (voteCounts[userVotes] ?? 0) + 1;
         }
      });
    }

    // Find max
    int maxVotes = 0;
    voteCounts.forEach((_, count) {
      if (count > maxVotes) maxVotes = count;
    });

    final eliminatedIds = voteCounts.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();

    // Result Login
    String result = "skip"; // default to skip if tie
    String? eliminatedId;

    if (maxVotes > 0 && eliminatedIds.length == 1) {
      eliminatedId = eliminatedIds.first;
      
      // Eliminate player
      await roomRef.child('game_state/players/$eliminatedId/is_alive').set(false);
      result = "eliminated";
    } else {
       // Tie or no votes - Skip round
    }
    
    // ALWAYS Clear votes for the next round
    await roomRef.child('game_state/votes').remove();

    // Check Win Conditions
    int impostersAlive = 0;
    int citizensAlive = 0;
    
    // Re-fetch updated players to be safe
    final pSnapshot = await roomRef.child('game_state/players').get();
    if (pSnapshot.exists) {
      final pMap = Map<dynamic, dynamic>.from(pSnapshot.value as Map);
      pMap.forEach((key, value) {
        final p = Map<String, dynamic>.from(value as Map);
        if (p['is_alive'] == true) {
          if (p['role'] == 'imposter') {
            impostersAlive++;
          } else {
            citizensAlive++;
          }
        }
      });
    }

    String? winner;
    if (impostersAlive == 0) {
      winner = "citizens";
    } else if (impostersAlive >= citizensAlive) {
      winner = "imposters";
    }

    if (winner != null) {
       // Game Over
       await roomRef.child('game_state/verdict').set({
        'result': 'game_over',
        'winner': winner,
        'eliminated_id': eliminatedId, // Show who died last
        'timestamp': ServerValue.timestamp,
      });
      await roomRef.child('game_state/phase').set('game_over');
    } else {
      // Round Result
      await roomRef.child('game_state/verdict').set({
        'result': result,
        'eliminated_id': eliminatedId,
        'timestamp': ServerValue.timestamp,
      });
      await roomRef.child('game_state/phase').set('result');
      
      // Increment Round
      final currentRound = gameState['round'] as int? ?? 1;
      await roomRef.child('game_state/round').set(currentRound + 1);
    }
  }

  // Host resets game to lobby
  Future<void> resetGame(String roomCode) async {
    // Keep config, clear game_state, set status to waiting
    await _database.ref().child('rooms').child(roomCode).update({
      'status': 'waiting',
      'game_state': null, // Clear previous game data
    });
  }

  // Listen to room updates
  Stream<DatabaseEvent> getRoomStream(String roomCode) {
    return _database.ref().child('rooms').child(roomCode).onValue;
  }
}
