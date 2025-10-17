import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/data/models/place_model.dart';
import 'package:gotravel/data/models/user_favorite_model.dart';
import 'package:gotravel/presentation/providers/places_provider.dart';
import 'package:gotravel/presentation/providers/user_favorites_provider.dart';
import 'package:gotravel/presentation/widgets/common/custom_search_bar.dart';
import 'package:provider/provider.dart';

class PlacesPage extends StatefulWidget {
  const PlacesPage({Key? key}) : super(key: key);

  @override
  State<PlacesPage> createState() => _PlacesPageState();
}

class _PlacesPageState extends State<PlacesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilterTab = 'All';
  final List<String> _filterTabs = ['All', 'Featured', 'Popular'];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final placesProvider = Provider.of<PlacesProvider>(
        context,
        listen: false,
      );
      final favoritesProvider = Provider.of<UserFavoritesProvider>(
        context,
        listen: false,
      );

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
            _buildHeader(theme),
            _buildFilterTabs(theme),
            Expanded(child: _buildPlacesContent(theme)),
          ],
        ),
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  'Places',
                  style: theme.textTheme.headlineSmall?.copyWith(
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
          FadeTransition(
            opacity: _fadeAnimation,
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search places...',
              onChanged: _performDynamicSearch,
              onSubmitted: _performDynamicSearch,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Filter Tabs ----------------
  Widget _buildFilterTabs(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterTabs.map((tab) {
                final isSelected = _selectedFilterTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
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
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilterTab = tab;
                        });
                        _handleFilterTabSelection(tab);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Places Content ----------------
  Widget _buildPlacesContent(ThemeData theme) {
    return Consumer2<PlacesProvider, UserFavoritesProvider>(
      builder: (context, placesProvider, favoritesProvider, child) {
        if (placesProvider.isLoading) {
          return const Center(child: CupertinoActivityIndicator());
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
                Text('Something went wrong', style: theme.textTheme.titleLarge),
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
                  onPressed: placesProvider.loadPlaces,
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
                Text('No places found', style: theme.textTheme.titleLarge),
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
          child: ListView.builder(
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              final isFavorite = favoritesProvider.isFavoritedFromCache(
                itemType: FavoriteItemType.place,
                itemId: place.id,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPlaceCard(
                  theme,
                  place,
                  isFavorite,
                  favoritesProvider,
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ---------------- Helper Methods ----------------
  List<PlaceModel> _getPlacesToShow(PlacesProvider provider) {
    switch (_selectedFilterTab) {
      case 'Featured':
        return provider.featuredPlaces;
      case 'Popular':
        return provider.popularPlaces;
      default:
        return provider.places;
    }
  }

  void _handleFilterTabSelection(String tab) {
    final provider = Provider.of<PlacesProvider>(context, listen: false);
    switch (tab) {
      case 'Featured':
        provider.loadFeaturedPlaces();
        break;
      case 'Popular':
        provider.loadPopularPlaces();
        break;
      default:
        provider.loadPlaces();
    }
  }

  void _performDynamicSearch(String query) {
    final provider = Provider.of<PlacesProvider>(context, listen: false);
    if (query.isEmpty) {
      _handleFilterTabSelection(_selectedFilterTab);
    } else {
      provider.searchPlaces(query);
    }
  }

  // ---------------- Place Card ----------------
  Widget _buildPlaceCard(
    ThemeData theme,
    PlaceModel place,
    bool isFavorite,
    UserFavoritesProvider favoritesProvider,
  ) {
    return GestureDetector(
      onTap: () => context.push('/place-details/${place.id}'),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surfaceVariant,
        ),
        child: Stack(
          children: [
            // Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: place.coverImage != null && place.coverImage!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(place.coverImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (place.coverImage == null || place.coverImage!.isEmpty)
                  ? Center(
                      child: Icon(
                        CupertinoIcons.photo,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),

            // Favorite icon
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () async {
                  await favoritesProvider.toggleFavorite(
                    itemType: FavoriteItemType.place,
                    itemId: place.id,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    color: isFavorite ? Colors.red : Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Text info
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name ?? 'Unknown Place',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.location_solid,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${place.city ?? 'Unknown'}, ${place.country ?? ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
