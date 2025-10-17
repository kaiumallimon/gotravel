/// Database schema metadata - represents complete database structure
class DatabaseSchema {
  static final Map<String, TableSchema> tables = {
    'packages': TableSchema(
      name: 'packages',
      description: 'Tour packages with destinations, pricing, and availability',
      columns: {
        'id': ColumnSchema('id', 'uuid', 'Primary key'),
        'name': ColumnSchema('name', 'string', 'Package name'),
        'description': ColumnSchema('description', 'text', 'Detailed description'),
        'destination': ColumnSchema('destination', 'string', 'Destination city/location', searchable: true),
        'country': ColumnSchema('country', 'string', 'Country name', searchable: true),
        'category': ColumnSchema('category', 'string', 'Package category (Beach, Mountain, Cultural, Adventure)', searchable: true),
        'duration_days': ColumnSchema('duration_days', 'integer', 'Trip duration in days', filterable: true),
        'price': ColumnSchema('price', 'decimal', 'Package price', filterable: true, sortable: true),
        'currency': ColumnSchema('currency', 'string', 'Currency code (USD, BDT, etc)'),
        'max_participants': ColumnSchema('max_participants', 'integer', 'Maximum group size'),
        'available_slots': ColumnSchema('available_slots', 'integer', 'Available booking slots', filterable: true),
        'difficulty_level': ColumnSchema('difficulty_level', 'string', 'Easy, Moderate, Hard'),
        'minimum_age': ColumnSchema('minimum_age', 'integer', 'Minimum age requirement'),
        'included_services': ColumnSchema('included_services', 'array', 'List of included services'),
        'excluded_services': ColumnSchema('excluded_services', 'array', 'List of excluded services'),
        'itinerary': ColumnSchema('itinerary', 'jsonb', 'Day-by-day itinerary'),
        'contact_email': ColumnSchema('contact_email', 'string', 'Contact email'),
        'contact_phone': ColumnSchema('contact_phone', 'string', 'Contact phone'),
        'rating': ColumnSchema('rating', 'decimal', 'Average rating (0-5)', sortable: true, filterable: true),
        'reviews_count': ColumnSchema('reviews_count', 'integer', 'Number of reviews'),
        'cover_image': ColumnSchema('cover_image', 'string', 'Main image URL'),
        'images': ColumnSchema('images', 'array', 'Additional images'),
        'is_active': ColumnSchema('is_active', 'boolean', 'Package availability status', filterable: true),
        'created_at': ColumnSchema('created_at', 'timestamp', 'Creation timestamp'),
        'updated_at': ColumnSchema('updated_at', 'timestamp', 'Last update timestamp'),
      },
      searchableColumns: ['name', 'description', 'destination', 'country', 'category'],
      defaultOrderBy: 'price',
      userSpecific: false,
    ),

    'places': TableSchema(
      name: 'places',
      description: 'Tourist attractions and places to visit',
      columns: {
        'id': ColumnSchema('id', 'uuid', 'Primary key'),
        'name': ColumnSchema('name', 'string', 'Place name', searchable: true),
        'description': ColumnSchema('description', 'text', 'Place description', searchable: true),
        'city': ColumnSchema('city', 'string', 'City name', searchable: true, filterable: true),
        'country': ColumnSchema('country', 'string', 'Country name', searchable: true, filterable: true),
        'category': ColumnSchema('category', 'string', 'Category (Historical, Beach, Park, Museum)', searchable: true, filterable: true),
        'latitude': ColumnSchema('latitude', 'decimal', 'GPS latitude'),
        'longitude': ColumnSchema('longitude', 'decimal', 'GPS longitude'),
        'address': ColumnSchema('address', 'string', 'Full address'),
        'opening_hours': ColumnSchema('opening_hours', 'string', 'Opening hours'),
        'entry_fee': ColumnSchema('entry_fee', 'decimal', 'Entry fee amount', filterable: true),
        'rating': ColumnSchema('rating', 'decimal', 'Average rating', sortable: true),
        'reviews_count': ColumnSchema('reviews_count', 'integer', 'Number of reviews'),
        'cover_image': ColumnSchema('cover_image', 'string', 'Main image URL'),
        'images': ColumnSchema('images', 'array', 'Additional images'),
        'is_active': ColumnSchema('is_active', 'boolean', 'Visibility status', filterable: true),
        'created_at': ColumnSchema('created_at', 'timestamp', 'Creation timestamp'),
      },
      searchableColumns: ['name', 'description', 'city', 'country', 'category'],
      defaultOrderBy: 'created_at',
      userSpecific: false,
    ),

    'hotels': TableSchema(
      name: 'hotels',
      description: 'Hotels and accommodations',
      columns: {
        'id': ColumnSchema('id', 'uuid', 'Primary key'),
        'name': ColumnSchema('name', 'string', 'Hotel name', searchable: true),
        'description': ColumnSchema('description', 'text', 'Hotel description', searchable: true),
        'city': ColumnSchema('city', 'string', 'City name', searchable: true, filterable: true),
        'country': ColumnSchema('country', 'string', 'Country name', searchable: true, filterable: true),
        'address': ColumnSchema('address', 'string', 'Full address'),
        'star_rating': ColumnSchema('star_rating', 'integer', 'Star rating (1-5)', filterable: true),
        'latitude': ColumnSchema('latitude', 'decimal', 'GPS latitude'),
        'longitude': ColumnSchema('longitude', 'decimal', 'GPS longitude'),
        'amenities': ColumnSchema('amenities', 'array', 'List of amenities'),
        'contact_email': ColumnSchema('contact_email', 'string', 'Contact email'),
        'contact_phone': ColumnSchema('contact_phone', 'string', 'Contact phone'),
        'rating': ColumnSchema('rating', 'decimal', 'Average rating', sortable: true, filterable: true),
        'reviews_count': ColumnSchema('reviews_count', 'integer', 'Number of reviews'),
        'cover_image': ColumnSchema('cover_image', 'string', 'Main image URL'),
        'images': ColumnSchema('images', 'array', 'Additional images'),
        'is_active': ColumnSchema('is_active', 'boolean', 'Availability status', filterable: true),
        'created_at': ColumnSchema('created_at', 'timestamp', 'Creation timestamp'),
      },
      searchableColumns: ['name', 'description', 'city', 'country'],
      defaultOrderBy: 'rating',
      userSpecific: false,
    ),

    'rooms': TableSchema(
      name: 'rooms',
      description: 'Hotel rooms with pricing and availability',
      columns: {
        'id': ColumnSchema('id', 'uuid', 'Primary key'),
        'hotel_id': ColumnSchema('hotel_id', 'uuid', 'Related hotel ID', filterable: true),
        'room_type': ColumnSchema('room_type', 'string', 'Room type (Single, Double, Suite)', filterable: true),
        'description': ColumnSchema('description', 'text', 'Room description'),
        'price_per_night': ColumnSchema('price_per_night', 'decimal', 'Price per night', filterable: true, sortable: true),
        'currency': ColumnSchema('currency', 'string', 'Currency code'),
        'capacity': ColumnSchema('capacity', 'integer', 'Number of guests', filterable: true),
        'bed_type': ColumnSchema('bed_type', 'string', 'Bed configuration'),
        'total_rooms': ColumnSchema('total_rooms', 'integer', 'Total rooms available'),
        'available_rooms': ColumnSchema('available_rooms', 'integer', 'Currently available', filterable: true),
        'amenities': ColumnSchema('amenities', 'array', 'Room amenities'),
        'images': ColumnSchema('images', 'array', 'Room images'),
        'is_active': ColumnSchema('is_active', 'boolean', 'Availability status', filterable: true),
      },
      searchableColumns: ['room_type', 'description'],
      defaultOrderBy: 'price_per_night',
      userSpecific: false,
    ),

    'bookings': TableSchema(
      name: 'bookings',
      description: 'User bookings for packages',
      columns: {
        'id': ColumnSchema('id', 'uuid', 'Primary key'),
        'user_id': ColumnSchema('user_id', 'uuid', 'User who made booking', filterable: true),
        'package_id': ColumnSchema('package_id', 'uuid', 'Booked package', filterable: true),
        'travel_date': ColumnSchema('travel_date', 'date', 'Travel start date', filterable: true, sortable: true),
        'participants': ColumnSchema('participants', 'integer', 'Number of participants'),
        'total_amount': ColumnSchema('total_amount', 'decimal', 'Total cost', sortable: true),
        'currency': ColumnSchema('currency', 'string', 'Currency code'),
        'status': ColumnSchema('status', 'string', 'Booking status (pending, confirmed, cancelled)', filterable: true),
        'payment_status': ColumnSchema('payment_status', 'string', 'Payment status (pending, paid, refunded)', filterable: true),
        'special_requests': ColumnSchema('special_requests', 'text', 'Special requests'),
        'created_at': ColumnSchema('created_at', 'timestamp', 'Booking timestamp', sortable: true),
        'updated_at': ColumnSchema('updated_at', 'timestamp', 'Last update'),
      },
      searchableColumns: [],
      defaultOrderBy: 'created_at',
      userSpecific: true,
      userColumn: 'user_id',
    ),

    'payments': TableSchema(
      name: 'payments',
      description: 'Payment transactions',
      columns: {
        'id': ColumnSchema('id', 'uuid', 'Primary key'),
        'user_id': ColumnSchema('user_id', 'uuid', 'User who paid', filterable: true),
        'booking_id': ColumnSchema('booking_id', 'uuid', 'Related booking', filterable: true),
        'amount': ColumnSchema('amount', 'decimal', 'Payment amount', sortable: true),
        'currency': ColumnSchema('currency', 'string', 'Currency code'),
        'payment_method': ColumnSchema('payment_method', 'string', 'Payment method', filterable: true),
        'transaction_id': ColumnSchema('transaction_id', 'string', 'Transaction reference'),
        'status': ColumnSchema('status', 'string', 'Payment status (pending, completed, failed)', filterable: true),
        'payment_date': ColumnSchema('payment_date', 'timestamp', 'Payment timestamp', sortable: true),
        'created_at': ColumnSchema('created_at', 'timestamp', 'Record creation'),
      },
      searchableColumns: ['transaction_id'],
      defaultOrderBy: 'payment_date',
      userSpecific: true,
      userColumn: 'user_id',
    ),

    'reviews': TableSchema(
      name: 'reviews',
      description: 'User reviews for packages, places, and hotels',
      columns: {
        'id': ColumnSchema('id', 'uuid', 'Primary key'),
        'user_id': ColumnSchema('user_id', 'uuid', 'Reviewer', filterable: true),
        'item_type': ColumnSchema('item_type', 'string', 'Type (package, place, hotel)', filterable: true),
        'item_id': ColumnSchema('item_id', 'uuid', 'Reviewed item ID', filterable: true),
        'rating': ColumnSchema('rating', 'integer', 'Rating (1-5)', filterable: true, sortable: true),
        'comment': ColumnSchema('comment', 'text', 'Review text', searchable: true),
        'created_at': ColumnSchema('created_at', 'timestamp', 'Review date', sortable: true),
      },
      searchableColumns: ['comment'],
      defaultOrderBy: 'created_at',
      userSpecific: true,
      userColumn: 'user_id',
    ),

    'user_favorites': TableSchema(
      name: 'user_favorites',
      description: 'User saved/favorited items',
      columns: {
        'id': ColumnSchema('id', 'uuid', 'Primary key'),
        'user_id': ColumnSchema('user_id', 'uuid', 'User who favorited', filterable: true),
        'item_type': ColumnSchema('item_type', 'string', 'Type (package, place, hotel)', filterable: true),
        'item_id': ColumnSchema('item_id', 'uuid', 'Favorited item ID', filterable: true),
        'created_at': ColumnSchema('created_at', 'timestamp', 'When favorited', sortable: true),
      },
      searchableColumns: [],
      defaultOrderBy: 'created_at',
      userSpecific: true,
      userColumn: 'user_id',
    ),

    'users': TableSchema(
      name: 'users',
      description: 'User profiles and account information',
      columns: {
        'id': ColumnSchema('id', 'uuid', 'Primary key (auth.uid())'),
        'email': ColumnSchema('email', 'string', 'User email', searchable: true),
        'full_name': ColumnSchema('full_name', 'string', 'Full name', searchable: true),
        'phone': ColumnSchema('phone', 'string', 'Phone number'),
        'avatar_url': ColumnSchema('avatar_url', 'string', 'Profile picture URL'),
        'role': ColumnSchema('role', 'string', 'User role (user, admin)', filterable: true),
        'date_of_birth': ColumnSchema('date_of_birth', 'date', 'Birth date'),
        'nationality': ColumnSchema('nationality', 'string', 'Nationality'),
        'address': ColumnSchema('address', 'string', 'Full address'),
        'preferences': ColumnSchema('preferences', 'jsonb', 'User preferences'),
        'created_at': ColumnSchema('created_at', 'timestamp', 'Account creation'),
        'updated_at': ColumnSchema('updated_at', 'timestamp', 'Last update'),
      },
      searchableColumns: ['full_name', 'email'],
      defaultOrderBy: 'created_at',
      userSpecific: true,
      userColumn: 'id',
    ),

    'search_history': TableSchema(
      name: 'search_history',
      description: 'User search history',
      columns: {
        'id': ColumnSchema('id', 'uuid', 'Primary key'),
        'user_id': ColumnSchema('user_id', 'uuid', 'User who searched', filterable: true),
        'search_query': ColumnSchema('search_query', 'string', 'Search text', searchable: true),
        'search_type': ColumnSchema('search_type', 'string', 'Search category', filterable: true),
        'created_at': ColumnSchema('created_at', 'timestamp', 'Search timestamp', sortable: true),
      },
      searchableColumns: ['search_query'],
      defaultOrderBy: 'created_at',
      userSpecific: true,
      userColumn: 'user_id',
    ),

    'recommendations': TableSchema(
      name: 'recommendations',
      description: 'Admin-curated recommendations',
      columns: {
        'id': ColumnSchema('id', 'uuid', 'Primary key'),
        'item_type': ColumnSchema('item_type', 'string', 'Type (package, place, hotel)', filterable: true),
        'item_id': ColumnSchema('item_id', 'uuid', 'Recommended item ID', filterable: true),
        'title': ColumnSchema('title', 'string', 'Recommendation title', searchable: true),
        'description': ColumnSchema('description', 'text', 'Description', searchable: true),
        'priority': ColumnSchema('priority', 'integer', 'Display priority', sortable: true),
        'is_active': ColumnSchema('is_active', 'boolean', 'Active status', filterable: true),
        'created_at': ColumnSchema('created_at', 'timestamp', 'Creation date'),
      },
      searchableColumns: ['title', 'description'],
      defaultOrderBy: 'priority',
      userSpecific: false,
    ),

    'conversations': TableSchema(
      name: 'conversations',
      description: 'AI chat conversations',
      columns: {
        'id': ColumnSchema('id', 'uuid', 'Primary key'),
        'user_id': ColumnSchema('user_id', 'uuid', 'Conversation owner', filterable: true),
        'title': ColumnSchema('title', 'string', 'Conversation title', searchable: true),
        'created_at': ColumnSchema('created_at', 'timestamp', 'Start time', sortable: true),
        'updated_at': ColumnSchema('updated_at', 'timestamp', 'Last message time', sortable: true),
      },
      searchableColumns: ['title'],
      defaultOrderBy: 'updated_at',
      userSpecific: true,
      userColumn: 'user_id',
    ),

    'messages': TableSchema(
      name: 'messages',
      description: 'AI chat messages',
      columns: {
        'id': ColumnSchema('id', 'uuid', 'Primary key'),
        'conversation_id': ColumnSchema('conversation_id', 'uuid', 'Parent conversation', filterable: true),
        'role': ColumnSchema('role', 'string', 'Message role (user, assistant)', filterable: true),
        'content': ColumnSchema('content', 'text', 'Message text', searchable: true),
        'created_at': ColumnSchema('created_at', 'timestamp', 'Message time', sortable: true),
      },
      searchableColumns: ['content'],
      defaultOrderBy: 'created_at',
      userSpecific: false,
    ),
  };

  /// Get schema for a specific table
  static TableSchema? getTableSchema(String tableName) {
    return tables[tableName];
  }

  /// Get all table names
  static List<String> getAllTableNames() {
    return tables.keys.toList();
  }

  /// Get user-specific tables (require auth)
  static List<String> getUserSpecificTables() {
    return tables.entries
        .where((e) => e.value.userSpecific)
        .map((e) => e.key)
        .toList();
  }

  /// Generate schema summary for AI
  static String getSchemaForAI() {
    final buffer = StringBuffer();
    buffer.writeln('DATABASE SCHEMA REFERENCE:\n');
    
    tables.forEach((tableName, schema) {
      buffer.writeln('TABLE: $tableName');
      buffer.writeln('Description: ${schema.description}');
      if (schema.userSpecific) {
        buffer.writeln('⚠️ USER-SPECIFIC: Requires authentication, auto-filters by user_id');
      }
      buffer.writeln('Searchable columns: ${schema.searchableColumns.join(", ")}');
      buffer.writeln('Default order: ${schema.defaultOrderBy}');
      buffer.writeln('Columns:');
      
      schema.columns.forEach((colName, col) {
        final flags = <String>[];
        if (col.searchable) flags.add('searchable');
        if (col.filterable) flags.add('filterable');
        if (col.sortable) flags.add('sortable');
        final flagStr = flags.isNotEmpty ? ' [${flags.join(", ")}]' : '';
        buffer.writeln('  - $colName (${col.type}): ${col.description}$flagStr');
      });
      buffer.writeln();
    });
    
    return buffer.toString();
  }
}

/// Represents a database table
class TableSchema {
  final String name;
  final String description;
  final Map<String, ColumnSchema> columns;
  final List<String> searchableColumns;
  final String defaultOrderBy;
  final bool userSpecific;
  final String? userColumn;

  TableSchema({
    required this.name,
    required this.description,
    required this.columns,
    required this.searchableColumns,
    required this.defaultOrderBy,
    this.userSpecific = false,
    this.userColumn,
  });
}

/// Represents a table column
class ColumnSchema {
  final String name;
  final String type;
  final String description;
  final bool searchable;
  final bool filterable;
  final bool sortable;

  ColumnSchema(
    this.name,
    this.type,
    this.description, {
    this.searchable = false,
    this.filterable = false,
    this.sortable = false,
  });
}
