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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedFilterTab = 'All';
  final List<String> _filterTabs = ['All', 'Featured', 'Popular'];

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
      final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
      final favoritesProvider = Provider.of<UserFavoritesProvider>(context, listen: false);
      
      placesProvider.initialize();
      favoritesProvider.initialize();
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
          
          // Dynamic Search bar
          FadeTransition(
            opacity: _fadeAnimation,
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search ${_selectedCategory.toLowerCase() == 'all' ? '' : '${_selectedCategory.toLowerCase()} '}places...',
              onChanged: (query) {
                _performDynamicSearch(query);
              },
              onSubmitted: (query) {
                _performDynamicSearch(query);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Tabs Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filterTabs.map((tab) {
                    final isSelected = _selectedFilterTab == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: FilterChip(
                          label: Text(
                            tab,
                            style: TextStyle(
                              color: isSelected 
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                              fontWeight: isSelected 
                                ? FontWeight.w600 
                                : FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: theme.colorScheme.primary,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          checkmarkColor: theme.colorScheme.onPrimary,
                          elevation: isSelected ? 4 : 0,
                          shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilterTab = tab;
                                _selectedCategory = 'All'; // Reset category when switching filter tabs
                              });
                              _handleFilterTabSelection(tab);
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Categories Row
              Consumer<PlacesProvider>(
                builder: (context, placesProvider, child) {
                  final allCategories = ['All', ...placesProvider.categories];
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: allCategories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: ActionChip(
                              label: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected 
                                    ? theme.colorScheme.onSecondaryContainer
                                    : theme.colorScheme.onSurface,
                                  fontSize: 13,
                                  fontWeight: isSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.w400,
                                ),
                              ),
                              backgroundColor: isSelected 
                                ? theme.colorScheme.secondaryContainer
                                : theme.colorScheme.surface,
                              side: BorderSide(
                                color: isSelected 
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.outline.withOpacity(0.5),
                                width: isSelected ? 2 : 1,
                              ),
                              elevation: isSelected ? 2 : 0,
                              shadowColor: theme.colorScheme.secondary.withOpacity(0.2),
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                                _handleCategorySelection(category);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFilterTabSelection(String tab) {
    final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
    
    switch (tab) {
      case 'All':
        placesProvider.loadPlaces();
        break;
      case 'Featured':
        placesProvider.loadFeaturedPlaces();
        break;
      case 'Popular':
        placesProvider.loadPopularPlaces();
        break;
    }
  }

  void _handleCategorySelection(String category) {
    final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
    
    if (category == 'All') {
      // Apply the current filter tab selection instead of just loading all places
      _handleFilterTabSelection(_selectedFilterTab);
    } else {
      placesProvider.loadPlacesByCategory(category);
    }
    
    // Clear search when changing category
    _searchController.clear();
  }

  void _performDynamicSearch(String query) {
    final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
    
    if (query.isEmpty) {
      // Restore current filter based on selections
      if (_selectedCategory == 'All') {
        _handleFilterTabSelection(_selectedFilterTab);
      } else {
        _handleCategorySelection(_selectedCategory);
      }
    } else {
      // Perform search - the filtering by category will be handled in the UI
      placesProvider.searchPlaces(query);
    }
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

              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutCubic,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        (index * 0.1).clamp(0.0, 1.0),
                        ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                        curve: Curves.easeOutCubic,
                      ),
                    )),
                    child: PlaceCard(
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
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<PlaceModel> _getPlacesToShow(PlacesProvider provider) {
    List<PlaceModel> basePlaces;
    
    // Get base places based on filter tab
    switch (_selectedFilterTab) {
      case 'Featured':
        basePlaces = provider.featuredPlaces;
        break;
      case 'Popular':
        basePlaces = provider.popularPlaces;
        break;
      default:
        basePlaces = provider.places;
        break;
    }
    
    // Apply category filter if not 'All' and not in search mode
    if (_selectedCategory != 'All' && _searchController.text.isEmpty) {
      return basePlaces.where((place) => 
        place.category?.toLowerCase() == _selectedCategory.toLowerCase()
      ).toList();
    }
    
    // Apply category filter to search results if searching within a category
    if (_selectedCategory != 'All' && _searchController.text.isNotEmpty) {
      return basePlaces.where((place) => 
        place.category?.toLowerCase() == _selectedCategory.toLowerCase()
      ).toList();
    }
    
    return basePlaces;
  }
}