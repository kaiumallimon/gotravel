import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/presentation/providers/user_hotels_provider.dart';
import 'package:provider/provider.dart';

class UserHotelsPage extends StatefulWidget {
  const UserHotelsPage({Key? key}) : super(key: key);

  @override
  State<UserHotelsPage> createState() => _UserHotelsPageState();
}

class _UserHotelsPageState extends State<UserHotelsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _selectedCountry = 'All';
  String _selectedFilterTab = 'All';

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotelsProvider = Provider.of<UserHotelsProvider>(context, listen: false);
      hotelsProvider.initialize();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
            _buildHeader(theme),
            
            
            // Hotels grid
            Expanded(
              child: _buildHotelsContent(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(CupertinoIcons.back, color: theme.colorScheme.onSurface),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hotels',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search hotels...',
              prefixIcon: Icon(CupertinoIcons.search, color: theme.colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          // Country filter
          Consumer<UserHotelsProvider>(
            builder: (context, provider, _) {
              final countries = ['All', ...provider.countries];
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: countries.map((country) {
                    final isSelected = _selectedCountry == country;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(country),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCountry = country;
                          });
                        },
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildHotelsContent(ThemeData theme) {
    return Consumer<UserHotelsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.exclamationmark_triangle, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Error: ${provider.error}',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        List<Hotel> filteredHotels = _getFilteredHotels(provider);

        if (filteredHotels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.building_2_fill, size: 64, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  'No hotels found',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: RefreshIndicator(
              onRefresh: () => provider.refresh(),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 240,
                ),
                itemCount: filteredHotels.length,
                itemBuilder: (context, index) {
                  final hotel = filteredHotels[index];
                  return _buildHotelCard(theme, hotel);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  List<Hotel> _getFilteredHotels(UserHotelsProvider provider) {
    List<Hotel> hotels;
    
    // Apply filter tab
    switch (_selectedFilterTab) {
      case 'Recommended':
        hotels = provider.recommendedHotels;
        break;
      case 'Highest Rated':
        hotels = provider.featuredHotels;
        break;
      default:
        hotels = provider.hotels;
    }

    // Apply country filter
    if (_selectedCountry != 'All') {
      hotels = hotels.where((hotel) => hotel.country == _selectedCountry).toList();
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      hotels = hotels.where((hotel) {
        return hotel.name.toLowerCase().contains(query) ||
               hotel.city.toLowerCase().contains(query) ||
               hotel.country.toLowerCase().contains(query);
      }).toList();
    }

    return hotels;
  }

  Widget _buildHotelCard(ThemeData theme, Hotel hotel) {
    return GestureDetector(
      onTap: () => context.push('/hotel-details/${hotel.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  image: hotel.coverImage.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(hotel.coverImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: hotel.coverImage.isEmpty
                    ? Center(
                        child: Icon(
                          CupertinoIcons.building_2_fill,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.location_solid,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${hotel.city}, ${hotel.country}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.star_fill,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hotel.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${hotel.reviewsCount})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
    );
  }
}
