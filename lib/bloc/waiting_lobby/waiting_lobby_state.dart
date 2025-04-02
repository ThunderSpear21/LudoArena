import 'package:equatable/equatable.dart';

abstract class WaitingLobbyState extends Equatable {
  const WaitingLobbyState();

  @override
  List<Object?> get props => [];
}

class LobbyLoading extends WaitingLobbyState {}

class LobbyLoaded extends WaitingLobbyState {
  final List<String> players;

  const LobbyLoaded(this.players);

  @override
  List<Object?> get props => [players];
}

class LobbyError extends WaitingLobbyState {
  final String error;

  const LobbyError(this.error);

  @override
  List<Object?> get props => [error];
}

class GameStarted extends WaitingLobbyState {
  final List<String> players;

  const GameStarted(this.players);

  @override
  List<Object?> get props => [players];
}
