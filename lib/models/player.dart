class Player {
  final String id;
  final String name;
  final bool isImposter;
  final String assignedWord;
  final int voteCount;

  const Player({
    required this.id,
    required this.name,
    required this.isImposter,
    required this.assignedWord,
    this.voteCount = 0,
  });

  Player copyWith({
    String? id,
    String? name,
    bool? isImposter,
    String? assignedWord,
    int? voteCount,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      isImposter: isImposter ?? this.isImposter,
      assignedWord: assignedWord ?? this.assignedWord,
      voteCount: voteCount ?? this.voteCount,
    );
  }

  @override
  String toString() =>
      'Player(id: $id, name: $name, isImposter: $isImposter, assignedWord: $assignedWord, voteCount: $voteCount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player &&
        other.id == id &&
        other.name == name &&
        other.isImposter == isImposter &&
        other.assignedWord == assignedWord &&
        other.voteCount == voteCount;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      isImposter.hashCode ^
      assignedWord.hashCode ^
      voteCount.hashCode;
}
