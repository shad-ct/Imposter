import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_service_provider.dart';
import '../repositories/word_repository.dart';
import 'active_game_view.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(roomStreamProvider);
    final myUserId = ref.watch(myUserIdProvider);
    final roomCode = ref.watch(currentRoomProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Room: ${roomCode ?? "Unknown"}'),
        actions: [
          IconButton(icon: const Icon(Icons.copy), onPressed: () {}), // Todo: Copy code
        ],
      ),
      body: roomAsync.when(
        data: (event) {
          if (event.snapshot.value == null) {
            return const Center(child: Text("Room deleted or empty"));
          }

          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final status = data['status'] as String;
          final gameState = data['game_state'] as Map<dynamic, dynamic>? ?? {};
          final phase = gameState['phase'] as String? ?? 'playing';

          if (status == 'waiting') {
            return _buildLobbyView(context, ref, data, myUserId, roomCode!);
          } else if (status == 'playing') {
             if (phase == 'voting') {
               return _buildVotingView(context, ref, data, myUserId, roomCode!);
             } else if (phase == 'result') {
               return _buildResultView(context, ref, data, myUserId, roomCode!);
             } else if (phase == 'game_over') {
               return _buildGameOverView(context, ref, data, myUserId, roomCode!);
             }
             return _buildGameView(context, ref, data, myUserId, roomCode!);
          } else {
            return Center(child: Text("Unknown status: $status"));
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildLobbyView(BuildContext context, WidgetRef ref, Map<String, dynamic> data, String myUserId, String roomCode) {
    final playersMap = Map<String, dynamic>.from(data['players'] as Map? ?? {});
    final players = playersMap.values.toList();
    final isHost = data['host_id'] == myUserId;
    
    final config = Map<String, dynamic>.from(data['config'] as Map? ?? {});
    final imposterCount = config['imposterCount'] as int? ?? 1;
    final timerDuration = config['timerDuration'] as int? ?? 60;
    final gameMode = config['gameMode'] as String? ?? 'undercover';
    final selectedCats = (config['selectedCategories'] as List?)?.map((e) => e.toString()).toList() ?? ['General'];
    final customCats = (config['customCategories'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    
    // Combine standard and custom categories for display
    final allCategories = WordRepository.getAllCategories();
    // Add custom ones to the list if not already there
    for (var c in customCats) {
      if (!allCategories.contains(c['categoryName'])) {
        allCategories.add(c['categoryName']);
      }
    }

    return Column(
      children: [
        // Player List
        Expanded(
          flex: 2,
          child: Column(
             children: [
               const Padding(padding: EdgeInsets.all(8), child: Text("PLAYERS", style: TextStyle(fontWeight: FontWeight.bold))),
               Expanded(
                 child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final p = Map<String, dynamic>.from(players[index] as Map);
                      return ListTile(
                        leading: CircleAvatar(child: Text(p['avatar']?.toString().substring(0, 1) ?? "?")),
                        title: Text(p['name'] ?? "Unknown"),
                        subtitle: const Text("Ready"),
                      );
                    },
                  ),
               ),
             ],
          ),
        ),
        const Divider(),
        // Config Section
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("GAME SETTINGS", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Imposters: $imposterCount"),
                if (isHost)
                  Slider(
                    value: imposterCount.toDouble(),
                    min: 1,
                    max: 3, // Logic could be max(1, players.length - 1)
                    divisions: 2,
                    label: imposterCount.toString(),
                     onChanged: (val) {
                        ref.read(gameServiceProvider).updateConfig(roomCode, val.toInt(), selectedCats, timerDuration, gameMode);
                     },
                  ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                      const Text("Categories:"),
                      if (isHost)
                        TextButton.icon(
                          onPressed: () {
                             _showAddCustomCategoryDialog(context, ref, roomCode, config);
                          }, 
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text("Add Custom"),
                        )
                   ],
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: allCategories.map((cat) {
                    final isSelected = selectedCats.contains(cat);
                    return GestureDetector(
                      onLongPress: () {
                         // Show preview dialog
                         final words = WordRepository.getWordsForCategory(cat);
                         showDialog(context: context, builder: (_) => AlertDialog(
                           title: Text(cat),
                           content: SingleChildScrollView(
                             child: Wrap(spacing: 5, children: words.map((w) => Chip(label: Text(w))).toList()),
                           ),
                           actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("CLOSE"))],
                         ));
                      },
                      child: FilterChip(
                        label: Text(
                          cat, 
                          style: TextStyle(
                             color: isSelected ? Colors.black : Colors.white,
                             fontWeight: FontWeight.w500,
                          )
                        ),
                        selected: isSelected,
                        backgroundColor: const Color(0xFF262626), // Dark Grey
                        selectedColor: const Color(0xFFFAFAFA), // White
                        side: BorderSide(
                           color: isSelected ? const Color(0xFFFAFAFA) : const Color(0xFF262626),
                        ),
                        onSelected: isHost ? (val) {
                          List<String> newCats = List.from(selectedCats);
                          if (val) {
                            newCats.add(cat);
                          } else {
                            newCats.remove(cat);
                          }
                          if (newCats.isEmpty) newCats.add(cat); // Prevent empty
                          ref.read(gameServiceProvider).updateConfig(roomCode, imposterCount, newCats, timerDuration, gameMode);
                        } : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Text("Timer: ${timerDuration}s"),
                if (isHost)
                  Slider(
                    value: timerDuration.toDouble(),
                    min: 30,
                    max: 300,
                    divisions: 9, // 30, 60, 90...
                    label: "$timerDuration s",
                    onChanged: (val) {
                       ref.read(gameServiceProvider).updateConfig(roomCode, imposterCount, selectedCats, val.toInt(), gameMode);
                    },
                  ),

                const SizedBox(height: 10),
                const Text("Game Mode:"),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text("Undercover"),
                      selected: gameMode == 'undercover',
                      onSelected: isHost ? (val) {
                         if (val) ref.read(gameServiceProvider).updateConfig(roomCode, imposterCount, selectedCats, timerDuration, 'undercover');
                      } : null,
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text("Classic"),
                      selected: gameMode == 'classic',
                      onSelected: isHost ? (val) {
                         if (val) ref.read(gameServiceProvider).updateConfig(roomCode, imposterCount, selectedCats, timerDuration, 'classic');
                      } : null,
                    ),
                  ],
                ),
                Text(gameMode == 'classic' 
                    ? "Classic: Imposters know they are imposters." 
                    : "Undercover: Imposters get a similar word.",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        // Start Button
        if (isHost)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: players.length >= 3 
                    ? () => ref.read(gameServiceProvider).startGame(roomCode)
                    : null, // Disable if < 3 players
                child: Text(players.length >= 3 ? "START GAME" : "NEED 3 PLAYERS"),
              ),
            ),
          )
        else
          const Padding(
             padding: EdgeInsets.all(20.0),
             child: Text("Waiting for host..."),
          ),
      ],
    );
  }

  Widget _buildGameView(BuildContext context, WidgetRef ref, Map<String, dynamic> data, String myUserId, String roomCode) {
    return ActiveGameView(ref: ref, data: data, myUserId: myUserId, roomCode: roomCode);
  }

  Widget _buildGameViewOld(BuildContext context, WidgetRef ref, Map<String, dynamic> data, String myUserId, String roomCode) {
    if (data['game_state'] == null || data['game_state']['players'] == null) {
      return const Center(child: Text("Initializing game..."));
    }

    final playersMap = Map<String, dynamic>.from(data['game_state']['players'] as Map);
    if (!playersMap.containsKey(myUserId)) {
        return const Center(child: Text("You are spectating"));
    }

    final myData = Map<String, dynamic>.from(playersMap[myUserId] as Map);
    final myRole = myData['role'];
    final myWord = myData['word'] ?? "???";
    final isImposter = myRole == 'imposter';
    final isAlive = myData['is_alive'] == true;

    // Timer Logic
    final gameState = data['game_state'] as Map;
    final int round = gameState['round'] as int? ?? 1;
    final int startedAt = gameState['started_at'] as int? ?? 0;
    final int duration = (data['config']?['timerDuration'] as int?) ?? 60;
    
    // We need a timer that updates. Since this is a ConsumerWidget, it rebuilds on stream updates.
    // However, for a smooth countdown, we might need a separate Timer widget or just rely on manual refresh/stream freq.
    // Riverpod stream updates likely suffice for "rough" seconds.
    // But calculate remaining time:
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - startedAt;
    final remainingMillis = (duration * 1000) - elapsed;
    final remainingSeconds = (remainingMillis / 1000).ceil();
    final displayTime = remainingSeconds > 0 ? remainingSeconds : 0;
    
    // Auto-Vote Logic (Host only)
    if (displayTime == 0 && (data['host_id'] == myUserId)) {
         // Debounce or ensure we call this once. 
         // Since build is called often, we should be careful. 
         // Better to do this via a persistent checker or ensuring it only fires if phase is NOT voting.
         // 'phase' is checked at top of build, but here we can check if we should trigger.
         // Ideally, use a useEffect or listen to stream changes, but here:
         Future.microtask(() {
             // Only switch if we are strictly at 0.
             ref.read(gameServiceProvider).setGamePhase(roomCode, 'voting');
         });
    }

    final otherPlayers = playersMap.entries
        .where((entry) => entry.key != myUserId)
        .map((e) => Map<String, dynamic>.from(e.value as Map))
        .toList();

    // Identity Logic
    // In Undercover mode, EVERYONE looks like a citizen (Blue).
    // In Classic mode, Imposter is Red and sees "YOU ARE THE IMPOSTER".
    final isClassic = (data['config']?['gameMode'] == 'classic');
    final showImposterUI = isImposter && isClassic;
    
    final cardColor = showImposterUI ? Colors.red.shade900 : Colors.blue.shade900;
    final roleText = showImposterUI ? "IMPOSTER" : "CITIZEN"; // Or "PLAYER" for undercover? "CITIZEN" works to blend in.

    return Column(
      children: [
        // Top Bar Info
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
              Padding(padding: const EdgeInsets.all(8), child: Text("Round: $round", style: const TextStyle(fontWeight: FontWeight.bold))),
              Padding(padding: const EdgeInsets.all(8), child: Text("Time: $displayTime s", style: TextStyle(fontWeight: FontWeight.bold, color: displayTime < 10 ? Colors.red : Colors.black))),
           ],
        ),
        // Identity Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: cardColor,
          child: Column(
            children: [
              Text(
                roleText,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                "Your Word: $myWord",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontStyle: FontStyle.italic),
              ),
              if (!isAlive)
                 const Text("(ELIMINATED)", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        
        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: otherPlayers.length,
            itemBuilder: (context, index) {
                final p = otherPlayers[index];
               // p is ALREADY the player map. No processing needed.
               final pAlive = p['is_alive'] == true;
               
               return Card(
                 color: pAlive ? null : Colors.grey.shade400,
                 child: Stack(
                   alignment: Alignment.center,
                   children: [
                     Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                          CircleAvatar(child: Text(p['avatar']?.toString().substring(0, 1) ?? "?")),
                          const SizedBox(height: 10),
                          Text(p['name'] ?? "Unknown"),
                       ],
                     ),
                     if (!pAlive) 
                       const Icon(Icons.close, size: 80, color: Colors.red),
                   ],
                 ),
               );
            },
          ),
        ),
        
        // Actions
        if (isAlive) 
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.how_to_vote),
                label: const Text("END ROUND (VOTE)"),
                onPressed: () {
                   ref.read(gameServiceProvider).setGamePhase(roomCode, 'voting');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildVotingView(BuildContext context, WidgetRef ref, Map<String, dynamic> data, String myUserId, String roomCode) {
    final gameState = data['game_state'] as Map;
    final playersMap = Map<String, dynamic>.from(gameState['players'] as Map);
    final isHost = data['host_id'] == myUserId;

    // Check if I already voted
    final votes = Map<String, dynamic>.from(gameState['votes'] as Map? ?? {});
    // final hasVoted = votes.containsKey(myUserId); // OLD logic

    final activePlayers = playersMap.entries
        .where((e) => e.value['is_alive'] == true)
        .toList();

    // Max votes logic
    final config = Map<String, dynamic>.from(data['config'] as Map? ?? {});
    final maxVotes = config['imposterCount'] as int? ?? 1;

    // Check my votes
    // votes is now potentially Map<voterId, Map|String>
    int myVotesCast = 0;
    if (votes.containsKey(myUserId)) {
       final v = votes[myUserId];
       if (v is Map) {
         myVotesCast = v.length;
       } else {
         myVotesCast = 1;
       }
    }
    final hasFinishedVoting = myVotesCast >= maxVotes;

    // Calculate total expected votes for Host
    // This is tricky if structure is mixed. Assume new structure
    int totalVotesCast = 0;
    votes.forEach((key, val) {
       if (val is Map) totalVotesCast += val.length;
       else totalVotesCast += 1;
    });
    final totalVotesPossible = activePlayers.length * maxVotes;

    return Column(
      children: [
        Container(
          width: double.infinity, 
          padding: const EdgeInsets.all(16),
          color: Colors.orange.shade800,
          child: const Text("VOTING SESSION", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Tap a player to vote (Secretly)", style: TextStyle(fontStyle: FontStyle.italic)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: activePlayers.length,
            itemBuilder: (context, index) {
              final pid = activePlayers[index].key;
              final pData = Map<String, dynamic>.from(activePlayers[index].value as Map);
              final isMe = pid == myUserId;

              return ListTile(
                leading: CircleAvatar(child: Text(pData['avatar'].toString().substring(0,1))),
                title: Text(isMe ? "${pData['name']} (You)" : pData['name']),
                trailing: hasFinishedVoting // Don't show check unless finished? Or maybe show count if allowed?
                    ? const Icon(Icons.check_circle, color: Colors.green) 
                    : const Icon(Icons.circle_outlined),
                onTap: (hasFinishedVoting || isMe) ? null : () {
                   ref.read(gameServiceProvider).castVote(roomCode, myUserId, pid);
                },
              );
            },
          ),
        ),
         if (hasFinishedVoting)
            Padding(padding: const EdgeInsets.all(16), child: Text("Votes cast ($myVotesCast/$maxVotes). Waiting for others...", style: const TextStyle(fontWeight: FontWeight.bold))),
         if (!hasFinishedVoting)
            Padding(padding: const EdgeInsets.all(8), child: Text("You have ${maxVotes - myVotesCast} vote(s) remaining.", style: const TextStyle(color: Colors.red))),
        
        if (isHost)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (totalVotesCast >= totalVotesPossible) 
                    ? () {
                       ref.read(gameServiceProvider).calculateVerdict(roomCode);
                      } 
                    : null, 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(totalVotesCast >= totalVotesPossible 
                   ? "END VOTING & REVEAL" 
                   : "WAITING FOR VOTES ($totalVotesCast/$totalVotesPossible)"),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultView(BuildContext context, WidgetRef ref, Map<String, dynamic> data, String myUserId, String roomCode) {
    final gameState = data['game_state'] as Map;
    final verdict = Map<String, dynamic>.from(gameState['verdict'] as Map? ?? {});
    final isHost = data['host_id'] == myUserId;
    
    final result = verdict['result']; // 'eliminated' or 'skip'
    final eliminatedId = verdict['eliminated_id'];
    
    String message = "No one was eliminated (Tie/Skip).";
    if (result == 'eliminated' && eliminatedId != null) {
       final playersMap = Map<String, dynamic>.from(gameState['players'] as Map);
       final pName = playersMap[eliminatedId]['name'];
       final pRole = playersMap[eliminatedId]['role'];
       message = "$pName was eliminated.\nThey were: ${pRole.toString().toUpperCase()}";
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("VOTING RESULTS", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 50),
            if (isHost)
               ElevatedButton(
                 onPressed: () {
                    // Back to playing
                    ref.read(gameServiceProvider).setGamePhase(roomCode, 'playing');
                 },
                 child: const Text("CONTINUE GAME"),
               )
            else
               const Text("Waiting for host..."),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverView(BuildContext context, WidgetRef ref, Map<String, dynamic> data, String myUserId, String roomCode) {
    final gameState = data['game_state'] as Map;
    final verdict = Map<String, dynamic>.from(gameState['verdict'] as Map? ?? {});
    final isHost = data['host_id'] == myUserId;
    final winner = verdict['winner']; // 'citizens' or 'imposters'
    
    final isImposterWin = winner == 'imposters';
    final color = isImposterWin ? Colors.red : Colors.blue;

    // Find Imposters
    final playersMap = Map<String, dynamic>.from(gameState['players'] as Map);
    final imposters = playersMap.values
        .where((p) => (p as Map)['role'] == 'imposter')
        .map((p) => (p as Map)['name'])
        .join(", ");

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple Animation using AnimatedSwitcher or just standard Scale/Fade transition widgets if we had state.
            // Since this is Stateless, rely on the layout transition or add a simple TweenAnimationBuilder.
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child, 
                  );
              },
              child: Text(isImposterWin ? "IMPOSTERS WIN!" : "CITIZENS WIN!", 
                 style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            ),
            const SizedBox(height: 30),
            
            // Reveal
            const Text("The Imposter(s) were:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
             TweenAnimationBuilder<double>(
               tween: Tween(begin: 0.0, end: 1.0),
               duration: const Duration(milliseconds: 1500), // Slower reveal
               builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
               },
               child: Text(imposters, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
            ),

            const SizedBox(height: 50),
            if (isHost)
               ElevatedButton(
                 onPressed: () {
                    ref.read(gameServiceProvider).resetGame(roomCode);
                 },
                 child: const Text("BACK TO LOBBY"),
               )
            else
               const Text("Waiting for host..."),
          ],
        ),
      ),
    );
  }
  
  void _showAddCustomCategoryDialog(BuildContext context, WidgetRef ref, String roomCode, Map<String, dynamic> currentConfig) {
      final nameCtrl = TextEditingController();
      final wordCtrl = TextEditingController();
      // We need state for the list of words. 
      // Since this is a method, we can't easily hold state unless we use a StatefulBuilder or distinct Widget.
      // Let's use a StatefulBuilder.
      
      showDialog(
        context: context,
        builder: (ctx) {
           List<String> words = [];
           return StatefulBuilder(
             builder: (context, setState) {
               return AlertDialog(
                title: const Text("Add Custom Category"),
                content: SingleChildScrollView(
                  child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Category Name")),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                 controller: wordCtrl, 
                                 decoration: const InputDecoration(labelText: "Add Word"),
                                 onSubmitted: (val) {
                                    if (val.trim().isNotEmpty) {
                                       setState(() {
                                          words.add(val.trim());
                                          wordCtrl.clear();
                                       });
                                    }
                                 },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.blue),
                              onPressed: () {
                                 if (wordCtrl.text.trim().isNotEmpty) {
                                     setState(() {
                                        words.add(wordCtrl.text.trim());
                                        wordCtrl.clear();
                                     });
                                 }
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 5,
                          children: words.map((w) => Chip(
                            label: Text(w),
                            onDeleted: () {
                               setState(() {
                                  words.remove(w);
                               });
                            },
                          )).toList(),
                        ),
                        const SizedBox(height: 5),
                        Text("Min 6 words, Max 12 words. Current: ${words.length}", 
                            style: TextStyle(color: words.length >= 6 && words.length <= 12 ? Colors.green : Colors.red, fontSize: 12)),
                     ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
                  ElevatedButton(
                    onPressed: () {
                       final name = nameCtrl.text.trim();
                       
                       if (name.isEmpty || words.length < 6 || words.length > 12) {
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Invalid input: Need Name + 6-12 words.")));
                          return;
                       }
                       
                       // Add to Custom Categories
                       final existingCustom = (currentConfig['customCategories'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
                       existingCustom.add({
                          'categoryName': name,
                          'words': words
                       });
                       
                       // Update Config
                       final imposterCount = currentConfig['imposterCount'] as int? ?? 1;
                       final selectedCats = (currentConfig['selectedCategories'] as List?)?.map((e) => e.toString()).toList() ?? [];
                       final timerDuration = currentConfig['timerDuration'] as int? ?? 60;
                       final gameMode = currentConfig['gameMode'] as String? ?? 'undercover';
                       
                       // Auto-select the new category
                       if (!selectedCats.contains(name)) {
                          selectedCats.add(name);
                       }
                       
                       ref.read(gameServiceProvider).updateConfig(roomCode, imposterCount, selectedCats, timerDuration, gameMode, existingCustom);
                       Navigator.pop(ctx);
                    },
                    child: const Text("ADD"),
                  )
                ],
              );
             }
           );
        },
      );
  }
}
