import 'package:equatable/equatable.dart';

abstract class JoinState extends Equatable {
  const JoinState();

  @override
  List<Object> get props => [];
}

class JoinInitial extends JoinState {
  const JoinInitial();
}

class JoinLoading extends JoinState {
  const JoinLoading();
}

class JoinSuccess extends JoinState {
  final String roomId;
  const JoinSuccess({required this.roomId});

  @override
  List<Object> get props => [roomId];
}

class JoinFailure extends JoinState {
  final String error;
  const JoinFailure({required this.error});

  @override
  List<Object> get props => [error];
}
