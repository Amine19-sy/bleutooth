class History {
  final int id;
  final String userId;
  final String? boxId;
  final String? itemId;
  final String actionType;
  final DateTime actionTime;
  final String? details;

  History({
    required this.id,
    required this.userId,
    this.boxId,
    this.itemId,
    required this.actionType,
    required this.actionTime,
    this.details,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'] as int,
      userId: json['user_id'].toString(),
      boxId: json['box_id'] != null ? json['box_id'].toString() : null,
      itemId: json['item_id'] != null ? json['item_id'].toString() : null,
      actionType: json['action_type'] as String,
      actionTime: DateTime.parse(json['action_time'] as String),
      details: json['details'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'box_id': boxId,
        'item_id': itemId,
        'action_type': actionType,
        'action_time': actionTime.toIso8601String(),
        'details': details,
      };
}
