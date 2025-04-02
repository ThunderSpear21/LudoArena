import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SessionManager {
  static const String _sessionKey = "session_id";

  static Future<String> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString(_sessionKey);

    if (sessionId == null) {
      sessionId = const Uuid().v4(); // Generate new UUID
      await prefs.setString(_sessionKey, sessionId);
    }
    
    return sessionId;
  }
}
