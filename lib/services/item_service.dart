import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bleutooth/models/item.dart';
import 'package:bleutooth/services/BaseUrl.dart';

class ItemService {
  final String baseUrl = '${ChromeUrl}/api';

  Future<List<Item>> getItems(int boxId) async {
    final response = await http.get(Uri.parse('$baseUrl/items?box_id=$boxId'));

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(response.body);
      return decoded.map((m) => Item.fromJson(m as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  Future<Item> addItem({
    required int boxId,
    required String name,
    required int userId,
    File? imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/add_item');
    final request = http.MultipartRequest('POST', uri);

    request.fields['box_id'] = boxId.toString();
    request.fields['name'] = name;
    request.fields['user_id'] = userId.toString();

    if (imageFile != null && await imageFile.exists()) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      final decoded = json.decode(response.body);
      return Item.fromJson(decoded);
    } else {
      throw Exception('Failed to add item: ${response.body}');
    }
  }

  Future<void> removeItem({
    required int itemId,
    required int userId,
  }) async {
    final uri = Uri.parse('$baseUrl/remove_item/$itemId?user_id=$userId');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to remove item');
    }
  }

  Future<List<Item>> searchItems({
    required String name,
    int? boxId,
  }) async {
    final queryParameters = {
      'name': name,
      if (boxId != null) 'box_id': boxId.toString(),
    };
    final uri = Uri.parse('$ChromeUrl/api/search_items')
        .replace(queryParameters: queryParameters);

    final resp = await http.get(uri);
    if (resp.statusCode != 200) {
      throw Exception('Failed to search items (${resp.statusCode})');
    }

    final List<dynamic> data = json.decode(resp.body);
    return data.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }
}
