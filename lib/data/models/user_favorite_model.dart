class UserFavoriteModel {
  final String id;
  final String userId;
  final FavoriteItemType itemType;
  final String itemId;
  final DateTime createdAt;

  UserFavoriteModel({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    required this.createdAt,
  });

  UserFavoriteModel copyWith({
    String? id,
    String? userId,
    FavoriteItemType? itemType,
    String? itemId,
    DateTime? createdAt,
  }) {
    return UserFavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'item_type': itemType.value,
      'item_id': itemId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserFavoriteModel.fromMap(Map<String, dynamic> map) {
    return UserFavoriteModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      itemType: FavoriteItemType.fromString(map['item_type'] ?? 'package'),
      itemId: map['item_id'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  @override
  String toString() {
    return 'UserFavoriteModel(id: $id, userId: $userId, itemType: $itemType, itemId: $itemId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserFavoriteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum FavoriteItemType {
  package('package'),
  hotel('hotel'),
  place('place');

  const FavoriteItemType(this.value);
  final String value;

  static FavoriteItemType fromString(String value) {
    return FavoriteItemType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FavoriteItemType.package,
    );
  }
}