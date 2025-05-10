class Box {
  final int id;
  final String userId;
  final String name;
  final String description;
  final bool isOpen;
  final DateTime createdAt;

  Box({required this.id, required this.userId, required this.name, required this.description, required this.isOpen, required this.createdAt});

  factory Box.fromJson(Map<String, dynamic> json) {
    return Box(
      id: json['id'],
      userId: json['user_id'].toString(),
      name: json['name'],
      description: json['description'],
      isOpen: json['is_open'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
