import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus on search field when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Container(
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
                        setState(() {});
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
              setState(() {});
              // TODO: Implement search functionality
            },
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search suggestions or recent searches
            if (_searchController.text.isEmpty) ...[
              Text(
                'Recent Searches',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Recent search items (placeholder)
              _buildRecentSearchItem('Swiss Alps', CupertinoIcons.location, theme),
              _buildRecentSearchItem('Beach Packages', CupertinoIcons.bag, theme),
              _buildRecentSearchItem('Luxury Hotels', CupertinoIcons.building_2_fill, theme),
              
              const SizedBox(height: 24),
              
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
            ] else ...[
              // Search results
              Text(
                'Search Results',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // TODO: Replace with actual search results
              Center(
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Searching for "${_searchController.text}"...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search functionality will be implemented soon',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(String text, IconData icon, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        title: Text(
          text,
          style: theme.textTheme.bodyMedium,
        ),
        trailing: IconButton(
          onPressed: () {
            // Remove from recent searches
          },
          icon: Icon(
            CupertinoIcons.xmark,
            color: theme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
        ),
        onTap: () {
          _searchController.text = text;
          setState(() {});
        },
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, Color color, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        setState(() {});
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