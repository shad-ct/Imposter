import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/player_notifier.dart';

class VotingScreen extends ConsumerStatefulWidget {
  const VotingScreen({super.key});

  @override
  ConsumerState<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends ConsumerState<VotingScreen> {
  void _showVerdict() {
    final players = ref.read(activePlayersProvider);

    if (players.isEmpty) return;

    // Find player(s) with max votes
    final maxVotes = players.map((p) => p.voteCount).reduce((a, b) => a > b ? a : b);

    if (maxVotes == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No votes cast! Please vote for a player.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final votedOutPlayers = players.where((p) => p.voteCount == maxVotes).toList();

    if (votedOutPlayers.length > 1) {
      // Tie - show dialog
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('TIE!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Multiple players have the same votes:'),
              const SizedBox(height: 8),
              ...votedOutPlayers.map((p) => Text('• ${p.name}')),
              const SizedBox(height: 16),
              const Text('Reset votes and vote again!'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                ref.read(activePlayersProvider.notifier).resetVotes();
                Navigator.pop(dialogContext);
              },
              child: const Text('RESET VOTES'),
            ),
          ],
        ),
      );
      return;
    }

    final votedOutPlayer = votedOutPlayers.first;

    // Determine winner
    String winner;
    if (votedOutPlayer.isImposter) {
      winner = 'Civilians';
    } else {
      winner = 'Imposters';
    }

    // Navigate to game over screen
    context.go('/game-over', extra: {
      'winner': winner,
      'votedOutPlayer': votedOutPlayer,
    });
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(activePlayersProvider);
    final theme = Theme.of(context);

    // Each player gets one vote
    final totalVotesAvailable = players.length;
    final totalVotesCast = players.fold<int>(0, (sum, player) => sum + player.voteCount);
    final votesRemaining = (totalVotesAvailable - totalVotesCast).clamp(0, totalVotesAvailable);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VOTING'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Instructions & Vote Counter
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.secondary,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.how_to_vote,
                        color: theme.colorScheme.secondary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Vote for who you think is the imposter!',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Votes used', style: theme.textTheme.bodySmall),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: totalVotesAvailable == 0
                                    ? 0
                                    : totalVotesCast / totalVotesAvailable,
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                color: theme.colorScheme.primary,
                                minHeight: 8,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$totalVotesCast of $totalVotesAvailable cast',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Remaining', style: theme.textTheme.bodySmall),
                            const SizedBox(height: 4),
                            Chip(
                              backgroundColor: votesRemaining > 0
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.error,
                              label: Text(
                                votesRemaining.toString(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: votesRemaining > 0
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onError,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Voting List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  final canVote = votesRemaining > 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            radius: 24,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  player.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.how_to_vote,
                                      size: 16,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '${player.voteCount} ${player.voteCount == 1 ? 'vote' : 'votes'}',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Vote button
                          Container(
                            decoration: BoxDecoration(
                              color: canVote
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withOpacity(0.25),
                              shape: BoxShape.circle,
                              boxShadow: canVote
                                  ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.add,
                                size: 28,
                                color: canVote
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onPrimary.withOpacity(0.6),
                              ),
                              onPressed: canVote
                                  ? () {
                                      ref
                                          .read(activePlayersProvider.notifier)
                                          .incrementVote(player.id);
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(activePlayersProvider.notifier).resetVotes();
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('RESET VOTES'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _showVerdict,
                    icon: const Icon(Icons.gavel),
                    label: const Text('CONFIRM & REVEAL'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
