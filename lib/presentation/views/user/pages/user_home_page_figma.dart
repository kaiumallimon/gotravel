import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/location_provider.dart';
import '../../../providers/places_provider.dart';
import '../../../providers/user_home_provider.dart';
import '../../../providers/user_hotels_provider.dart';
import '../../../providers/user_profile_provider.dart';

class UserHomePageFigma extends StatefulWidget {
  const UserHomePageFigma({super.key});

  @override
  State<UserHomePageFigma> createState() => _UserHomePageFigmaState();
}

class _UserHomePageFigmaState extends State<UserHomePageFigma> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserHomeProvider>().loadHomeData(context);
      context.read<PlacesProvider>().initialize();
      context.read<UserHotelsProvider>().initialize();
      context.read<LocationProvider>().getCurrentLocation();
    });
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'US';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'US';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            context.read<UserHomeProvider>().loadHomeData(context),
            context.read<PlacesProvider>().initialize(),
            context.read<UserHotelsProvider>().initialize(),
            context.read<LocationProvider>().getCurrentLocation(),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            _buildHeaderSection(theme),
            _buildFeaturedPackagesSection(theme),
            _buildPopularPlacesSection(theme),
            _buildAllPackagesSection(theme),
            _buildAllHotelsSection(theme),
            _buildRecentlyAddedPlacesSection(theme),
            _buildRecentlyAddedPackagesSection(theme),
            _buildRecentlyAddedHotelsSection(theme),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
        child: Consumer2<UserProfileProvider, LocationProvider>(
          builder: (context, profileProvider, locationProvider, child) {
            final userName = profileProvider.userAccount?.name ?? 'User';
            final initials = _getInitials(userName);
            
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => locationProvider.getCurrentLocation(),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.location_solid,
                              color: theme.colorScheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: locationProvider.isLoading
                                  ? Text(
                                      'Getting location...',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    )
                                  : Text(
                                      locationProvider.currentAddress,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: theme.textTheme.titleLarge?.copyWith(
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
    );
  }

  Widget _buildFeaturedPackagesSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Packages',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/packages'),
                  label: Text(
                    'See all',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: Icon(
                    CupertinoIcons.arrow_right,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  iconAlignment: IconAlignment.end,
                ),
              ],
            ),
          ),
          Consumer<UserHomeProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return Container(
                  height: 280,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(color: theme.colorScheme.primary),
                );
              }
              final featuredPackages = provider.featuredPackages;
              if (featuredPackages.isEmpty) {
                return Container(
                  height: 280,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.cube_box, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text('No packages available', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                );
              }
              return SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: featuredPackages.length,
                  itemBuilder: (context, index) {
                    final package = featuredPackages[index];
                    return Padding(
                      padding: EdgeInsets.only(right: index < featuredPackages.length - 1 ? 16 : 0),
                      child: _buildPackageCard(theme, package),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPopularPlacesSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Places',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/places'),
                  label: Text(
                    'See all',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: Icon(
                    CupertinoIcons.arrow_right,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  iconAlignment: IconAlignment.end,
                ),
              ],
            ),
          ),
          Consumer<PlacesProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(color: theme.colorScheme.primary),
                );
              }
              final places = provider.places;
              if (places.isEmpty) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.map, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text('No places available', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                );
              }
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return Padding(
                      padding: EdgeInsets.only(right: index < places.length - 1 ? 16 : 0),
                      child: _buildPlaceCard(theme, place),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllPackagesSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Consumer<UserHomeProvider>(
        builder: (context, provider, _) {
          final total = provider.totalPackagesCount;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$total Packages',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push('/packages'),
                      label: Text(
                        'See all',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: Icon(
                        CupertinoIcons.arrow_right,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      iconAlignment: IconAlignment.end,
                    ),
                  ],
                ),
              ),
              if (provider.isLoading)
                Container(
                  height: 280,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(color: theme.colorScheme.primary),
                )
              else if (provider.randomPackages.isEmpty)
                Container(
                  height: 280,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.cube_box, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text('No packages available', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: provider.randomPackages.length,
                    itemBuilder: (context, index) {
                      final package = provider.randomPackages[index];
                      return Padding(
                        padding: EdgeInsets.only(right: index < provider.randomPackages.length - 1 ? 16 : 0),
                        child: _buildPackageCard(theme, package),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllHotelsSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Consumer<UserHotelsProvider>(
        builder: (context, provider, _) {
          final total = provider.totalHotels;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$total Hotels',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push('/hotels'),
                      label: Text(
                        'See all',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: Icon(
                        CupertinoIcons.arrow_right,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      iconAlignment: IconAlignment.end,
                    ),
                  ],
                ),
              ),
              if (provider.isLoading)
                Container(
                  height: 240,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(color: theme.colorScheme.primary),
                )
              else if (provider.randomHotels.isEmpty)
                Container(
                  height: 240,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.building_2_fill, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text('No hotels available', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: provider.randomHotels.length,
                    itemBuilder: (context, index) {
                      final hotel = provider.randomHotels[index];
                      return Padding(
                        padding: EdgeInsets.only(right: index < provider.randomHotels.length - 1 ? 16 : 0),
                        child: _buildHotelCard(theme, hotel),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecentlyAddedPlacesSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recently Added Places',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/places'),
                  label: Text(
                    'See all',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: Icon(
                    CupertinoIcons.arrow_right,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  iconAlignment: IconAlignment.end,
                ),
              ],
            ),
          ),
          Consumer<PlacesProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(color: theme.colorScheme.primary),
                );
              }
              final places = provider.latestPlaces;
              if (places.isEmpty) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.map, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text('No places available', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                );
              }
              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return Padding(
                      padding: EdgeInsets.only(right: index < places.length - 1 ? 16 : 0),
                      child: _buildPlaceCard(theme, place),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyAddedPackagesSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recently Added Packages',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/packages'),
                  label: Text(
                    'See all',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: Icon(
                    CupertinoIcons.arrow_right,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  iconAlignment: IconAlignment.end,
                ),
              ],
            ),
          ),
          Consumer<UserHomeProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return Container(
                  height: 280,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(color: theme.colorScheme.primary),
                );
              }
              final packages = provider.recentlyAddedPackages;
              if (packages.isEmpty) {
                return Container(
                  height: 280,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.cube_box, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text('No packages available', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                );
              }
              return SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    return Padding(
                      padding: EdgeInsets.only(right: index < packages.length - 1 ? 16 : 0),
                      child: _buildPackageCard(theme, package),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyAddedHotelsSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recently Added Hotels',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/hotels'),
                  label: Text(
                    'See all',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  icon: Icon(
                    CupertinoIcons.arrow_right,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  iconAlignment: IconAlignment.end,
                ),
              ],
            ),
          ),
          Consumer<UserHotelsProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return Container(
                  height: 240,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(color: theme.colorScheme.primary),
                );
              }
              final hotels = provider.recentlyAddedHotels;
              if (hotels.isEmpty) {
                return Container(
                  height: 240,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.building_2_fill, size: 48, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text('No hotels available', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                );
              }
              return SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = hotels[index];
                    return Padding(
                      padding: EdgeInsets.only(right: index < hotels.length - 1 ? 16 : 0),
                      child: _buildHotelCard(theme, hotel),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(ThemeData theme, dynamic package) {
    return GestureDetector(
      onTap: () => context.push('/package-details/${package.id}'),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  image: package.coverImage != null && package.coverImage.isNotEmpty
                      ? DecorationImage(image: NetworkImage(package.coverImage), fit: BoxFit.cover)
                      : null,
                ),
                child: package.coverImage == null || package.coverImage.isEmpty
                    ? Center(child: Icon(CupertinoIcons.photo, size: 60, color: theme.colorScheme.onSurfaceVariant))
                    : null,
              ),
              Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name ?? 'Unknown Package',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(CupertinoIcons.location_solid, color: Colors.white.withOpacity(0.8), size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${package.destination ?? 'Unknown'}, ${package.country ?? ''}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.8)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (package.price != null)
                          Text('\$${package.price}', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        if (package.rating != null)
                          Row(
                            children: [
                              Icon(CupertinoIcons.star_fill, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(package.rating.toString(), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                      ],
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

  Widget _buildPlaceCard(ThemeData theme, dynamic place) {
    return GestureDetector(
      onTap: () => context.push('/place-details/${place.id}'),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  image: place.coverImage != null && place.coverImage.isNotEmpty
                      ? DecorationImage(image: NetworkImage(place.coverImage), fit: BoxFit.cover)
                      : null,
                ),
                child: place.coverImage == null || place.coverImage.isEmpty
                    ? Center(child: Icon(CupertinoIcons.photo, size: 48, color: theme.colorScheme.onSurfaceVariant))
                    : null,
              ),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name ?? 'Unknown Place',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(CupertinoIcons.location_solid, color: Colors.white.withOpacity(0.8), size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${place.city ?? 'Unknown'}, ${place.country ?? ''}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.8)),
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
      ),
    );
  }

  Widget _buildHotelCard(ThemeData theme, dynamic hotel) {
    return GestureDetector(
      onTap: () => context.push('/hotel-details/${hotel.id}'),
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  image: hotel.coverImage != null && hotel.coverImage.isNotEmpty
                      ? DecorationImage(image: NetworkImage(hotel.coverImage), fit: BoxFit.cover)
                      : null,
                ),
                child: hotel.coverImage == null || hotel.coverImage.isEmpty
                    ? Center(child: Icon(CupertinoIcons.building_2_fill, size: 48, color: theme.colorScheme.onSurfaceVariant))
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name ?? 'Unknown Hotel',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(CupertinoIcons.location_solid, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${hotel.city ?? 'Unknown'}, ${hotel.country ?? ''}',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (hotel.rating != null) ...[
                        Icon(CupertinoIcons.star_fill, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(hotel.rating.toStringAsFixed(1), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                      if (hotel.reviewsCount != null) ...[
                        const SizedBox(width: 4),
                        Text('(${hotel.reviewsCount})', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
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
