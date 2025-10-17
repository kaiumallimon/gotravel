import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gotravel/presentation/providers/user_home_provider.dart';
import 'package:gotravel/presentation/providers/places_provider.dart';
import 'package:gotravel/presentation/providers/location_provider.dart';
import 'package:gotravel/presentation/providers/user_favorites_provider.dart';
import 'package:gotravel/data/models/place_model.dart';
import 'package:gotravel/data/models/user_favorite_model.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class UserHomePageFigma extends StatefulWidget {
  const UserHomePageFigma({super.key});

  @override
  State<UserHomePageFigma> createState() => _UserHomePageFigmaState();
}

class _UserHomePageFigmaState extends State<UserHomePageFigma> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserHomeProvider>(context, listen: false).loadHomeData(context);
      Provider.of<PlacesProvider>(context, listen: false).loadPlaces();
      // Get user's current location
      Provider.of<LocationProvider>(context, listen: false).getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Location Header
              SliverAppBar(
                backgroundColor: theme.colorScheme.surface,
                elevation: 0,
                floating: false,
                pinned: false,
                automaticallyImplyLeading: false,
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Consumer<LocationProvider>(
                      builder: (context, locationProvider, child) {
                        return Row(
                          children: [
                            // Location
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.location_solid,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: locationProvider.isLoading
                                        ? Row(
                                            children: [
                                              SizedBox(
                                                width: 12,
                                                height: 12,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    theme.colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Getting location...',
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              // Refresh location
                                              locationProvider.getCurrentLocation();
                                            },
                                            child: Text(
                                              locationProvider.currentAddress,
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Profile Avatar
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'JD',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // Category Tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Packages'),
                      Tab(text: 'Places'),
                      Tab(text: 'Hotels'),
                    ],
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    indicatorColor: theme.colorScheme.primary,
                    indicatorWeight: 3,
                    dividerColor: theme.primaryColor.withAlpha(20),
                    labelStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPackagesTab(),
              _buildPlacesTab(),
              _buildHotelsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackagesTab() {
    return Consumer<UserHomeProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Latest Packages (latest 5)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${provider.totalPackages} Packages',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/packages');
                    },
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (provider.latestPackages.isEmpty)
                Center(
                  child: Text(
                    'No packages available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.latestPackages.length,
                    itemBuilder: (context, index) {
                      final package = provider.latestPackages[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < provider.latestPackages.length - 1 ? 16 : 0,
                        ),
                        child: _buildPackageCard(package),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              // Featured (Recommended) Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/packages');
                    },
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (provider.recommendedPackages.isEmpty)
                Center(
                  child: Text(
                    'No recommended packages available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.recommendedPackages.length,
                    itemBuilder: (context, index) {
                      final package = provider.recommendedPackages[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < provider.recommendedPackages.length - 1 ? 16 : 0,
                        ),
                        child: _buildPackageCard(package),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              // Top Packages Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Packages',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/packages');
                    },
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (provider.topPackages.isEmpty)
                Center(
                  child: Text(
                    'No top packages available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.topPackages.length,
                    itemBuilder: (context, index) {
                      final package = provider.topPackages[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < provider.topPackages.length - 1 ? 12 : 0,
                        ),
                        child: _buildPackageCard(package),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlacesTab() {
    return Consumer<PlacesProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Category Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCategoryIcon('All', CupertinoIcons.circle_grid_3x3, Colors.red, true),
                  _buildCategoryIcon('Beach', CupertinoIcons.sun_max, Colors.orange, false),
                  _buildCategoryIcon('Forest', CupertinoIcons.tree, Colors.green, false),
                  _buildCategoryIcon('Mountain', CupertinoIcons.triangle, Colors.blue, false),
                  _buildCategoryIcon('Suburban', CupertinoIcons.building_2_fill, Colors.purple, false),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Popular Places Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Places',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/places');
                    },
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              if (provider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (provider.places.isEmpty)
                Center(
                  child: Text(
                    'No places available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    // Large featured place card
                    if (provider.places.isNotEmpty)
                      _buildLargePlaceCard(provider.places.first),
                    
                    const SizedBox(height: 16),
                    
                    // Recommended for you section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Recommended for you',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Grid of recommended places
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: provider.places.length > 4 ? 4 : provider.places.length,
                      itemBuilder: (context, index) {
                        final place = provider.places[index];
                        return _buildSmallPlaceCard(place);
                      },
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHotelsTab() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.building_2_fill,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Hotels Coming Soon',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hotel booking feature will be available soon',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String label, IconData icon, Color color, bool isSelected) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? color : color.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLargePlaceCard(PlaceModel place) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        context.push('/place-details/${place.id}');
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: place.coverImage.isNotEmpty
                        ? NetworkImage(place.coverImage)
                        : const AssetImage('assets/images/placeholder.png') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Gradient overlay
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              
              // Content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Text(
                  place.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Favorite icon
              Positioned(
                top: 16,
                right: 16,
                child: Consumer<UserFavoritesProvider>(
                  builder: (context, favProvider, child) {
                    final isFavorite = favProvider.favorites.any(
                      (fav) => fav.itemId == place.id && 
                               fav.itemType == FavoriteItemType.place,
                    );

                    return GestureDetector(
                      onTap: () async {
                        if (isFavorite) {
                          await favProvider.removeFromFavorites(
                            itemType: FavoriteItemType.place,
                            itemId: place.id,
                          );
                        } else {
                          await favProvider.addToFavorites(
                            itemType: FavoriteItemType.place,
                            itemId: place.id,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isFavorite
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallPlaceCard(PlaceModel place) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        context.push('/place-details/${place.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background Image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: place.coverImage.isNotEmpty
                        ? NetworkImage(place.coverImage)
                        : const AssetImage('assets/images/placeholder.png') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              
              // Content - Place Name and Favorite Button
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Consumer<UserFavoritesProvider>(
                      builder: (context, favoritesProvider, _) {
                        final isFavorite = favoritesProvider.favorites
                            .any((fav) => fav.itemId == place.id && fav.itemType == FavoriteItemType.place);
                        
                        return GestureDetector(
                          onTap: () {
                            if (isFavorite) {
                              favoritesProvider.removeFromFavorites(
                                itemId: place.id,
                                itemType: FavoriteItemType.place,
                              );
                            } else {
                              favoritesProvider.addToFavorites(
                                itemId: place.id,
                                itemType: FavoriteItemType.place,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                              color: isFavorite ? Colors.red : Colors.white,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(dynamic package) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        context.push('/package-details/${package.id}');
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Package Image
              Container(
                height: 280,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: package.coverImage.isNotEmpty
                        ? NetworkImage(package.coverImage)
                        : const AssetImage('assets/images/placeholder.png') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Gradient overlay
              Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              
              // Content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Package title
                    Text(
                      package.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Location
                    Text(
                      '${package.destination}, ${package.country}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Price
                    
                  ],
                ),
              ),
              
              // (rating badge removed per design)
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}