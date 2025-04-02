import 'package:equatable/equatable.dart';

abstract class JoinEvent extends Equatable {
  const JoinEvent();

  @override
  List<Object> get props => [];
}

class JoinGame extends JoinEvent {
  final String roomId;
  final String username;
  final String sessionId;

  const JoinGame({
    required this.roomId,
    required this.username,
    required this.sessionId,
  });

  @override
  List<Object> get props => [roomId, username, sessionId];
}
