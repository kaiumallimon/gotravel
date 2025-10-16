class SearchHistoryModel {
  final String id;
  final String? userId;
  final String searchQuery;
  final String? searchType;
  final Map<String, dynamic>? searchFilters;
  final int resultsCount;
  final String? clickedItemId;
  final String? clickedItemType;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;

  SearchHistoryModel({
    required this.id,
    this.userId,
    required this.searchQuery,
    this.searchType,
    this.searchFilters,
    this.resultsCount = 0,
    this.clickedItemId,
    this.clickedItemType,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
  });

  SearchHistoryModel copyWith({
    String? id,
    String? userId,
    String? searchQuery,
    String? searchType,
    Map<String, dynamic>? searchFilters,
    int? resultsCount,
    String? clickedItemId,
    String? clickedItemType,
    String? ipAddress,
    String? userAgent,
    DateTime? createdAt,
  }) {
    return SearchHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      searchQuery: searchQuery ?? this.searchQuery,
      searchType: searchType ?? this.searchType,
      searchFilters: searchFilters ?? this.searchFilters,
      resultsCount: resultsCount ?? this.resultsCount,
      clickedItemId: clickedItemId ?? this.clickedItemId,
      clickedItemType: clickedItemType ?? this.clickedItemType,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'search_query': searchQuery,
      'search_type': searchType,
      'search_filters': searchFilters,
      'results_count': resultsCount,
      'clicked_item_id': clickedItemId,
      'clicked_item_type': clickedItemType,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SearchHistoryModel.fromMap(Map<String, dynamic> map) {
    return SearchHistoryModel(
      id: map['id'] ?? '',
      userId: map['user_id'],
      searchQuery: map['search_query'] ?? '',
      searchType: map['search_type'],
      searchFilters: map['search_filters'] != null
          ? Map<String, dynamic>.from(map['search_filters'])
          : null,
      resultsCount: map['results_count']?.toInt() ?? 0,
      clickedItemId: map['clicked_item_id'],
      clickedItemType: map['clicked_item_type'],
      ipAddress: map['ip_address'],
      userAgent: map['user_agent'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  @override
  String toString() {
    return 'SearchHistoryModel(id: $id, searchQuery: $searchQuery, searchType: $searchType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchHistoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class SearchFilter {
  final String? destination;
  final String? country;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final int? minDuration;
  final int? maxDuration;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? participants;
  final List<String>? amenities;
  final String? sortBy;
  final String? sortOrder;

  SearchFilter({
    this.destination,
    this.country,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.minDuration,
    this.maxDuration,
    this.startDate,
    this.endDate,
    this.participants,
    this.amenities,
    this.sortBy,
    this.sortOrder,
  });

  SearchFilter copyWith({
    String? destination,
    String? country,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    int? minDuration,
    int? maxDuration,
    DateTime? startDate,
    DateTime? endDate,
    int? participants,
    List<String>? amenities,
    String? sortBy,
    String? sortOrder,
  }) {
    return SearchFilter(
      destination: destination ?? this.destination,
      country: country ?? this.country,
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      minDuration: minDuration ?? this.minDuration,
      maxDuration: maxDuration ?? this.maxDuration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participants: participants ?? this.participants,
      amenities: amenities ?? this.amenities,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'destination': destination,
      'country': country,
      'category': category,
      'min_price': minPrice,
      'max_price': maxPrice,
      'min_rating': minRating,
      'min_duration': minDuration,
      'max_duration': maxDuration,
      'start_date': startDate?.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'participants': participants,
      'amenities': amenities,
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };
  }

  factory SearchFilter.fromMap(Map<String, dynamic> map) {
    return SearchFilter(
      destination: map['destination'],
      country: map['country'],
      category: map['category'],
      minPrice: map['min_price']?.toDouble(),
      maxPrice: map['max_price']?.toDouble(),
      minRating: map['min_rating']?.toDouble(),
      minDuration: map['min_duration']?.toInt(),
      maxDuration: map['max_duration']?.toInt(),
      startDate: map['start_date'] != null ? DateTime.parse(map['start_date']) : null,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      participants: map['participants']?.toInt(),
      amenities: map['amenities'] != null ? List<String>.from(map['amenities']) : null,
      sortBy: map['sort_by'],
      sortOrder: map['sort_order'],
    );
  }

  bool get isEmpty {
    return destination == null &&
        country == null &&
        category == null &&
        minPrice == null &&
        maxPrice == null &&
        minRating == null &&
        minDuration == null &&
        maxDuration == null &&
        startDate == null &&
        endDate == null &&
        participants == null &&
        (amenities == null || amenities!.isEmpty) &&
        sortBy == null &&
        sortOrder == null;
  }
}