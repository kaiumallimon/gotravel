import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/data/models/place_model.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/data/models/search_model.dart';
import 'package:gotravel/presentation/providers/places_provider.dart';
import 'package:gotravel/presentation/providers/user_home_provider.dart';
import 'package:gotravel/presentation/providers/search_provider.dart';
import 'package:gotravel/presentation/widgets/cards/place_card.dart';
import 'package:intl/intl.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  late TabController _filterTabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedFilter = 'All';
  List<PlaceModel> _filteredPlaces = [];
  List<TourPackage> _filteredPackages = [];
  List<Hotel> _filteredHotels = [];
  bool _hasSearched = false;
  bool _isSearching = false;
  
  final List<String> _filterOptions = ['All', 'Packages', 'Places', 'Hotels'];

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _filterTabController = TabController(length: _filterOptions.length, vsync: this);
    
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
    
    // Auto-focus on search field when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      _animationController.forward();
      
      // Load search history
      final searchProvider = Provider.of<SearchProvider>(context, listen: false);
      searchProvider.loadSearchHistory();
    });
  }

  @override
  void dispose() {
    _filterTabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _filteredPlaces.clear();
        _filteredPackages.clear();
        _filteredHotels.clear();
        _hasSearched = false;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
      final homeProvider = Provider.of<UserHomeProvider>(context, listen: false);

      // Search places
      await placesProvider.searchPlaces(query);
      _filteredPlaces = placesProvider.places.where((place) =>
        place.name.toLowerCase().contains(query.toLowerCase()) ||
        (place.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        (place.category?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();

      // Search packages
      _filteredPackages = homeProvider.packages.where((package) =>
        package.name.toLowerCase().contains(query.toLowerCase()) ||
        package.description.toLowerCase().contains(query.toLowerCase()) ||
        package.destination.toLowerCase().contains(query.toLowerCase())
      ).toList();

      // Search hotels
      _filteredHotels = homeProvider.recommendedHotels.where((hotel) =>
        hotel.name.toLowerCase().contains(query.toLowerCase()) ||
        hotel.description.toLowerCase().contains(query.toLowerCase()) ||
        hotel.city.toLowerCase().contains(query.toLowerCase())
      ).toList();

    } catch (e) {
      print('Search error: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search places, packages, hotels...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                        icon: Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                _performSearch(value);
              },
              onSubmitted: (value) {
                _performSearch(value);
              },
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Filter Tabs
              if (_hasSearched) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TabBar(
                    controller: _filterTabController,
                    isScrollable: true,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    indicatorColor: theme.colorScheme.primary,
                    labelStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: theme.textTheme.titleSmall,
                    tabs: _filterOptions.map((filter) => Tab(text: filter)).toList(),
                    onTap: (index) {
                      setState(() {
                        _selectedFilter = _filterOptions[index];
                      });
                    },
                  ),
                ),
                const Divider(height: 1),
              ],
              
              // Content
              Expanded(
                child: _buildSearchContent(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchContent(ThemeData theme) {
    if (!_hasSearched) {
      return _buildInitialContent(theme);
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildSearchResults(theme);
  }

  Widget _buildInitialContent(ThemeData theme) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search History Section
              if (searchProvider.searchHistory.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear Search History'),
                            content: const Text('Are you sure you want to clear all search history?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Clear All'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirmed == true) {
                          await searchProvider.clearSearchHistory();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Search history cleared'),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...searchProvider.searchHistory.take(5).map((historyItem) {
                  return _buildSearchHistoryItem(historyItem, theme, searchProvider);
                }),
                const SizedBox(height: 24),
              ],
              
              // Popular Categories
              Text(
                'Popular Categories',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Popular categories grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3,
                children: [
                  _buildCategoryItem('Adventure', CupertinoIcons.location_solid, Colors.green, theme),
                  _buildCategoryItem('Beach', CupertinoIcons.sun_max, Colors.orange, theme),
                  _buildCategoryItem('Cultural', CupertinoIcons.building_2_fill, Colors.purple, theme),
                  _buildCategoryItem('Mountain', CupertinoIcons.triangle, Colors.blue, theme),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchHistoryItem(SearchHistoryModel historyItem, ThemeData theme, SearchProvider searchProvider) {
    final timeAgo = _getTimeAgo(historyItem.createdAt);
    
    return Dismissible(
      key: Key(historyItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          CupertinoIcons.delete,
          color: theme.colorScheme.onError,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Search History'),
            content: Text('Delete "${historyItem.searchQuery}" from history?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        try {
          await searchProvider.deleteSearchHistoryItem(historyItem.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Search history deleted'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete: $e'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getSearchTypeIcon(historyItem.searchType),
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            historyItem.searchQuery,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              if (historyItem.searchType != null) ...[
                Text(
                  _getSearchTypeLabel(historyItem.searchType),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Text(' • '),
              ],
              Text(
                timeAgo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (historyItem.resultsCount > 0) ...[
                const Text(' • '),
                Text(
                  '${historyItem.resultsCount} results',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // If there was a clicked item, show navigation button
              if (historyItem.clickedItemId != null && historyItem.clickedItemType != null)
                IconButton(
                  icon: Icon(
                    CupertinoIcons.arrow_right_circle,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    _navigateToDetailPage(
                      historyItem.clickedItemId!,
                      historyItem.clickedItemType!,
                    );
                  },
                  tooltip: 'Go to ${historyItem.clickedItemType}',
                ),
              IconButton(
                icon: Icon(
                  CupertinoIcons.delete,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Search History'),
                      content: Text('Delete "${historyItem.searchQuery}" from history?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirmed == true) {
                    try {
                      await searchProvider.deleteSearchHistoryItem(historyItem.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Search history deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete: $e'),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
          onTap: () {
            // Perform search again with the same query
            _searchController.text = historyItem.searchQuery;
            _performSearch(historyItem.searchQuery);
          },
        ),
      ),
    );
  }

  IconData _getSearchTypeIcon(String? searchType) {
    switch (searchType) {
      case 'places':
        return CupertinoIcons.map;
      case 'packages':
        return CupertinoIcons.bag;
      case 'hotels':
        return CupertinoIcons.building_2_fill;
      default:
        return CupertinoIcons.search;
    }
  }

  String _getSearchTypeLabel(String? searchType) {
    switch (searchType) {
      case 'places':
        return 'Places';
      case 'packages':
        return 'Packages';
      case 'hotels':
        return 'Hotels';
      case 'global':
        return 'All';
      default:
        return 'Search';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToDetailPage(String itemId, String itemType) {
    switch (itemType) {
      case 'package':
        context.push('/package-details/$itemId');
        break;
      case 'hotel':
        context.push('/hotel-details/$itemId');
        break;
      case 'place':
        context.push('/place-details/$itemId');
        break;
    }
  }

  Widget _buildSearchResults(ThemeData theme) {
    final totalResults = _filteredPlaces.length + _filteredPackages.length + _filteredHotels.length;
    
    if (totalResults == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.search,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$totalResults results found',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_selectedFilter == 'All' || _selectedFilter == 'Packages')
            _buildPackagesSection(theme),
          
          if (_selectedFilter == 'All' || _selectedFilter == 'Places')
            _buildPlacesSection(theme),
          
          if (_selectedFilter == 'All' || _selectedFilter == 'Hotels')
            _buildHotelsSection(theme),
        ],
      ),
    );
  }

  Widget _buildPackagesSection(ThemeData theme) {
    if (_filteredPackages.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Packages (${_filteredPackages.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredPackages.length,
          itemBuilder: (context, index) {
            final package = _filteredPackages[index];
            return _buildPackageCard(package, theme);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPlacesSection(ThemeData theme) {
    if (_filteredPlaces.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Places (${_filteredPlaces.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredPlaces.length,
          itemBuilder: (context, index) {
            final place = _filteredPlaces[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PlaceCard(
                place: place,
                onTap: () {
                  // Track search click
                  final searchProvider = Provider.of<SearchProvider>(context, listen: false);
                  searchProvider.trackSearchClick(place.id, 'place');
                  
                  // Navigate to place details
                  context.push('/place-details/${place.id}');
                },
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHotelsSection(ThemeData theme) {
    if (_filteredHotels.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hotels (${_filteredHotels.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredHotels.length,
          itemBuilder: (context, index) {
            final hotel = _filteredHotels[index];
            return _buildHotelCard(hotel, theme);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPackageCard(TourPackage package, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.primary.withOpacity(0.1),
          ),
          child: Icon(
            CupertinoIcons.bag,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          package.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              package.destination,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '\$${package.price.toStringAsFixed(0)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: const Icon(CupertinoIcons.chevron_right),
        onTap: () {
          // Track search click
          final searchProvider = Provider.of<SearchProvider>(context, listen: false);
          searchProvider.trackSearchClick(package.id, 'package');
          
          // Navigate to package details
          context.push('/package-details/${package.id}');
        },
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.secondary.withOpacity(0.1),
          ),
          child: Icon(
            CupertinoIcons.building_2_fill,
            color: theme.colorScheme.secondary,
          ),
        ),
        title: Text(
          hotel.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${hotel.city}, ${hotel.country}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Row(
              children: [
                ...List.generate(
                  hotel.rating.toInt(),
                  (index) => Icon(
                    CupertinoIcons.star_fill,
                    size: 12,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  hotel.rating.toString(),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(CupertinoIcons.chevron_right),
        onTap: () {
          // Track search click
          final searchProvider = Provider.of<SearchProvider>(context, listen: false);
          searchProvider.trackSearchClick(hotel.id, 'hotel');
          
          // Navigate to hotel details
          context.push('/hotel-details/${hotel.id}');
        },
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, Color color, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}