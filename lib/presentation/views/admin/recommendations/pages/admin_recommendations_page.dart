import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/presentation/providers/admin_recommendations_provider.dart';
import 'package:provider/provider.dart';

class AdminRecommendationsPage extends StatefulWidget {
  const AdminRecommendationsPage({super.key});

  @override
  State<AdminRecommendationsPage> createState() => _AdminRecommendationsPageState();
}

class _AdminRecommendationsPageState extends State<AdminRecommendationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminRecommendationsProvider>(context, listen: false)
          .loadRecommendationsData();
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
    final provider = Provider.of<AdminRecommendationsProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Manage Recommendations',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Packages'),
            Tab(text: 'Hotels'),
          ],
        ),
        actions: [
          if (provider.isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(CupertinoIcons.refresh),
              onPressed: () => provider.refreshData(),
            ),
        ],
      ),
      body: provider.isLoading
          ? _buildLoading()
          : provider.error != null
              ? _buildError(provider.error!, provider)
              : Column(
                  children: [
                    _buildStatsSection(theme, provider),
                    _buildFiltersSection(theme),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPackagesTab(provider),
                          _buildHotelsTab(provider),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading recommendations...'),
        ],
      ),
    );
  }

  Widget _buildError(String error, AdminRecommendationsProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 64,
            color: Colors.red.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.refreshData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, AdminRecommendationsProvider provider) {
    final stats = provider.stats;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total',
              '${stats['total'] ?? 0}',
              CupertinoIcons.star_circle_fill,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              'Packages',
              '${stats['packages'] ?? 0}',
              CupertinoIcons.cube_box_fill,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              'Hotels',
              '${stats['hotels'] ?? 0}',
              CupertinoIcons.house_fill,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(CupertinoIcons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _currentFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'recommended', child: Text('Recommended')),
                  DropdownMenuItem(value: 'not_recommended', child: Text('Not Recommended')),
                ],
                onChanged: (value) {
                  setState(() {
                    _currentFilter = value ?? 'all';
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesTab(AdminRecommendationsProvider provider) {
    List<Map<String, dynamic>> packages = provider.filterPackages(_currentFilter);
    
    if (_searchController.text.isNotEmpty) {
      packages = provider.searchPackages(_searchController.text);
      packages = packages.where((item) {
        if (_currentFilter == 'recommended') return item['isRecommended'] == true;
        if (_currentFilter == 'not_recommended') return item['isRecommended'] != true;
        return true;
      }).toList();
    }

    if (packages.isEmpty) {
      return _buildEmptyState('No packages found', CupertinoIcons.cube_box);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final item = packages[index];
        final package = item['package'] as TourPackage;
        final isRecommended = item['isRecommended'] as bool;

        return _buildPackageCard(package, isRecommended, provider);
      },
    );
  }

  Widget _buildHotelsTab(AdminRecommendationsProvider provider) {
    List<Map<String, dynamic>> hotels = provider.filterHotels(_currentFilter);
    
    if (_searchController.text.isNotEmpty) {
      hotels = provider.searchHotels(_searchController.text);
      hotels = hotels.where((item) {
        if (_currentFilter == 'recommended') return item['isRecommended'] == true;
        if (_currentFilter == 'not_recommended') return item['isRecommended'] != true;
        return true;
      }).toList();
    }

    if (hotels.isEmpty) {
      return _buildEmptyState('No hotels found', CupertinoIcons.house);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hotels.length,
      itemBuilder: (context, index) {
        final item = hotels[index];
        final hotel = item['hotel'] as Hotel;
        final isRecommended = item['isRecommended'] as bool;

        return _buildHotelCard(hotel, isRecommended, provider);
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(TourPackage package, bool isRecommended, AdminRecommendationsProvider provider) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecommended 
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            package.coverImage,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 60,
              height: 60,
              color: theme.colorScheme.surfaceVariant,
              child: const Icon(CupertinoIcons.cube_box),
            ),
          ),
        ),
        title: Text(
          package.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${package.country} • ${package.durationDays} days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${package.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: Switch.adaptive(
          value: isRecommended,
          onChanged: (value) async {
            try {
              await provider.togglePackageRecommendation(package.id, isRecommended);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isRecommended 
                          ? 'Removed from recommendations'
                          : 'Added to recommendations'
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          activeColor: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel, bool isRecommended, AdminRecommendationsProvider provider) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecommended 
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            hotel.coverImage,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 60,
              height: 60,
              color: theme.colorScheme.surfaceVariant,
              child: Icon(CupertinoIcons.house),
            ),
          ),
        ),
        title: Text(
          hotel.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              hotel.address,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  CupertinoIcons.star_fill,
                  size: 14,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  hotel.rating.toStringAsFixed(1),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${hotel.rooms.isNotEmpty ? "\$${hotel.rooms.first.pricePerNight.toStringAsFixed(0)}/night" : "No rooms"}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Switch.adaptive(
          value: isRecommended,
          onChanged: (value) async {
            try {
              await provider.toggleHotelRecommendation(hotel.id, isRecommended);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isRecommended 
                          ? 'Removed from recommendations'
                          : 'Added to recommendations'
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          activeColor: theme.colorScheme.primary,
        ),
      ),
    );
  }
}