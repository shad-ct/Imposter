enum GameMode {
  classic,
  undercover;

  String get displayName {
    switch (this) {
      case GameMode.classic:
        return 'Classic';
      case GameMode.undercover:
        return 'Undercover';
    }
  }

  String get description {
    switch (this) {
      case GameMode.classic:
        return 'Imposters see "YOU ARE THE IMPOSTER"';
      case GameMode.undercover:
        return 'Imposters see a different word';
    }
  }
}
