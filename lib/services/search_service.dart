import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bleutooth/services/BaseUrl.dart';

class SearchService {
  final String baseUrl = ChromeUrl;

  /// Fetches boxes with their items grouped by box_id for a given user.
  // Future<List<Map<String, dynamic>>> fetchBoxesGrouped(String userId) async {
  //   final uri = Uri.parse('$baseUrl/api/boxes_items_grouped?user_id=$userId');
  //   final resp = await http.get(uri);

  //   if (resp.statusCode != 200) {
  //     throw Exception('Error fetching grouped boxes: ${resp.statusCode}');
  //   }

  //   final List<dynamic> data = jsonDecode(resp.body);
  //   return data.map((e) => Map<String, dynamic>.from(e)).toList();
  // }
  Future<List<Map<String, dynamic>>> fetchBoxesGrouped(
    String userId, {
    String? dateFrom, 
    String? dateTo, 
    String? addedBy,
  }) async {
    final params = {
      'user_id': userId,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo   != null) 'date_to':   dateTo,
      if (addedBy  != null) 'added_by':  addedBy,
    };
    final uri = Uri.parse('$baseUrl/api/boxes_items_grouped')
        .replace(queryParameters: params);
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Error fetching grouped boxes: ${resp.statusCode}');
    }
    final List<dynamic> data = jsonDecode(resp.body);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> users_suggestions(String userId) async {
    final uri = Uri.parse('$baseUrl/api/user_collaborators')
        .replace(queryParameters: {'user_id': userId});
    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Error fetching collaborators: ${resp.statusCode}');
    }
    final List<dynamic> data = jsonDecode(resp.body);
    // each element has {id, name}
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
