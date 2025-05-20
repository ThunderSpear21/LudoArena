import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ludo_app/utils/session_manager.dart';
import '../bloc/game/game_bloc.dart';
import '../bloc/game/game_event.dart';
import '../bloc/game/game_state.dart';
import '../widgets/ludo_board.dart';

class GameScreen extends StatelessWidget {
  final String roomId;
  final List<String> players; // List of player IDs

  const GameScreen({super.key, required this.roomId, required this.players});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              GameBloc(roomId: roomId, players: players)
                ..add(InitializeGame(roomId: roomId, players: players)),
      child: _GameScreenBody(roomId: roomId),
    );
  }
}

class _GameScreenBody extends StatefulWidget {
  final String roomId;

  const _GameScreenBody({required this.roomId});

  @override
  State<_GameScreenBody> createState() => _GameScreenBodyState();
}

class _GameScreenBodyState extends State<_GameScreenBody> {
  String? sessionId;
  @override
  void initState() {
    super.initState();
    _loadSessionId();
  }

  Future<void> _loadSessionId() async {
    final id = await SessionManager.getSessionId();
    setState(() {
      sessionId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ludo - Room ${widget.roomId}"),
        centerTitle: true,
        backgroundColor: Colors.pink.shade300,
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state is GameLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GameLoaded) {
            return Column(
              children: [
                _buildPlayerLegend(context), // Legend for players
                Expanded(
                  child: LudoBoard(
                    playerColors: state.playerColors,
                    playerPositions: state.playerPieces,
                    onPieceTapped: (playerId, pieceIndex) {
                      if (state.currentTurn != sessionId) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("⛔ Not your turn!"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                      if (playerId == state.currentTurn) {
                        // Send move request to backend (NO local position calculation)
                        context.read<GameBloc>().add(
                          MovePiece(
                            playerId: playerId,
                            pieceIndex: pieceIndex,
                            roomId: widget.roomId,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("⛔ Not your turn!"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                ), // Ludo Board Widget
                const SizedBox(height: 20),
                _buildDice(context),
                const SizedBox(height: 20),
              ],
            );
          } else if (state is GameError) {
            return Center(
              child: Text(
                state.error,
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }
          return Container();
        },
      ),
      backgroundColor: Colors.pink.shade50,
    );
  }

  /// Dice Rolling Widget
  Widget _buildDice(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        if (state is! GameLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: GestureDetector(
            onTap:
                state.isRolling || state.currentTurn != sessionId
                    ? null // Disable tap if rolling or no turn
                    : () => context.read<GameBloc>().add(
                      RollDice(
                        roomId: widget.roomId,
                        playerId: state.currentTurn!,
                      ),
                    ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child:
                    state.isRolling
                        ? const CircularProgressIndicator()
                        : Text(
                          state.diceValue.toString(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Player Legend Widget
  Widget _buildPlayerLegend(BuildContext context) {
    final gameState = context.watch<GameBloc>().state;

    if (gameState is! GameLoaded)
      return SizedBox.shrink(); // If game isn't loaded yet, return empty

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            gameState.playerColors.entries.map((entry) {
              String sessionId = entry.key;
              String username =
                  gameState.playerUsernames[sessionId] ?? "Player";
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getPlayerColor(entry.value),
                      radius: 10,
                    ),
                    const SizedBox(width: 5),
                    Text(username, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Color _getPlayerColor(String color) {
    switch (color) {
      case "Red":
        return Colors.red;
      case "Green":
        return Colors.green;
      case "Blue":
        return Colors.blue;
      case "Yellow":
        return Colors.yellow;
      default:
        return Colors.grey; // Default for safety
    }
  }
}
