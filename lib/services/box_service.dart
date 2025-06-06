import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:bleutooth/models/box.dart';
import 'package:bleutooth/models/boxrequest.dart';
import 'package:bleutooth/models/user.dart';
import 'package:bleutooth/services/BaseUrl.dart';

class BoxService {
  final String baseUrl = ChromeUrl;

  Future<List<Box>> fetchUserBoxes(String userId) async {
    final url = Uri.parse('$baseUrl/api/boxes?user_id=$userId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Box.fromJson(json)).toList();
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(
        responseBody['error'] ?? 'An error occurred while fetching boxes.',
      );
    }
  }

  /// ✅ Claim an existing available box
  Future<Box> claimBox({
    required String userId,
    required String userBoxName,
    required String originalName,
    String description = "",
  }) async {
    final url = Uri.parse('$baseUrl/api/claim_box');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'user_id': userId,
        'user_box_name': userBoxName,
        'original_name': originalName.toLowerCase(),
        'description': description,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return Box.fromJson(jsonResponse);
    } else {
      final Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception(
        errorResponse['error'] ?? 'An error occurred while claiming the box.',
      );
    }
  }

  Future<void> requestBoxAccess({
    required int boxId,
    required String inviteeEmail,
    required int ownerId,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/box/request_access'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'box_id': boxId,
        'invitee_email': inviteeEmail,
        'requested_by': ownerId,
      }),
    );
    if (resp.statusCode != 201) {
      throw Exception('Invite failed: ${resp.body}');
    }
  }

  Future<List<BoxAccessRequest>> fetchRequestsSent(int userId) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/box/requests_sent?owner_id=$userId'),
    );
    final json = jsonDecode(resp.body) as List;
    return json.map((e) => BoxAccessRequest.fromJson(e)).toList();
  }

  Future<List<BoxAccessRequest>> fetchRequestsReceived(int userId) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/box/requests_received?user_id=$userId'),
    );
    final json = jsonDecode(resp.body) as List;
    return json.map((e) => BoxAccessRequest.fromJson(e)).toList();
  }

  Future<void> respondRequest(int requestId, bool accept, int userId) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/box/respond_request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'request_id': requestId,
        'accept': accept,
        'user_id': userId,
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('Respond failed: ${resp.body}');
    }
  }

  Future<List<Box>> SharedBoxes(int userId) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/shared_boxes?user_id=$userId'),
    );
    final json = jsonDecode(resp.body) as List;
    return json.map((e) => Box.fromJson(e)).toList();
  }

  Future<List<User>> fetchCollaborators(int boxId) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/box/collaborators?box_id=$boxId'),
    );
    if (resp.statusCode != 200) {
      final error = jsonDecode(resp.body)['error'] ?? resp.body;
      throw Exception('Could not load collaborators: $error');
    }
    final List<dynamic> data = jsonDecode(resp.body);
    return data.map((j) => User.fromJson(j)).toList();
  }

  /// ✅ Send SSID, Password, and User ID via Bluetooth to the box
  Future<void> sendWifiCredentialsViaBluetooth(
    String address,
    String ssid,
    String password,
    String userId,
  ) async {
    try {
      final conn = await BluetoothConnection.toAddress(address);
      final msg = "$ssid,$password,$userId\n";
      conn.output.add(Uint8List.fromList(msg.codeUnits));
      await conn.output.allSent;
      await Future.delayed(const Duration(milliseconds: 500));
      conn.finish(); // Clean disconnect
    } catch (e) {
      throw Exception("Bluetooth send failed: $e");
    }
  }
}
