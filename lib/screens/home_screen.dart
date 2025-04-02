import 'package:flutter/material.dart';
import 'package:ludo_app/screens/host_game_screen.dart';
import 'package:ludo_app/screens/join_game_screen.dart';
import '../utils/session_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String? _sessionId; // Nullable to handle loading state
  String _username = "";

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    String sessionId = await SessionManager.getSessionId();
    setState(() {
      _sessionId = sessionId;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LUDO",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Show loading indicator while fetching session ID
            _sessionId == null
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Session ID: $_sessionId",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),

            // ✅ Username Input Field (No need for BlocBuilder)
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Enter Username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _username = value;
                });
              },
            ),

            const SizedBox(height: 40),

            // ✅ Host Game Button
            ElevatedButton(
              onPressed: _username.isNotEmpty && _sessionId != null
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HostGameScreen(
                            hostId: _sessionId!,
                            username: _username,
                          ),
                        ),
                      );
                    }
                  : null, // Disable if username is empty
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade400,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text(
                "Host A Game",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 10),

            // ✅ Join Game Button
            ElevatedButton(
              onPressed: _username.isNotEmpty && _sessionId != null
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => JoinGameScreen(
                            sessionId: _sessionId!,
                            username: _username,
                          ),
                        ),
                      );
                    }
                  : null, // Disable if username is empty
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text(
                "Join A Game",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.pink.shade50,
    );
  }
}
