import 'package:bloc/bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// EVENTS
abstract class SocketEvent {}

class ConnectToSocket extends SocketEvent {}

class DisconnectFromSocket extends SocketEvent {}

class JoinRoom extends SocketEvent {
  final String roomId;
  final String sessionId;
  final String username;

  JoinRoom({required this.roomId, required this.sessionId, required this.username});
}

// STATES
abstract class SocketState {}

class SocketDisconnected extends SocketState {}

class SocketConnected extends SocketState {}

class SocketError extends SocketState {
  final String message;
  SocketError(this.message);
}

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  late IO.Socket socket;

  SocketBloc() : super(SocketDisconnected()) {
    on<ConnectToSocket>(_connect);
    on<DisconnectFromSocket>(_disconnect);
    on<JoinRoom>(_joinRoom);
  }

  void _connect(ConnectToSocket event, Emitter<SocketState> emit) {
    socket = IO.io('http://10.0.2.2:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true, // ✅ Enable auto-reconnection
    });

    socket.connect();

    socket.onConnect((_) {
      print("✅ Connected to WebSocket Server");
      emit(SocketConnected());
    });

    socket.onDisconnect((_) {
      print("❌ Disconnected from WebSocket Server");
      emit(SocketDisconnected());
    });

    // ✅ Handle server errors
    socket.on('error', (data) {
      print("⚠️ WebSocket Error: $data");
      emit(SocketError(data.toString()));
    });
  }

  void _disconnect(DisconnectFromSocket event, Emitter<SocketState> emit) {
    socket.disconnect();
    emit(SocketDisconnected());
  }

  void _joinRoom(JoinRoom event, Emitter<SocketState> emit) {
    if (socket.connected) {
      socket.emit("joinRoom", {
        "roomId": event.roomId,
        "sessionId": event.sessionId,
        "username": event.username
      });
      print("📌 Sent joinRoom event for room: ${event.roomId}");
    } else {
      emit(SocketError("WebSocket not connected"));
    }
  }
}
