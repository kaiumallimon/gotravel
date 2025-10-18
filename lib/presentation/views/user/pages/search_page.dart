import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/core/routes/app_routes.dart';
import 'package:gotravel/data/models/search_model.dart';
import 'package:gotravel/presentation/providers/search_provider.dart';
// Removed inline result cards; results are shown on SearchResultsPage
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
  // Inline result state removed; navigation-based results
  
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

  void _goToResults([String? overrideQuery, String? overrideFilter]) {
    final query = (overrideQuery ?? _searchController.text).trim();
    if (query.isEmpty) return;
    final filter = overrideFilter ?? _selectedFilter;
    final q = Uri.encodeComponent(query);
    final f = Uri.encodeComponent(filter);
    context.push('${AppRoutes.searchResults}?q=$q&filter=$f');
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
          child: Row(
            children: [
              Expanded(
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
                                setState(() {
                                  _searchController.clear();
                                });
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
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _goToResults(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _goToResults,
                icon: const Icon(CupertinoIcons.search),
                label: const Text('Search'),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
              ),
            ],
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
              // Content: only initial content on this page
              Expanded(
                child: _buildInitialContent(theme),
              ),
            ],
          ),
        ),
      ),
    );
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
            _searchController.text = historyItem.searchQuery;
            _goToResults(historyItem.searchQuery, _mapHistoryTypeToFilter(historyItem.searchType));
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

  String _mapHistoryTypeToFilter(String? searchType) {
    switch (searchType) {
      case 'places':
        return 'Places';
      case 'packages':
        return 'Packages';
      case 'hotels':
        return 'Hotels';
      default:
        return 'All';
    }
  }

  Widget _buildCategoryItem(String label, IconData icon, Color color, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _goToResults(label, 'All');
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