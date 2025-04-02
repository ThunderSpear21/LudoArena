abstract class GameEvent {}

class InitializeGame extends GameEvent {
  final String roomId;
  final List<String> players;

  InitializeGame({required this.roomId, required this.players});
}

class RollDice extends GameEvent {
  final String roomId;
  final String playerId; // Identifies which player is rolling

  RollDice({required this.roomId, required this.playerId});
}

class MovePiece extends GameEvent {
  final String playerId;
  final int pieceIndex;
  final String roomId;

  MovePiece({
    required this.playerId,
    required this.pieceIndex,
    required this.roomId,
  });
}
