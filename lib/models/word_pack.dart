import 'word_pair.dart';

class WordPack {
  final String categoryName;
  final List<WordPair> pairs;

  const WordPack({
    required this.categoryName,
    required this.pairs,
  });

  @override
  String toString() => 'WordPack(categoryName: $categoryName, pairs: ${pairs.length})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordPack &&
        other.categoryName == categoryName &&
        _listEquals(other.pairs, pairs);
  }

  @override
  int get hashCode => categoryName.hashCode ^ pairs.hashCode;

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
