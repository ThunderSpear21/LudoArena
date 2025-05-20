import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/io.dart';
import 'waiting_lobby_event.dart';
import 'waiting_lobby_state.dart';

class WaitingLobbyBloc extends Bloc<WaitingLobbyEvent, WaitingLobbyState> {
  IOWebSocketChannel? _channel;
  final String roomId;

  WaitingLobbyBloc({required this.roomId}) : super(LobbyLoading()) {
    on<LoadPlayers>(_onLoadPlayers);
    on<StartGame>(_onStartGame);
    on<PlayersUpdated>((event, emit) => emit(LobbyLoaded(event.players, event.hostId)));
    on<GameStartedEvent>((event, emit) => emit(GameStarted(event.players)));

  }
  
  Future<void> _onLoadPlayers(
    LoadPlayers event,
    Emitter<WaitingLobbyState> emit,
  ) async {
    emit(LobbyLoading());

    try {
      // Connect to WebSocket for real-time updates
      _channel = IOWebSocketChannel.connect("ws://10.0.2.2:5000/");

      _channel!.stream.listen((message) {
        if (message is Uint8List) {
          message = utf8.decode(message); // ✅ Convert binary data to String
        }
        final data = jsonDecode(message);
        print("data in lobby bloc : $data");
        if (data["type"] == "player_list") {
          List<String> players =
              data["players"]
                  .map<String>(
                    (player) => player["username"].toString(),
                  ) // Extract only usernames
                  .toList();
          String hostId = data["hostId"].toString();
          print("📢 Players list received: $players");
          add(PlayersUpdated(players,hostId));
        } else if (data["type"] == "game_started") {
          List<String> players =
              data["players"]
                  .map<String>(
                    (player) => player["username"].toString(),
                  ) // Extract usernames
                  .toList();
          print("📢 Game has started : $players");
          add(GameStartedEvent(players)); // 🔥 Dispatch event instead of emit
        }
      });

      // Request the initial player list
      _channel!.sink.add(jsonEncode({"type": "get_players", "roomId": roomId}));
    } catch (e) {
      emit(LobbyError("Failed to connect: ${e.toString()}"));
    }
  }

  void _onStartGame(StartGame event, Emitter<WaitingLobbyState> emit) {
    _channel?.sink.add(jsonEncode({"type": "start_game", "roomId": roomId}));
    print("📢 Game has started : $event");
    emit(GameStarted(event.players));
  }

  @override
  Future<void> close() {
    _channel?.sink.close();
    return super.close();
  }
}
