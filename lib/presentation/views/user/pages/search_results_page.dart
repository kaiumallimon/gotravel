import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:gotravel/data/models/place_model.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/presentation/providers/search_provider.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;
  final String initialFilter; // All, Places, Packages, Hotels

  const SearchResultsPage({super.key, required this.query, this.initialFilter = 'All'});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> with TickerProviderStateMixin {
  late TabController _filterTabController;
  late String _selectedFilter;

  final List<String> _filterOptions = ['All', 'Packages', 'Places', 'Hotels'];

  @override
  void initState() {
    super.initState();
    _selectedFilter = _filterOptions.contains(widget.initialFilter) ? widget.initialFilter : 'All';
    _filterTabController = TabController(length: _filterOptions.length, vsync: this);
    _filterTabController.index = _filterOptions.indexOf(_selectedFilter);

    // Kick off the search after first frame so navigation is smooth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runSearch();
    });
  }

  Future<void> _runSearch() async {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);

    switch (_selectedFilter) {
      case 'Places':
        await searchProvider.searchPlaces(widget.query);
        break;
      case 'Packages':
        await searchProvider.searchPackages(widget.query);
        break;
      case 'Hotels':
        await searchProvider.searchHotels(widget.query);
        break;
      case 'All':
      default:
        await searchProvider.performGlobalSearch(widget.query);
    }
  }

  @override
  void dispose() {
    _filterTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "${widget.query}"'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.loop),
            tooltip: 'Refresh',
            onPressed: _runSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TabBar(
              controller: _filterTabController,
              isScrollable: true,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
              tabs: _filterOptions.map((f) => Tab(text: f)).toList(),
              onTap: (index) async {
                final newFilter = _filterOptions[index];
                if (newFilter != _selectedFilter) {
                  setState(() {
                    _selectedFilter = newFilter;
                  });
                  await _runSearch();
                }
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final places = provider.placeResults;
                final packages = provider.packageResults;
                final hotels = provider.hotelResults;
                final totalResults = places.length + packages.length + hotels.length;

                if (totalResults == 0) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.search, size: 64, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('No results found', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Try a different query', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$totalResults results found', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 16),

                      if (_selectedFilter == 'All' || _selectedFilter == 'Packages')
                        _buildPackagesSection(theme, packages),

                      if (_selectedFilter == 'All' || _selectedFilter == 'Places')
                        _buildPlacesSection(theme, places),

                      if (_selectedFilter == 'All' || _selectedFilter == 'Hotels')
                        _buildHotelsSection(theme, hotels),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesSection(ThemeData theme, List<TourPackage> packages) {
    if (packages.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Packages (${packages.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final p = packages[index];
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
                  child: Icon(CupertinoIcons.bag, color: theme.colorScheme.primary),
                ),
                title: Text(p.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.destination, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    Text('\$${p.price.toStringAsFixed(0)}', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                trailing: const Icon(CupertinoIcons.chevron_right),
                onTap: () {
                  final provider = Provider.of<SearchProvider>(context, listen: false);
                  provider.trackSearchClick(p.id, 'package');
                  context.push('/package-details/${p.id}');
                },
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPlacesSection(ThemeData theme, List<PlaceModel> places) {
    if (places.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Places (${places.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Icon(CupertinoIcons.map, color: theme.colorScheme.primary),
                ),
                title: Text(place.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  [if (place.city != null && place.city!.isNotEmpty) place.city!, place.country].where((e) => e.isNotEmpty).join(', '),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                trailing: const Icon(CupertinoIcons.chevron_right),
                onTap: () {
                  final provider = Provider.of<SearchProvider>(context, listen: false);
                  provider.trackSearchClick(place.id, 'place');
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

  Widget _buildHotelsSection(ThemeData theme, List<Hotel> hotels) {
    if (hotels.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hotels (${hotels.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hotels.length,
          itemBuilder: (context, index) {
            final hotel = hotels[index];
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
                  child: Icon(CupertinoIcons.building_2_fill, color: theme.colorScheme.secondary),
                ),
                title: Text(hotel.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('${hotel.city}, ${hotel.country}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                trailing: const Icon(CupertinoIcons.chevron_right),
                onTap: () {
                  final provider = Provider.of<SearchProvider>(context, listen: false);
                  provider.trackSearchClick(hotel.id, 'hotel');
                  context.push('/hotel-details/${hotel.id}');
                },
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
