class UserAccountModel {
  final String? id;
  final String? email;
  final String? name;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserAccountModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserAccountModel.fromJson(Map<dynamic, dynamic> json) {
    return UserAccountModel(
      id: json['id']?? 'N/A',
      email: json['email']?? 'N/A',
      name: json['name']?? 'N/A',
      role: json['role']?? 'N/A',
      createdAt: DateTime.tryParse(json['created_at']?? '')?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?? '')?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
