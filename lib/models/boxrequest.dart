class BoxAccessRequest {
  final int    id;
  final int    boxId;
  final int    userId;
  final int    requestedBy;
  final String status;
  final DateTime requestedAt;
  final DateTime? respondedAt;

  BoxAccessRequest({
    required this.id,
    required this.boxId,
    required this.userId,
    required this.requestedBy,
    required this.status,
    required this.requestedAt,
    this.respondedAt,
  });

  factory BoxAccessRequest.fromJson(Map<String, dynamic> json) {
    return BoxAccessRequest(
      id: json['id'],
      boxId: json['box_id'],
      userId: json['user_id'],
      requestedBy: json['requested_by'],
      status: json['status'],
      requestedAt: DateTime.parse(json['requested_at']),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'])
          : null,
    );
  }
}
