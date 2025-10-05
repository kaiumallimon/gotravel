class PackageActivity {
  final String id;
  final String packageId;
  final int dayNumber;
  final String activityName;
  final String description;
  final String location;
  final String? startTime;
  final String? endTime;
  final String activityType;
  final bool isOptional;
  final double additionalCost;

  PackageActivity({
    required this.id,
    required this.packageId,
    required this.dayNumber,
    required this.activityName,
    required this.description,
    required this.location,
    this.startTime,
    this.endTime,
    required this.activityType,
    this.isOptional = false,
    this.additionalCost = 0.0,
  });

  factory PackageActivity.fromMap(Map<String, dynamic> map) {
    return PackageActivity(
      id: map['id'] ?? '',
      packageId: map['package_id'] ?? '',
      dayNumber: map['day_number'] ?? 1,
      activityName: map['activity_name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      startTime: map['start_time'],
      endTime: map['end_time'],
      activityType: map['activity_type'] ?? '',
      isOptional: map['is_optional'] ?? false,
      additionalCost: (map['additional_cost'] is num) 
          ? map['additional_cost'].toDouble() 
          : 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'package_id': packageId,
      'day_number': dayNumber,
      'activity_name': activityName,
      'description': description,
      'location': location,
      'start_time': startTime,
      'end_time': endTime,
      'activity_type': activityType,
      'is_optional': isOptional,
      'additional_cost': additionalCost,
    };
  }
}