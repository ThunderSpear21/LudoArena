abstract class GameState {}

class GameLoading extends GameState {}

class GameLoaded extends GameState {
  final Map<String, String> playerColors;
  final Map<String, List<List<int>>> playerPieces;
  final Map<String, String> playerUsernames;
  final List<String> turnOrder;
  final String? currentTurn; // NEW: Track current player's turn
  final int? diceValue;
  final bool isRolling;

  GameLoaded({
    required this.playerColors,
    required this.playerPieces,
    required this.playerUsernames,
    required this.turnOrder,
    this.currentTurn, // NEW: Optional current turn player
    this.diceValue,
    this.isRolling = false,
  });

  GameLoaded copyWith({
    Map<String, String>? playerColors,
    Map<String, List<List<int>>>? playerPieces,
    Map<String, String>? playerUsernames,
    List<String>? turnOrder,
    String? currentTurn,
    int? diceValue,
    bool? isRolling,
  }) {
    return GameLoaded(
      playerColors: playerColors ?? this.playerColors,
      playerPieces: playerPieces ?? this.playerPieces,
      playerUsernames: playerUsernames ?? this.playerUsernames,
      turnOrder: turnOrder ?? this.turnOrder,
      currentTurn: currentTurn ?? this.currentTurn, // Ensure it's copied
      diceValue: diceValue ?? this.diceValue,
      isRolling: isRolling ?? this.isRolling,
    );
  }
}


class GameError extends GameState {
  final String error;
  GameError(this.error);
}
