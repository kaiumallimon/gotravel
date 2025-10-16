class ReviewModel {
  final String id;
  final String userId;
  final ReviewItemType itemType;
  final String itemId;
  final String? bookingId;
  
  // Review Details
  final int rating;
  final String? title;
  final String? reviewText;
  final List<String> images;
  
  // Review Metadata
  final bool isVerified;
  final bool isAnonymous;
  final int helpfulCount;
  final int reportedCount;
  
  // Status
  final bool isApproved;
  final bool isFeatured;
  final DateTime? moderatedAt;
  final String? moderatedBy;
  final String? moderationNotes;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    this.bookingId,
    required this.rating,
    this.title,
    this.reviewText,
    this.images = const [],
    this.isVerified = false,
    this.isAnonymous = false,
    this.helpfulCount = 0,
    this.reportedCount = 0,
    this.isApproved = true,
    this.isFeatured = false,
    this.moderatedAt,
    this.moderatedBy,
    this.moderationNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  ReviewModel copyWith({
    String? id,
    String? userId,
    ReviewItemType? itemType,
    String? itemId,
    String? bookingId,
    int? rating,
    String? title,
    String? reviewText,
    List<String>? images,
    bool? isVerified,
    bool? isAnonymous,
    int? helpfulCount,
    int? reportedCount,
    bool? isApproved,
    bool? isFeatured,
    DateTime? moderatedAt,
    String? moderatedBy,
    String? moderationNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      reviewText: reviewText ?? this.reviewText,
      images: images ?? this.images,
      isVerified: isVerified ?? this.isVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      reportedCount: reportedCount ?? this.reportedCount,
      isApproved: isApproved ?? this.isApproved,
      isFeatured: isFeatured ?? this.isFeatured,
      moderatedAt: moderatedAt ?? this.moderatedAt,
      moderatedBy: moderatedBy ?? this.moderatedBy,
      moderationNotes: moderationNotes ?? this.moderationNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'item_type': itemType.value,
      'item_id': itemId,
      'booking_id': bookingId,
      'rating': rating,
      'title': title,
      'review_text': reviewText,
      'images': images,
      'is_verified': isVerified,
      'is_anonymous': isAnonymous,
      'helpful_count': helpfulCount,
      'reported_count': reportedCount,
      'is_approved': isApproved,
      'is_featured': isFeatured,
      'moderated_at': moderatedAt?.toIso8601String(),
      'moderated_by': moderatedBy,
      'moderation_notes': moderationNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      itemType: ReviewItemType.fromString(map['item_type'] ?? 'package'),
      itemId: map['item_id'] ?? '',
      bookingId: map['booking_id'],
      rating: map['rating']?.toInt() ?? 1,
      title: map['title'],
      reviewText: map['review_text'],
      images: List<String>.from(map['images'] ?? []),
      isVerified: map['is_verified'] ?? false,
      isAnonymous: map['is_anonymous'] ?? false,
      helpfulCount: map['helpful_count']?.toInt() ?? 0,
      reportedCount: map['reported_count']?.toInt() ?? 0,
      isApproved: map['is_approved'] ?? true,
      isFeatured: map['is_featured'] ?? false,
      moderatedAt: map['moderated_at'] != null ? DateTime.parse(map['moderated_at']) : null,
      moderatedBy: map['moderated_by'],
      moderationNotes: map['moderation_notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, rating: $rating, itemType: $itemType, itemId: $itemId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum ReviewItemType {
  package('package'),
  hotel('hotel'),
  place('place');

  const ReviewItemType(this.value);
  final String value;

  static ReviewItemType fromString(String value) {
    return ReviewItemType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReviewItemType.package,
    );
  }
}