import 'dart:convert';
import 'package:http/http.dart' as http;

class BoxControlService {
  final String baseUrl = "https://groupeproject.vercel.app/";

  Future<bool> sendCommand(String command, int boxId) async {
    final url = Uri.parse('${baseUrl}api/send_command');
    final payload = {"command": command, "box_id": boxId};
    print("📤 Sending command: $payload");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      print("📥 Response (${response.statusCode}): ${response.body}");

      return response.statusCode == 201;
    } catch (e) {
      print("❌ Error sending command: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchLastTemperature(int boxId) async {
    final url = Uri.parse('${baseUrl}api/last_temperature?box_id=$boxId');
    print("📡 Fetching temperature for box $boxId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("⚠️ Failed to fetch temperature: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching temperature: $e");
      return null;
    }
  }
}
