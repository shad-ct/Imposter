class WordPair {
  final String civilian;
  final String imposter;

  const WordPair({
    required this.civilian,
    required this.imposter,
  });

  @override
  String toString() => 'WordPair(civilian: $civilian, imposter: $imposter)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordPair &&
        other.civilian == civilian &&
        other.imposter == imposter;
  }

  @override
  int get hashCode => civilian.hashCode ^ imposter.hashCode;
}
