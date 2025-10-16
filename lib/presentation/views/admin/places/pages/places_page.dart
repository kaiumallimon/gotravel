import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gotravel/data/models/place_model.dart';
import 'package:gotravel/presentation/providers/admin_places_provider.dart';
import 'package:gotravel/presentation/views/admin/places/pages/add_place_page.dart';
import 'package:gotravel/presentation/views/admin/places/pages/detailed_place_page.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class AdminPlacesPage extends StatefulWidget {
  const AdminPlacesPage({super.key});

  @override
  State<AdminPlacesPage> createState() => _AdminPlacesPageState();
}

class _AdminPlacesPageState extends State<AdminPlacesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Beach', 'Forest', 'Mountain', 'Suburban', 'Urban'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminPlacesProvider>(context, listen: false).loadPlaces();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Header with search and filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search places...',
                    prefixIcon: Icon(CupertinoIcons.search, 
                      color: theme.colorScheme.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  onChanged: (value) {
                    Provider.of<AdminPlacesProvider>(context, listen: false)
                        .searchPlaces(value);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Category filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            Provider.of<AdminPlacesProvider>(context, listen: false)
                                .filterByCategory(category == 'All' ? '' : category);
                          },
                          selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                          checkmarkColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Places list
          Expanded(
            child: Consumer<AdminPlacesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading places',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadPlaces(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (provider.filteredPlaces.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.location,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No places found',
                          style: theme.textTheme.titleMedium,
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
                
                return RefreshIndicator(
                  onRefresh: () => provider.loadPlaces(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.filteredPlaces.length,
                    itemBuilder: (context, index) {
                      final place = provider.filteredPlaces[index];
                      return _buildPlaceCard(place, theme);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddPlaceModal(context);
        },
        icon: const Icon(CupertinoIcons.add),
        label: const Text('Add Place'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPlaceCard(PlaceModel place, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showPlaceDetails(context, place);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Place image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                  ),
                  child: place.images.isNotEmpty
                      ? Image.network(
                          place.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              CupertinoIcons.photo,
                              color: theme.colorScheme.onSurfaceVariant,
                            );
                          },
                        )
                      : Icon(
                          CupertinoIcons.photo,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Place info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(place.category ?? 'Unknown'),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            place.category ?? 'Unknown',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.location,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${place.city}, ${place.country}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        // Rating
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.star_fill,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.rating.toStringAsFixed(1),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        const Spacer(),
                        
                        // Action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                _showEditPlaceModal(context, place);
                              },
                              icon: Icon(
                                CupertinoIcons.pencil,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              tooltip: 'Edit Place',
                            ),
                            IconButton(
                              onPressed: () {
                                _showDeleteConfirmation(context, place);
                              },
                              icon: Icon(
                                CupertinoIcons.delete,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                              tooltip: 'Delete Place',
                            ),
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'beach':
        return Colors.blue;
      case 'forest':
        return Colors.green;
      case 'mountain':
        return Colors.grey;
      case 'suburban':
        return Colors.purple;
      case 'urban':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showAddPlaceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const AddPlacePage(),
        ),
      ),
    );
  }

  void _showEditPlaceModal(BuildContext context, PlaceModel place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: AddPlacePage(placeToEdit: place),
        ),
      ),
    );
  }

  void _showPlaceDetails(BuildContext context, PlaceModel place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: DetailedPlacePage(place: place),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PlaceModel place) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Place'),
        content: Text('Are you sure you want to delete "${place.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AdminPlacesProvider>(context, listen: false)
                  .deletePlace(place.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}