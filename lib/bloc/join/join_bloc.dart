import 'dart:convert';
import 'dart:io'; // Required for SocketException
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'join_event.dart';
import 'join_state.dart';

class JoinBloc extends Bloc<JoinEvent, JoinState> {
  JoinBloc() : super(JoinInitial()) {
    on<JoinGame>(_onJoinGame);
  }

  Future<void> _onJoinGame(JoinGame event, Emitter<JoinState> emit) async {
    emit(JoinLoading());

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/api/room/join"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "roomId": event.roomId,
          "sessionId": event.sessionId,
          "username": event.username,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 400) {
        emit(JoinFailure(error: data["message"] ?? "Failed to join game"));
        return;
      }

      if (data["success"] == true) {
        emit(JoinSuccess(roomId: event.roomId));
      } else {
        emit(JoinFailure(error: data["message"] ?? "Failed to join game"));
      }
    } on SocketException {
      emit(JoinFailure(error: "No internet connection"));
    } on FormatException {
      emit(JoinFailure(error: "Invalid server response"));
    } catch (e) {
      emit(JoinFailure(error: "Unexpected error: ${e.toString()}"));
    }
  }
}
