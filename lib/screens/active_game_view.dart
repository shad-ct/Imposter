import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_service_provider.dart';

class ActiveGameView extends StatefulWidget {
  final WidgetRef ref;
  final Map<String, dynamic> data;
  final String myUserId;
  final String roomCode;

  const ActiveGameView({
    super.key, 
    required this.ref, 
    required this.data, 
    required this.myUserId, 
    required this.roomCode
  });

  @override
  State<ActiveGameView> createState() => _ActiveGameViewState();
}

class _ActiveGameViewState extends State<ActiveGameView> {
  // We use a periodic timer stream to trigger rebuilds every second
  Stream<int>? _timerStream;
  
  @override
  void initState() {
    super.initState();
    _timerStream = Stream.periodic(const Duration(seconds: 1), (x) => x);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _timerStream,
      builder: (context, snapshot) {
          final data = widget.data;
          final ref = widget.ref;
          final myUserId = widget.myUserId;
          final roomCode = widget.roomCode;
          
          final gameState = data['game_state'] as Map;
          final config = Map<String, dynamic>.from(data['config'] as Map? ?? {});
          final playersMap = Map<String, dynamic>.from(gameState['players'] as Map);
          
          final myPlayer = Map<String, dynamic>.from(playersMap[myUserId] as Map? ?? {});
          final isImposter = myPlayer['role'] == 'imposter';
          final myWord = myPlayer['word'];
          final isAlive = myPlayer['is_alive'] == true;
          final round = gameState['round'] as int? ?? 1;

          // Timer Logic
          final startedAt = gameState['started_at'] as int? ?? 0;
          final duration = config['timerDuration'] as int? ?? 60;
          final now = DateTime.now().millisecondsSinceEpoch;
          
          final elapsed = now - startedAt;
          final remainingMillis = (duration * 1000) - elapsed;
          final remainingSeconds = (remainingMillis / 1000).ceil();
          final displayTime = remainingSeconds > 0 ? remainingSeconds : 0;
          
          // Auto-Vote Logic (Host only)
          if (displayTime == 0 && (data['host_id'] == myUserId)) {
               // Using microtask to allow build to finish
               Future.microtask(() {
                   // Only trigger if phase is not already voting? GameService handles it usually
                   ref.read(gameServiceProvider).setGamePhase(roomCode, 'voting');
               });
          }

          final activePlayers = playersMap.entries
              .where((e) => e.value['is_alive'] == true)
              .toList();

          // Identity Logic
          final isClassic = (data['config']?['gameMode'] == 'classic');
          final showImposterUI = isImposter && isClassic;
          
          final cardColor = showImposterUI ? Colors.red.shade900 : Colors.blue.shade900;
          final roleText = showImposterUI ? "IMPOSTER" : "CITIZEN"; 

          return Column(
            children: [
              // Top Bar Info
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Padding(padding: const EdgeInsets.all(8), child: Text("Round: $round", style: const TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: const EdgeInsets.all(8), child: Text("Time: $displayTime s", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: displayTime < 10 ? Colors.red : Colors.black))),
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
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
                  itemCount: activePlayers.length,
                  itemBuilder: (context, index) {
                     final pData = Map<String, dynamic>.from(activePlayers[index].value as Map);
                     final pid = activePlayers[index].key;
                     final isMe = pid == myUserId;
                     
                     return Container(
                       decoration: BoxDecoration(
                         color: Colors.grey[200],
                         borderRadius: BorderRadius.circular(8),
                         border: isMe ? Border.all(color: Colors.blue, width: 2) : null,
                       ),
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           CircleAvatar(child: Text(pData['avatar'].toString().substring(0,1))),
                           const SizedBox(height: 5),
                           Text(pData['name'], overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                         ],
                       ),
                     );
                  },
                ),
              ),
              if (widget.data['host_id'] == myUserId)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                         widget.ref.read(gameServiceProvider).setGamePhase(roomCode, 'voting');
                      }, 
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text("END ROUND (VOTE)"),
                    ),
                  ),
                )
            ],
          );
      }
    );
  }
}
