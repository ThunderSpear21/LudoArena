import 'dart:async';
import 'dart:convert';
import 'dart:typed_data'; // ✅ Import for Uint8List handling
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/io.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  IOWebSocketChannel? _channel;
  final String roomId;
  final List<String> players;
  String? currentTurn;
  StreamSubscription? _streamSubscription;

  GameBloc({required this.roomId, required this.players})
    : super(GameLoading()) {
    on<InitializeGame>(_onInitializeGame);
    on<RollDice>(_onRollDice);
    on<MovePiece>(_onMovePiece);
  }

  void _onInitializeGame(InitializeGame event, Emitter<GameState> emit) async {
    print("🎲 GameBloc received InitializeGame event for room: $roomId");
    emit(GameLoading());

    try {
      _connectWebSocket(); // ✅ Move WebSocket logic to a separate method

      // Send request to fetch initial game state
      _sendMessage({"type": "get_game_state", "roomId": roomId});
    } catch (e) {
      emit(GameError("Failed to connect: ${e.toString()}"));
    }
  }

  void _connectWebSocket() {
    print("🔗 Connecting WebSocket to: ws://10.0.2.2:5000/ws/$roomId");

    try {
      _channel = IOWebSocketChannel.connect(
        "ws://10.0.2.2:5000/ws/$roomId",
      ); // ✅ Correct WebSocket URL

      _streamSubscription = _channel!.stream.listen(
        (message) {
          print("🟢 WebSocket connection established!");
          if (message is Uint8List) {
            message = utf8.decode(message); // ✅ Convert Uint8List to String
          }

          final data = jsonDecode(message);

          if (data["type"] == "game_state") {
            // ✅ Extract player colors and usernames separately
            Map<String, dynamic> playerColorsRaw = Map<String, dynamic>.from(
              data["playerColors"],
            );
            Map<String, String> playerColors = {};
            Map<String, String> playerUsernames =
                {}; // ✅ Store usernames separately

            playerColorsRaw.forEach((sessionId, info) {
              playerColors[sessionId] = info["color"]; // ✅ Extract color
              playerUsernames[sessionId] =
                  info["username"]; // ✅ Extract username
            });

            Map<String, List<List<int>>> playerPieces = data["playerPieces"]
                .map<String, List<List<int>>>(
                  (dynamic k, dynamic v) => MapEntry(
                    k as String,
                    (v as List<dynamic>)
                        .map<List<int>>(
                          (e) => List<int>.from(e as List<dynamic>),
                        )
                        .toList(),
                  ),
                );

            List<String> turnOrder = List<String>.from(data["turnOrder"]);
            currentTurn = data["currentTurn"];
            int diceValue = data["diceValue"] ?? 1;
            emit(
              GameLoaded(
                playerColors: playerColors,
                playerUsernames: playerUsernames, // ✅ Add usernames here
                playerPieces: playerPieces,
                turnOrder: turnOrder,
                currentTurn: currentTurn,
                diceValue: diceValue,
              ),
            );
          } else if (data["type"] == "dice_rolled") {
            emit(
              (state as GameLoaded).copyWith(
                currentTurn: data["currentTurn"],
                diceValue: data["diceValue"],
                isRolling: false, // Stop loading indicator
              ),
            );
          }
          else if (data["type"] == "piece_moved") {
            print("♟️ Piece Moved Event Received: $data");

            if (state is GameLoaded) {
              final currentState = state as GameLoaded;

              // ✅ Extract new and old positions properly
              List<int> newPosition = List<int>.from(
                data["newPosition"] as List<dynamic>,
              );
              List<int> oldPosition = List<int>.from(
                data["oldPosition"] as List<dynamic>,
              );
              String playerId = data["playerId"];

              // ✅ Clone current player pieces
              Map<String, List<List<int>>> updatedPlayerPieces =
                  Map<String, List<List<int>>>.from(currentState.playerPieces);

              if (updatedPlayerPieces.containsKey(playerId)) {
                List<List<int>> pieces = updatedPlayerPieces[playerId] ?? [];

                // ✅ Find and update the correct piece
                for (int i = 0; i < pieces.length; i++) {
                  if (pieces[i][0] == oldPosition[0] &&
                      pieces[i][1] == oldPosition[1]) {
                    pieces[i] = newPosition; // ✅ Move piece to new position
                    break;
                  }
                }

                updatedPlayerPieces[playerId] = pieces;
              }

              emit(
                currentState.copyWith(
                  currentTurn: data["currentTurn"], // ✅ Update turn
                  diceValue: data["diceValue"], // ✅ Update dice value
                  playerPieces: updatedPlayerPieces, // ✅ Update board
                  isRolling: false, // ✅ Hide rolling indicator
                ),
              );
            }
          }
        },
        onDone: () {
          print("🔴 WebSocket closed. Attempting reconnect...");
          _reconnect();
        },
        onError: (error) {
          print("❌ WebSocket Error: $error");
          _reconnect();
        },
      );
    } catch (e) {
      print("❌ WebSocket connection failed: $e");
    }
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_channel != null && _channel!.sink != null) {
      print("📤 Sending WebSocket message: ${jsonEncode(message)}");

      _channel!.sink.add(jsonEncode(message));
    } else {
      print("⚠️ WebSocket is not connected. Message not sent.");
    }
  }

  void _onRollDice(RollDice event, Emitter<GameState> emit) async {
    if (state is GameLoaded) {
      final currentState = state as GameLoaded;

      if (currentState.currentTurn == event.playerId) {
        emit(currentState.copyWith(isRolling: true)); // Show loading indicator

        _sendMessage({
          "type": "roll_dice",
          "roomId": event.roomId,
          "playerId": event.playerId,
        });
      }
    }
  }

  void _onMovePiece(MovePiece event, Emitter<GameState> emit) {
  if (state is GameLoaded) {
    final currentState = state as GameLoaded;

    if (currentState.currentTurn == event.playerId) {
      print("♟️ Sending move request for piece ${event.pieceIndex}");

      _sendMessage({
        "type": "move_piece",
        "roomId": event.roomId,
        "playerId": event.playerId,
        "pieceIndex": event.pieceIndex,
      });
    } else {
      print("⛔ It's not your turn to move!");
    }
  }
}


  void _reconnect() {
    Future.delayed(Duration(seconds: 3), () {
      print("🔄 Reconnecting WebSocket...");
      _connectWebSocket();
    });
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    _channel?.sink.close();
    return super.close();
  }
}
