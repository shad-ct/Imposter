import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageNotifier extends StateNotifier<AsyncValue<SharedPreferences?>> {
  StorageNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = AsyncValue.data(prefs);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> savePlayerNames(List<String> names) async {
    final prefs = state.value;
    if (prefs != null) {
      await prefs.setStringList('player_names', names);
    }
  }

  List<String> getPlayerNames() {
    final prefs = state.value;
    return prefs?.getStringList('player_names') ?? [];
  }

  Future<void> saveLastCategories(List<String> categories) async {
    final prefs = state.value;
    if (prefs != null) {
      await prefs.setStringList('last_categories', categories);
    }
  }

  List<String> getLastCategories() {
    final prefs = state.value;
    return prefs?.getStringList('last_categories') ?? [];
  }
}

final storageProvider =
    StateNotifierProvider<StorageNotifier, AsyncValue<SharedPreferences?>>((ref) {
  return StorageNotifier();
});
