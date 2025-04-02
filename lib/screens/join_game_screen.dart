import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ludo_app/screens/waiting_lobby_screen.dart';
import '../bloc/join/join_bloc.dart';
import '../bloc/join/join_event.dart';
import '../bloc/join/join_state.dart';

class JoinGameScreen extends StatefulWidget {
  final String username;
  final String sessionId;

  const JoinGameScreen({
    super.key,
    required this.username,
    required this.sessionId,
  });

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final TextEditingController _roomIdController = TextEditingController();

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Close keyboard on tap
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Join a Game"),
          centerTitle: true,
          backgroundColor: Colors.pink.shade300,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocConsumer<JoinBloc, JoinState>(
            listener: (context, state) {
              if (state is JoinSuccess) {
                final roomId = _roomIdController.text.trim(); // Store value safely
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => WaitingLobbyScreen(roomId: roomId),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🎲 Room ID Input Field
                  TextField(
                    controller: _roomIdController,
                    decoration: InputDecoration(
                      labelText: "Enter Room ID",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 20),

                  // 🔴 Show Error Message if Joining Fails
                  if (state is JoinFailure)
                    Text(
                      state.error,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  const SizedBox(height: 20),

                  // 🏁 Join Game Button
                  ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus(); // Hide keyboard
                      String roomId = _roomIdController.text.trim();

                      if (roomId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Room ID cannot be empty"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      context.read<JoinBloc>().add(
                            JoinGame(
                              roomId: roomId,
                              username: widget.username,
                              sessionId: widget.sessionId,
                            ),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade400,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: state is JoinLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Join Game",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
        backgroundColor: Colors.pink.shade50,
      ),
    );
  }
}
