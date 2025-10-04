import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/core/routes/app_routes.dart';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/data/models/room_model.dart';
import 'package:gotravel/presentation/providers/admin_hotels_provider.dart';
import 'package:gotravel/presentation/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class AdminHotelsPage extends StatefulWidget {
  const AdminHotelsPage({super.key});

  @override
  State<AdminHotelsPage> createState() => _AdminHotelsPageState();
}

class _AdminHotelsPageState extends State<AdminHotelsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminHotelsProvider>(context, listen: false);
      provider.loadHotels(context);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Trigger rebuild when search text changes
    setState(() {});
  }

  List<Hotel> _getFilteredHotels(List<Hotel> allHotels) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return allHotels;
    } else {
      return allHotels
          .where(
            (hotel) =>
                hotel.name.toLowerCase().contains(query) ||
                hotel.city.toLowerCase().contains(query) ||
                hotel.country.toLowerCase().contains(query) ||
                hotel.address.toLowerCase().contains(query),
          )
          .toList();
    }
  }

  Widget _buildRatingStars(double rating) {
    final fullStars = rating.floor();
    final halfStar = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(Icons.star, color: Colors.amber, size: 14);
        } else if (index == fullStars && halfStar) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 14);
        } else {
          return Icon(Icons.star_border, color: Colors.grey[400], size: 14);
        }
      }),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        amenity,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  String _formatPrice(List<Room> rooms) {
    if (rooms.isEmpty) return 'No rooms available';

    final prices = rooms.map((room) => room.pricePerNight).toList()..sort();
    final minPrice = prices.first;
    final maxPrice = prices.last;
    final currency = rooms.first.currency;

    if (minPrice == maxPrice) {
      return '$currency${minPrice.toStringAsFixed(0)}/night';
    }
    return '$currency${minPrice.toStringAsFixed(0)} - $currency${maxPrice.toStringAsFixed(0)}/night';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final hotelsProvider = Provider.of<AdminHotelsProvider>(context);

    // Filter hotels based on search query
    final hotels = _getFilteredHotels(hotelsProvider.hotels);

    // Determine responsive layout
    int crossAxisCount;
    double aspectRatio;
    if (size.width > 1200) {
      crossAxisCount = 4;
      aspectRatio = 0.85;
    } else if (size.width > 800) {
      crossAxisCount = 3;
      aspectRatio = 0.9;
    } else if (size.width > 500) {
      crossAxisCount = 2;
      aspectRatio = 0.95;
    } else {
      crossAxisCount = 1;
      aspectRatio = 1.1;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Search Bar
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CustomTextField(
                  height: 56,
                  prefixIcon: CupertinoIcons.search,
                  labelText: "Search hotels by name, city, or country...",
                  controller: _searchController,
                ),
              ),

              const SizedBox(height: 24),

              // Hotels Grid
              Expanded(
                child: hotelsProvider.isLoading
                    ? _buildLoadingState()
                    : hotels.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildHotelsGrid(
                        hotels,
                        crossAxisCount,
                        aspectRatio,
                        theme,
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('${AppRoutes.adminWrapper}${AppRoutes.addHotel}');
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(CupertinoIcons.add),
        label: const Text('Add Hotel'),
        elevation: 8,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading hotels...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () => Provider.of<AdminHotelsProvider>(
        context,
        listen: false,
      ).loadHotels(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.hotel_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _searchController.text.isEmpty
                      ? "No hotels found"
                      : "No hotels match your search",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchController.text.isEmpty
                      ? "Click the + button to add a new hotel"
                      : "Try adjusting your search terms",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelsGrid(
    List<Hotel> hotels,
    int crossAxisCount,
    double aspectRatio,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: () => Provider.of<AdminHotelsProvider>(
        context,
        listen: false,
      ).loadHotels(context),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: aspectRatio,
        ),
        itemCount: hotels.length,
        itemBuilder: (context, index) => _buildHotelCard(hotels[index], theme),
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.push(
              '/admin/detailed-hotel',
              extra: hotel.toMap(),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image with overlay
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        hotel.coverImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: theme.colorScheme.surfaceVariant,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.hotel,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No Image',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Rating Badge
                    if (hotel.rating > 0)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hotel.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Rooms Count Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${hotel.rooms.length} rooms',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Hotel Details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hotel Name
                      Text(
                        hotel.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Location with icon
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${hotel.city}, ${hotel.country}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Rating and Reviews
                      Row(
                        children: [
                          _buildRatingStars(hotel.rating),
                          const SizedBox(width: 6),
                          Text(
                            hotel.reviewsCount > 0
                                ? '(${hotel.reviewsCount})'
                                : 'No reviews',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Price and Rooms
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _formatPrice(hotel.rooms),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Room amenities sample
                          if (hotel.rooms.isNotEmpty &&
                              hotel.rooms.first.amenities.isNotEmpty)
                            _buildAmenityChip(
                              hotel.rooms.first.amenities.first,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
