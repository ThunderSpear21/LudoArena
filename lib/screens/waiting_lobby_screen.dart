import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ludo_app/utils/session_manager.dart';
import '../bloc/waiting_lobby/waiting_lobby_bloc.dart';
import '../bloc/waiting_lobby/waiting_lobby_event.dart';
import '../bloc/waiting_lobby/waiting_lobby_state.dart';
import 'game_screen.dart';

class WaitingLobbyScreen extends StatelessWidget {
  final String roomId;

  const WaitingLobbyScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              WaitingLobbyBloc(roomId: roomId)..add(LoadPlayers(roomId)),
      child: _WaitingLobbyScreenBody(roomId: roomId),
    );
  }
}

class _WaitingLobbyScreenBody extends StatefulWidget {
  final String roomId;
  const _WaitingLobbyScreenBody({required this.roomId});

  @override
  State<_WaitingLobbyScreenBody> createState() =>
      _WaitingLobbyScreenBodyState();
}

class _WaitingLobbyScreenBodyState extends State<_WaitingLobbyScreenBody> {
  String _sessionId = '';  // Store the session ID
  
  @override
  void initState() {
    super.initState();
    _initializeSession();  // Fetch the session ID
  }

  // Fetch session ID asynchronously
  Future<void> _initializeSession() async {
    String sessionId = await SessionManager.getSessionId();
    setState(() {
      _sessionId = sessionId;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<WaitingLobbyBloc, WaitingLobbyState>(
      listener: (context, state) {
        if (state is GameStarted) {
          print("Now Navigating from Waiting Screen to Game Screen");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => GameScreen(
                    roomId: widget.roomId,
                    players: state.players, // Pass actual players list
                  ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Room ${widget.roomId}"),
          centerTitle: true,
          backgroundColor: Colors.pink.shade300,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Players in Lobby:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              BlocBuilder<WaitingLobbyBloc, WaitingLobbyState>(
                builder: (context, state) {
                  if (state is LobbyLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is LobbyLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...state.players
                            .map(
                              (player) => Text(
                                player,
                                style: const TextStyle(fontSize: 16),
                              ),
                            )
                            .toList(),
                        if (state.hostId ==  _sessionId)
                        const SizedBox(height: 100,),
                        if (state.hostId ==  _sessionId)
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              final currentState =
                                  context.read<WaitingLobbyBloc>().state;
                              if (currentState is LobbyLoaded) {
                                context.read<WaitingLobbyBloc>().add(
                                  StartGame(
                                    widget.roomId,
                                    currentState.players,
                                  ),
                                );
                              }
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
                            child: const Text(
                              "Start Game",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (state is LobbyError) {
                    return Text(
                      state.error,
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
        backgroundColor: Colors.pink.shade50,
      ),
    );
  }
}
