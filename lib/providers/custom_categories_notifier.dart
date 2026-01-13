import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/word_pack.dart';
import '../models/word_pair.dart';

class CustomCategoriesNotifier extends StateNotifier<List<WordPack>> {
  CustomCategoriesNotifier() : super([]);

  void addCategory(String categoryName, List<String> words) {
    if (categoryName.trim().isEmpty || words.length < 6) return;

    // Create pairs by pairing consecutive words
    final pairs = <WordPair>[];
    for (int i = 0; i < words.length - 1; i++) {
      pairs.add(WordPair(
        civilian: words[i].trim(),
        imposter: words[i + 1].trim(),
      ));
    }

    final newPack = WordPack(
      categoryName: categoryName.trim(),
      pairs: pairs,
    );

    // Check if category already exists
    final existingIndex =
        state.indexWhere((pack) => pack.categoryName == categoryName.trim());
    if (existingIndex >= 0) {
      final newState = [...state];
      newState[existingIndex] = newPack;
      state = newState;
    } else {
      state = [...state, newPack];
    }
  }

  void removeCategory(String categoryName) {
    state = state.where((pack) => pack.categoryName != categoryName).toList();
  }

  void clearAll() {
    state = [];
  }
}

final customCategoriesProvider =
    StateNotifierProvider<CustomCategoriesNotifier, List<WordPack>>((ref) {
  return CustomCategoriesNotifier();
});
