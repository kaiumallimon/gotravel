class PackageDate {
  final String id;
  final String packageId;
  final DateTime departureDate;
  final DateTime returnDate;
  final int availableSlots;
  final double? priceOverride;
  final bool isActive;

  PackageDate({
    required this.id,
    required this.packageId,
    required this.departureDate,
    required this.returnDate,
    required this.availableSlots,
    this.priceOverride,
    this.isActive = true,
  });

  factory PackageDate.fromMap(Map<String, dynamic> map) {
    return PackageDate(
      id: map['id'] ?? '',
      packageId: map['package_id'] ?? '',
      departureDate: DateTime.tryParse(map['departure_date']?.toString() ?? '') ?? DateTime.now(),
      returnDate: DateTime.tryParse(map['return_date']?.toString() ?? '') ?? DateTime.now(),
      availableSlots: map['available_slots'] ?? 0,
      priceOverride: (map['price_override'] is num) 
          ? map['price_override'].toDouble() 
          : null,
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'package_id': packageId,
      'departure_date': departureDate.toIso8601String().split('T')[0],
      'return_date': returnDate.toIso8601String().split('T')[0],
      'available_slots': availableSlots,
      'price_override': priceOverride,
      'is_active': isActive,
    };
  }

  /// Get the final price (override if available, otherwise null)
  double? getFinalPrice(double basePrice) {
    return priceOverride ?? basePrice;
  }
}