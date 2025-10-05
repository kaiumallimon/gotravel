# Tour Packages Feature

This feature adds comprehensive tour package management to the GoTravel app, similar to the hotels feature but tailored for tour packages.

## Features Added

### 1. Database Schema (`/supabase/packages_schema.sql`)
- **packages**: Main packages table with comprehensive package information
- **package_dates**: Specific departure and return dates for each package
- **package_activities**: Daily activities/itinerary for each package
- Full RLS (Row Level Security) policies for admin access
- Proper indexing for performance

### 2. Data Models
- **TourPackage** (`/lib/data/models/tour_package_model.dart`): Main package model
- **PackageActivity** (`/lib/data/models/package_activity_model.dart`): Individual activities
- **PackageDate** (`/lib/data/models/package_date_model.dart`): Package departure dates

### 3. Services
- **AdminPackageService** (`/lib/data/services/remote/admin_package_service.dart`): CRUD operations for packages
- **AddPackageService** (`/lib/data/services/remote/add_package_service.dart`): Package creation with image upload

### 4. Providers (State Management)
- **AdminPackagesProvider** (`/lib/presentation/providers/admin_packages_provider.dart`): Manages package list and operations
- **AddPackageProvider** (`/lib/presentation/providers/add_package_provider.dart`): Handles package creation form

### 5. UI Components

#### Admin Packages Page (`/lib/presentation/views/admin/packages/pages/packages_page.dart`)
- Grid/list view of all packages
- Search functionality
- Responsive design
- Status indicators (active/inactive)
- Difficulty level badges
- Category badges
- Quick stats (duration, price, slots)

#### Add Package Page (`/lib/presentation/views/admin/packages/pages/add_package_page.dart`)
- Comprehensive form for package creation
- JSON import functionality
- Image upload (cover + gallery)
- Dynamic activities management
- Dynamic package dates management
- Form validation

#### Detailed Package Page (`/lib/presentation/views/admin/packages/pages/detailed_package_page.dart`)
- Three-tab layout:
  1. **Overview**: Package info, services, gallery
  2. **Itinerary**: Day-by-day activities
  3. **Dates**: Available departure dates
- Image viewer with zoom
- Responsive design

### 6. Database Structure

#### Packages Table
```sql
- id (UUID, Primary Key)
- name (VARCHAR)
- description (TEXT)
- destination (VARCHAR)
- country (VARCHAR)
- category (VARCHAR) -- adventure, cultural, relaxation, etc.
- duration_days (INTEGER)
- price (DECIMAL)
- currency (VARCHAR)
- max_participants (INTEGER)
- available_slots (INTEGER)
- difficulty_level (VARCHAR) -- easy, moderate, hard
- minimum_age (INTEGER)
- included_services (TEXT[])
- excluded_services (TEXT[])
- contact_email (VARCHAR)
- contact_phone (VARCHAR)
- rating (DECIMAL)
- reviews_count (INTEGER)
- cover_image (TEXT)
- images (TEXT[])
- is_active (BOOLEAN)
```

#### Package Activities Table
```sql
- id (UUID, Primary Key)
- package_id (UUID, Foreign Key)
- day_number (INTEGER)
- activity_name (VARCHAR)
- description (TEXT)
- location (VARCHAR)
- start_time (TIME)
- end_time (TIME)
- activity_type (VARCHAR)
- is_optional (BOOLEAN)
- additional_cost (DECIMAL)
```

#### Package Dates Table
```sql
- id (UUID, Primary Key)  
- package_id (UUID, Foreign Key)
- departure_date (DATE)
- return_date (DATE)
- available_slots (INTEGER)
- price_override (DECIMAL)
- is_active (BOOLEAN)
```

## Usage

### 1. Database Setup
Run the SQL schema in your Supabase instance:
```sql
-- Execute supabase/packages_schema.sql
```

### 2. Adding Packages
1. Navigate to Admin Panel → Packages
2. Click "Add Package" button
3. Fill in package details or import from JSON
4. Add activities for each day
5. Add available departure dates
6. Upload cover image and gallery images
7. Save package

### 3. JSON Import
Use the sample JSON structure in `/supabase/sample_package.json` for easy data import.

### 4. Managing Packages
- View all packages in responsive grid
- Search by name, destination, country, category
- Toggle active/inactive status
- Edit package details
- View detailed package information

## Features Consistency with Hotels

✅ **UI Consistency**: Same design patterns, colors, and layout structure
✅ **Responsive Design**: Adaptive grid layout for different screen sizes  
✅ **Search Functionality**: Real-time search across multiple fields
✅ **Image Management**: Cover image + gallery with upload/removal
✅ **Form Validation**: Comprehensive input validation
✅ **Error Handling**: User-friendly error messages
✅ **Loading States**: Proper loading indicators
✅ **JSON Import**: Easy bulk data import capability
✅ **Provider Pattern**: Same state management approach
✅ **Service Layer**: Consistent API service structure
✅ **Routing**: Integrated with existing router configuration

## Additional Features (Beyond Hotels)

🎯 **Activities Management**: Daily itinerary with time slots
📅 **Departure Dates**: Multiple departure dates with availability
🎚️ **Difficulty Levels**: Easy, Moderate, Hard classifications
👥 **Age Restrictions**: Minimum age requirements
💰 **Price Overrides**: Different pricing for specific dates
📋 **Service Lists**: Included/excluded services management
📊 **Availability Tracking**: Real-time slot availability

## File Structure
```
lib/
├── data/
│   ├── models/
│   │   ├── tour_package_model.dart
│   │   ├── package_activity_model.dart
│   │   └── package_date_model.dart
│   └── services/remote/
│       ├── admin_package_service.dart
│       └── add_package_service.dart
├── presentation/
│   ├── providers/
│   │   ├── admin_packages_provider.dart
│   │   └── add_package_provider.dart
│   └── views/admin/packages/pages/
│       ├── packages_page.dart
│       ├── add_package_page.dart
│       └── detailed_package_page.dart
└── core/routes/
    ├── app_routes.dart (updated)
    └── app_router.dart (updated)

supabase/
├── packages_schema.sql
└── sample_package.json
```