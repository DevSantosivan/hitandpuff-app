class BranchModel {
  final String id; // branch_id
  final String name;
  final String email;
  final String? location;

  final String status; // active / blocked
  final String? blockReason;

  final DateTime createdAt;

  BranchModel({
    required this.id,
    required this.name,
    required this.email,
    this.location,
    required this.status,
    this.blockReason,
    required this.createdAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['branch_id']?.toString() ?? json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      location: json['location'] as String?,
      status: json['status'] ?? 'active',
      blockReason: json['block_reason'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_id': id,
      'name': name,
      'email': email,
      'location': location,
      'status': status,
      'block_reason': blockReason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // 🔥 helper methods (optional but useful)
  bool get isBlocked => status == 'blocked';
  bool get isActive => status == 'active';
}
