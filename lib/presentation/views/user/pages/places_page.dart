import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gotravel/data/models/place_model.dart';
import 'package:gotravel/data/models/user_favorite_model.dart';
import 'package:gotravel/presentation/providers/places_provider.dart';
import 'package:gotravel/presentation/providers/user_favorites_provider.dart';
import 'package:gotravel/presentation/widgets/cards/place_card.dart';
import 'package:gotravel/presentation/widgets/common/custom_search_bar.dart';
import 'package:provider/provider.dart';

class PlacesPage extends StatefulWidget {
  const PlacesPage({Key? key}) : super(key: key);

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
      final favoritesProvider = Provider.of<UserFavoritesProvider>(context, listen: false);
      
      placesProvider.initialize();
      favoritesProvider.initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            
            // Filter tabs
            _buildFilterTabs(theme),
            
            // Places grid
            Expanded(
              child: _buildPlacesContent(theme),
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
          // Title and back button
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  CupertinoIcons.back,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Discover Places',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Navigate to favorites
                },
                icon: Icon(
                  CupertinoIcons.heart,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Search bar
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Search places...',
            onChanged: (query) {
              final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
              if (query.isEmpty) {
                placesProvider.loadPlaces();
              } else {
                placesProvider.searchPlaces(query);
              }
            },
            onSubmitted: (query) {
              final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
              if (query.isEmpty) {
                placesProvider.loadPlaces();
              } else {
                placesProvider.searchPlaces(query);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: theme.colorScheme.primary,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Featured'),
          Tab(text: 'Popular'),
          Tab(text: 'Categories'),
        ],
        onTap: (index) {
          final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
          
          switch (index) {
            case 0:
              placesProvider.loadPlaces();
              break;
            case 1:
              placesProvider.loadFeaturedPlaces();
              break;
            case 2:
              placesProvider.loadPopularPlaces();
              break;
            case 3:
              _showCategoryFilter();
              break;
          }
        },
      ),
    );
  }

  Widget _buildPlacesContent(ThemeData theme) {
    return Consumer2<PlacesProvider, UserFavoritesProvider>(
      builder: (context, placesProvider, favoritesProvider, child) {
        if (placesProvider.isLoading) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        if (placesProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  placesProvider.error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    placesProvider.loadPlaces();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final places = _getPlacesToShow(placesProvider);

        if (places.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.location,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No places found',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              final isFavorite = favoritesProvider.isFavoritedFromCache(
                itemType: FavoriteItemType.place,
                itemId: place.id,
              );

              return PlaceCard(
                place: place,
                isFavorite: isFavorite,
                width: double.infinity,
                height: double.infinity,
                onTap: () {
                  // TODO: Navigate to place details
                  placesProvider.loadPlaceDetails(place.id);
                },
                onFavoritePressed: () async {
                  final newStatus = await favoritesProvider.toggleFavorite(
                    itemType: FavoriteItemType.place,
                    itemId: place.id,
                  );
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          newStatus
                              ? 'Added to favorites'
                              : 'Removed from favorites',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  List<PlaceModel> _getPlacesToShow(PlacesProvider provider) {
    switch (_tabController.index) {
      case 1:
        return provider.featuredPlaces;
      case 2:
        return provider.popularPlaces;
      default:
        return provider.places;
    }
  }

  void _showCategoryFilter() {
    final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['All', ...placesProvider.categories].map((category) {
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    
                    if (category == 'All') {
                      placesProvider.loadPlaces();
                    } else {
                      placesProvider.loadPlacesByCategory(category);
                    }
                    
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}