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

// import 'package:smart_box/services/BaseUrl.dart';

// class Item {
//   final int id;
//   final String boxId;
//   final String name;
//   final String? description;
//   final String? imagePath;
//   final DateTime addedAt;

//   Item({
//     required this.id,
//     required this.boxId,
//     required this.name,
//     this.imagePath,
//     this.description,
//     required this.addedAt,
//   });

//   factory Item.fromJson(Map<String, dynamic> json) {
//   final String? rawPath = json['image_path'];
//   final String? imageUrl = rawPath != null
//       ? '${BackendUrl}$rawPath' 
//       : null;

//   return Item(
//     id: json['id'],
//     boxId: json['box_id'].toString(),
//     name: json['name'],
//     imagePath: imageUrl,
//     addedAt: DateTime.parse(json['added_at']),
//     description: json['description']
//   );
// }


//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'box_id': boxId,
//         'name': name,
//         'image_path': imagePath,
//         'added_at': addedAt.toIso8601String(),
//         'description': description
//       };
// }