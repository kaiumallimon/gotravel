import 'package:flutter/material.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/data/models/package_activity_model.dart';

class DetailedPackagePage extends StatefulWidget {
  final TourPackage package;
  const DetailedPackagePage({super.key, required this.package});

  @override
  State<DetailedPackagePage> createState() => _DetailedPackagePageState();
}

class _DetailedPackagePageState extends State<DetailedPackagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _showImageViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageViewer(
          images: widget.package.images,
          initialIndex: initialIndex,
          heroTag: 'package_image_$initialIndex',
        ),
      ),
    );
  }

  void _editPackage(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/admin/packages/add',
      arguments: widget.package,
    );
  }

  void _deletePackage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Package'),
        content: Text('Are you sure you want to delete "${widget.package.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Return to packages list with delete signal
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            title: Text(widget.package.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: 20,
                )),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () => _editPackage(context),
                icon: Icon(Icons.edit),
                tooltip: 'Edit Package',
              ),
              IconButton(
                onPressed: () => _deletePackage(context),
                icon: Icon(Icons.delete),
                tooltip: 'Delete Package',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.package.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.package.coverImage,
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: theme.scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Itinerary'),
                    Tab(text: 'Dates'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(theme),
            _buildItineraryTab(theme),
            _buildDatesTab(theme),
          ],
        ),
      ),
    );
  }

  /// 📋 Overview Tab
  Widget _buildOverviewTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status and Category Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.package.isActive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.package.isActive ? 'ACTIVE' : 'INACTIVE',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.primary),
              ),
              child: Text(
                widget.package.category.toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),

        // Rating and Reviews
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 6),
            Text(
              widget.package.rating.toStringAsFixed(1),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "(${widget.package.reviewsCount} reviews)",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),

        // Package Info Cards
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                theme,
                Icons.schedule,
                'Duration',
                widget.package.getDurationDisplay(),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                theme,
                Icons.attach_money,
                'Price',
                widget.package.getPriceDisplay(),
                Colors.green,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                theme,
                Icons.people,
                'Max Participants',
                '${widget.package.maxParticipants}',
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                theme,
                Icons.event_available,
                'Available Slots',
                '${widget.package.availableSlots}',
                Colors.purple,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Description
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.package.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),

        const SizedBox(height: 20),

        // Location Info
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "${widget.package.destination}, ${widget.package.country}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Contact Info
        Row(
          children: [
            const Icon(Icons.email_outlined, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.package.contactEmail)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.phone, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.package.contactPhone)),
          ],
        ),

        if (widget.package.difficultyLevel != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Difficulty: ${widget.package.difficultyLevel}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],

        if (widget.package.minimumAge > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.child_friendly, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                'Minimum Age: ${widget.package.minimumAge} years',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),

        // Included Services
        if (widget.package.includedServices.isNotEmpty) ...[
          Text(
            "Included Services",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.package.includedServices
                .map((service) => _buildServiceChip(theme, service, Colors.green))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Excluded Services
        if (widget.package.excludedServices.isNotEmpty) ...[
          Text(
            "Not Included",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.package.excludedServices
                .map((service) => _buildServiceChip(theme, service, Colors.red))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Gallery
        Text(
          "Gallery",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.package.images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showImageViewer(context, index),
                child: Hero(
                  tag: 'package_image_$index',
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(widget.package.images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 📅 Itinerary Tab
  Widget _buildItineraryTab(ThemeData theme) {
    if (widget.package.activities.isEmpty) {
      return const Center(child: Text("No activities available."));
    }

    // Group activities by day
    Map<int, List<PackageActivity>> activitiesByDay = {};
    for (var activity in widget.package.activities) {
      if (!activitiesByDay.containsKey(activity.dayNumber)) {
        activitiesByDay[activity.dayNumber] = [];
      }
      activitiesByDay[activity.dayNumber]!.add(activity);
    }

    final sortedDays = activitiesByDay.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final dayNumber = sortedDays[index];
        final dayActivities = activitiesByDay[dayNumber]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Day $dayNumber',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ...dayActivities.map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildActivityItem(theme, activity),
                )).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 📆 Dates Tab
  Widget _buildDatesTab(ThemeData theme) {
    debugPrint('🔍 Package dates count: ${widget.package.packageDates.length}');
    debugPrint('🔍 Package dates: ${widget.package.packageDates}');
    
    if (widget.package.packageDates.isEmpty) {
      return const Center(child: Text("No dates available."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.package.packageDates.length,
      itemBuilder: (context, index) {
        final packageDate = widget.package.packageDates[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Departure',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: packageDate.isActive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        packageDate.isActive ? 'Available' : 'Unavailable',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${packageDate.departureDate.day}/${packageDate.departureDate.month}/${packageDate.departureDate.year}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Return',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${packageDate.returnDate.day}/${packageDate.returnDate.month}/${packageDate.returnDate.year}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, size: 18),
                        const SizedBox(width: 4),
                        Text('${packageDate.availableSlots} slots'),
                      ],
                    ),
                    if (packageDate.priceOverride != null)
                      Text(
                        '${widget.package.currency}${packageDate.priceOverride!.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        widget.package.getPriceDisplay(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(ThemeData theme, IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(ThemeData theme, String service, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        service,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActivityItem(ThemeData theme, PackageActivity activity) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activity.activityName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (activity.isOptional)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Row(
            children: [
              Icon(Icons.category, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                activity.activityType,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          if (activity.startTime != null || activity.endTime != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${activity.startTime ?? ''} - ${activity.endTime ?? ''}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 4),
          
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.red),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  activity.location,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            activity.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          if (activity.additionalCost > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Additional cost: ${widget.package.currency}${activity.additionalCost.toStringAsFixed(0)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String heroTag;

  const _ImageViewer({
    required this.images,
    required this.initialIndex,
    required this.heroTag,
  });

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: Hero(
                tag: index == widget.initialIndex ? widget.heroTag : 'package_image_$index',
                child: Image.network(
                  widget.images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 64,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.images.length > 1
          ? Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}