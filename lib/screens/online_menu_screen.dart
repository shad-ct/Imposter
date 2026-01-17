import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_service_provider.dart';

class OnlineMenuScreen extends ConsumerStatefulWidget {
  const OnlineMenuScreen({super.key});

  @override
  ConsumerState<OnlineMenuScreen> createState() => _OnlineMenuScreenState();
}

class _OnlineMenuScreenState extends ConsumerState<OnlineMenuScreen> {
  final _nameController = TextEditingController();
  final _roomCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter display name')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = ref.read(myUserIdProvider);
      // Using a default avatar "A" for now, or could act random
      final avatar = "Avatar_${name.length % 5}"; 
      
      final roomCode = await ref.read(gameServiceProvider).createRoom(name, avatar, userId);
      
      ref.read(currentRoomProvider.notifier).state = roomCode;
      if (mounted) context.push('/game');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinRoom() async {
    final name = _nameController.text.trim();
    final code = _roomCodeController.text.trim().toUpperCase();

    if (name.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter name and room code')));
      return;
    }

    setState(() => _isLoading = true);
    try {
       final userId = ref.read(myUserIdProvider);
       final avatar = "Avatar_${name.length % 5}"; 

       await ref.read(gameServiceProvider).joinRoom(code, name, avatar, userId);
       
       ref.read(currentRoomProvider.notifier).state = code;
       if (mounted) context.push('/game');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Online Multiplayer")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Your Display Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            if (_isLoading) 
              const CircularProgressIndicator()
            else ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _createRoom,
                  icon: const Icon(Icons.add),
                  label: const Text("CREATE NEW ROOM"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700, foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(height: 30),
              const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OR")), Expanded(child: Divider())]),
              const SizedBox(height: 30),
              TextField(
                controller: _roomCodeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: "Enter Room Code (e.g. ABCD)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _joinRoom,
                  icon: const Icon(Icons.login),
                  label: const Text("JOIN ROOM"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
