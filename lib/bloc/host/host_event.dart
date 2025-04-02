import 'package:equatable/equatable.dart';

abstract class HostEvent extends Equatable {
  const HostEvent();

  @override
  List<Object> get props => [];
}

class HostGame extends HostEvent {
  final String roomId;
  final String hostId;
  final String username;

  const HostGame({required this.roomId, required this.hostId, required this.username});

  @override
  List<Object> get props => [roomId, hostId, username];
}
