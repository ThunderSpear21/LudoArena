import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'host_event.dart';
import 'host_state.dart';

class HostBloc extends Bloc<HostEvent, HostState> {
  HostBloc() : super(HostInitial()) {
    on<HostGame>(_onHostGame);
  }

  Future<void> _onHostGame(HostGame event, Emitter<HostState> emit) async {
    emit(HostLoading());

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/api/room/create"), // ✅ Corrected endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "roomId": event.roomId,  // ✅ Moved roomId to body
          "hostId": event.hostId,
          "username": event.username,
        }),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data["success"] == true) {
        emit(HostSuccess(roomId: event.roomId));
      } else {
        emit(HostFailure(error: data["message"] ?? "Failed to host game"));
      }
    } catch (e) {
      print("❌ Error hosting game: $e"); // ✅ Improved error logging
      emit(HostFailure(error: "Error: ${e.toString()}"));
    }
  }
}
