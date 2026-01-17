import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/player_notifier.dart';
import '../providers/storage_provider.dart';

class PlayerManagementScreen extends ConsumerStatefulWidget {
  const PlayerManagementScreen({super.key});

  @override
  ConsumerState<PlayerManagementScreen> createState() =>
      _PlayerManagementScreenState();
}

class _PlayerManagementScreenState
    extends ConsumerState<PlayerManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    // Load saved player names only if list is empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentPlayers = ref.read(playerListProvider);
      if (currentPlayers.isEmpty) {
        final storage = ref.read(storageProvider.notifier);
        final savedNames = storage.getPlayerNames();
        if (savedNames.isNotEmpty) {
          for (final name in savedNames) {
            ref.read(playerListProvider.notifier).addPlayer(name);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addOrUpdatePlayer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (_editingIndex != null) {
      ref.read(playerListProvider.notifier).updatePlayer(_editingIndex!, name);
      setState(() {
        _editingIndex = null;
      });
    } else {
      ref.read(playerListProvider.notifier).addPlayer(name);
    }

    _nameController.clear();
    _savePlayerNames();
  }

  void _savePlayerNames() {
    final players = ref.read(playerListProvider);
    ref.read(storageProvider.notifier).savePlayerNames(players);
  }

  void _startEditing(int index, String currentName) {
    setState(() {
      _editingIndex = index;
      _nameController.text = currentName;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
      _nameController.clear();
    });
  }

  void _deletePlayer(int index) {
    ref.read(playerListProvider.notifier).removePlayer(index);
    _savePlayerNames();
  }

  void _proceedToConfig() {
    final players = ref.read(playerListProvider);
    if (players.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least 3 players required!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    context.push('/config');
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playerListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IMPOSTER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi),
            tooltip: "Online Mode",
            onPressed: () => context.push('/online-menu'),
          ),
          if (players.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                ref.read(playerListProvider.notifier).clearPlayers();
                _savePlayerNames();
              },
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Input Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ADD PLAYERS',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: _editingIndex != null
                                ? 'Edit Player Name'
                                : 'Player Name',
                            hintText: 'Enter name...',
                            prefixIcon: const Icon(Icons.person),
                            suffixIcon: _editingIndex != null
                                ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: _cancelEditing,
                                  )
                                : null,
                          ),
                          textCapitalization: TextCapitalization.words,
                          onSubmitted: (_) => _addOrUpdatePlayer(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addOrUpdatePlayer,
                        child: Icon(
                          _editingIndex != null ? Icons.check : Icons.add,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Players: ${players.length} (Min: 3)',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Player List
            Expanded(
              child: players.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.groups,
                            size: 80,
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No players added yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add at least 3 players to start',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: players.length,
                      onReorder: (oldIndex, newIndex) {
                        ref
                            .read(playerListProvider.notifier)
                            .reorderPlayers(oldIndex, newIndex);
                        _savePlayerNames();
                      },
                      itemBuilder: (context, index) {
                        final player = players[index];
                        final isEditing = _editingIndex == index;

                        return Card(
                          key: ValueKey(player + index.toString()),
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: isEditing ? 8 : 4,
                          shadowColor: isEditing
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.primary,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              player,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: theme.colorScheme.tertiary,
                                  ),
                                  onPressed: () => _startEditing(index, player),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: theme.colorScheme.error,
                                  ),
                                  onPressed: () => _deletePlayer(index),
                                ),
                                const Icon(Icons.drag_handle),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: players.length >= 3 ? _proceedToConfig : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('CONFIGURE GAME'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
