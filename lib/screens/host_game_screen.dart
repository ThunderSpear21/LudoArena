import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ludo_app/bloc/host/host_bloc.dart';
import 'package:ludo_app/bloc/host/host_event.dart';
import 'package:ludo_app/bloc/host/host_state.dart';
import 'package:ludo_app/screens/waiting_lobby_screen.dart';
import 'package:uuid/uuid.dart';

class HostGameScreen extends StatefulWidget {
  final String hostId;
  final String username;

  const HostGameScreen({
    super.key,
    required this.hostId,
    required this.username,
  });

  @override
  State<HostGameScreen> createState() => _HostGameScreenState();
}

class _HostGameScreenState extends State<HostGameScreen> {
  late String roomId;

  @override
  void initState() {
    super.initState();
    roomId = const Uuid().v4().substring(0, 6); // Generate short unique roomId
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Host a Game"),
        centerTitle: true,
        backgroundColor: Colors.pink.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocConsumer<HostBloc, HostState>(
          listener: (context, state) {
            if (state is HostSuccess) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WaitingLobbyScreen(roomId: state.roomId),
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableText(
                  "Room ID: $roomId",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                state is HostLoading
                    ? Center(child: const CircularProgressIndicator())
                    : Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // THis line is for testing purpose only !!
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => WaitingLobbyScreen(roomId: roomId)));
                          context.read<HostBloc>().add(
                            HostGame(
                              roomId: roomId,
                              hostId: widget.hostId,
                              username: widget.username,
                            ),
                          );
                          //print({widget.username});
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
                          "Host Game",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
      backgroundColor: Colors.pink.shade50,
    );
  }
}
