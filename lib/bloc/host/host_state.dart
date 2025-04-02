abstract class HostState {}

class HostInitial extends HostState {}

class HostRoomIdEntered extends HostState {
  final String roomId;
  HostRoomIdEntered({required this.roomId});
}

class HostLoading extends HostState {}

class HostSuccess extends HostState {
  final String roomId;
  HostSuccess({required this.roomId});
}

class HostFailure extends HostState {
  final String error;
  HostFailure({required this.error});
}
