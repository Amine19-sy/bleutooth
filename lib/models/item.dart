import 'dart:convert';
import 'dart:typed_data';

class Item {
  final int id;
  final int boxId;
  final String name;
  final int userId;
  final DateTime addedAt;
  final String? imageData; // base64

  Item({
    required this.id,
    required this.boxId,
    required this.name,
    required this.userId,
    required this.addedAt,
    this.imageData,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      boxId: json['box_id'],
      name: json['name'],
      userId: json['user_id'],
      addedAt: DateTime.parse(json['added_at']),
      imageData: json['image_data'],
    );
  }

  Uint8List? get decodedImage {
    if (imageData == null) return null;
    try {
      return base64Decode(imageData!);
    } catch (_) {
      return null;
    }
  }
}
