import 'package:equatable/equatable.dart';

abstract class WaitingLobbyEvent extends Equatable {
  const WaitingLobbyEvent();

  @override
  List<Object> get props => [];
}

class LoadPlayers extends WaitingLobbyEvent {
  final String roomId;

  const LoadPlayers(this.roomId);

  @override
  List<Object> get props => [roomId];
}

class StartGame extends WaitingLobbyEvent {
  final String roomId;
  final List<String> players;

  const StartGame(this.roomId, this.players);

  @override
  List<Object> get props => [roomId, players];
}
class PlayersUpdated extends WaitingLobbyEvent {
  final List<String> players;
  PlayersUpdated(this.players);
}

class GameStartedEvent extends WaitingLobbyEvent {
  final List<String> players;
  GameStartedEvent(this.players);
}