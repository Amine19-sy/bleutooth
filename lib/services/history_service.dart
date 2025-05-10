import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bleutooth/services/BaseUrl.dart';

class HistoryService{
    
  String baseUrl ='${ChromeUrl}/api';

  Future<List<Map<String, dynamic>>> getHistory(int boxId) async {
  final response = await http.get(Uri.parse('$baseUrl/history/$boxId'));

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception('Failed to fetch history');
  }
}
}