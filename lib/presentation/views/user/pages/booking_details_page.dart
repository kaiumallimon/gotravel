import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gotravel/data/models/booking_model.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/presentation/providers/user_packages_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class BookingDetailsPage extends StatefulWidget {
  final BookingModel booking;
  
  const BookingDetailsPage({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TourPackage? _package;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadItemDetails();
  }

  Future<void> _loadItemDetails() async {
    if (widget.booking.bookingType == BookingType.package) {
      final provider = Provider.of<UserPackagesProvider>(context, listen: false);
      await provider.loadPackageDetails(widget.booking.itemId);
      setState(() {
        _package = provider.selectedPackage;
        _isLoading = false;
      });
    } else {
      // Load hotel details if needed
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  leading: IconButton(
                    icon: Icon(CupertinoIcons.back, color: innerBoxIsScrolled ? theme.colorScheme.onSurface : Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      widget.booking.primaryGuestName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_package != null)
                          Image.network(
                            _package!.coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: theme.colorScheme.primary,
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ),
                            ),
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
                        indicatorColor: theme.colorScheme.primary,
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                        tabs: const [
                          Tab(text: 'Booking Info'),
                          Tab(text: 'Package Details'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingInfoTab(theme, dateFormat),
                  _buildPackageDetailsTab(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingInfoTab(ThemeData theme, DateFormat dateFormat) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status Cards
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                theme,
                'Booking Status',
                _getStatusText(widget.booking.bookingStatus),
                _getStatusColor(widget.booking.bookingStatus),
                _getStatusIcon(widget.booking.bookingStatus),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatusCard(
                theme,
                'Payment Status',
                _getPaymentStatusText(widget.booking.paymentStatus),
                _getPaymentStatusColor(widget.booking.paymentStatus),
                _getPaymentStatusIcon(widget.booking.paymentStatus),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Booking Reference
        _buildInfoSection(
          theme,
          'Booking Reference',
          widget.booking.bookingReference,
          CupertinoIcons.doc_text,
        ),

        const SizedBox(height: 16),

        // Guest Information
        Text(
          'Guest Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildInfoRow(theme, CupertinoIcons.person, 'Name', widget.booking.primaryGuestName),
        const SizedBox(height: 8),
        _buildInfoRow(theme, CupertinoIcons.mail, 'Email', widget.booking.primaryGuestEmail),
        const SizedBox(height: 8),
        _buildInfoRow(theme, CupertinoIcons.phone, 'Phone', widget.booking.primaryGuestPhone),
        const SizedBox(height: 8),
        _buildInfoRow(theme, CupertinoIcons.person_2, 'Participants', '${widget.booking.totalParticipants}'),

        const SizedBox(height: 24),

        // Travel Details
        if (widget.booking.bookingType == BookingType.package) ...[
          Text(
            'Travel Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (widget.booking.departureDate != null)
            _buildInfoRow(
              theme,
              CupertinoIcons.calendar,
              'Departure Date',
              dateFormat.format(widget.booking.departureDate!),
            ),
          
          if (widget.booking.returnDate != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              theme,
              CupertinoIcons.calendar,
              'Return Date',
              dateFormat.format(widget.booking.returnDate!),
            ),
          ],
        ] else ...[
          Text(
            'Hotel Stay Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (widget.booking.checkInDate != null)
            _buildInfoRow(
              theme,
              CupertinoIcons.calendar,
              'Check-in Date',
              dateFormat.format(widget.booking.checkInDate!),
            ),
          
          if (widget.booking.checkOutDate != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              theme,
              CupertinoIcons.calendar,
              'Check-out Date',
              dateFormat.format(widget.booking.checkOutDate!),
            ),
          ],
          
          const SizedBox(height: 8),
          _buildInfoRow(
            theme,
            CupertinoIcons.bed_double,
            'Rooms',
            '${widget.booking.roomCount}',
          ),
        ],

        const SizedBox(height: 24),

        // Payment Details
        Text(
          'Payment Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              _buildPriceRow(theme, 'Base Price', widget.booking.basePrice, widget.booking.currency),
              if (widget.booking.additionalCosts > 0) ...[
                const SizedBox(height: 8),
                _buildPriceRow(theme, 'Additional Costs', widget.booking.additionalCosts, widget.booking.currency),
              ],
              if (widget.booking.taxAmount > 0) ...[
                const SizedBox(height: 8),
                _buildPriceRow(theme, 'Tax', widget.booking.taxAmount, widget.booking.currency),
              ],
              if (widget.booking.discountAmount > 0) ...[
                const SizedBox(height: 8),
                _buildPriceRow(theme, 'Discount', -widget.booking.discountAmount, widget.booking.currency, isDiscount: true),
              ],
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.booking.currency} ${widget.booking.totalAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        
        _buildInfoRow(theme, CupertinoIcons.creditcard, 'Payment Method', widget.booking.paymentMethod ?? 'bKash'),

        // Special Requests
        if (widget.booking.specialRequests != null && widget.booking.specialRequests!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Special Requests',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.booking.specialRequests!,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Booking Date
        _buildInfoRow(
          theme,
          CupertinoIcons.clock,
          'Booked On',
          DateFormat('MMM dd, yyyy - hh:mm a').format(widget.booking.createdAt),
        ),
      ],
    );
  }

  Widget _buildPackageDetailsTab(ThemeData theme) {
    if (_package == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.info_circle,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Package details not available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Package Name and Category
        Text(
          _package!.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.primary),
              ),
              child: Text(
                _package!.category.toUpperCase(),
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

        // Rating
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 6),
            Text(
              _package!.rating.toStringAsFixed(1),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "(${_package!.reviewsCount} reviews)",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Package Info
        Row(
          children: [
            Expanded(
              child: _buildPackageInfoCard(
                theme,
                CupertinoIcons.clock,
                'Duration',
                _package!.getDurationDisplay(),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPackageInfoCard(
                theme,
                CupertinoIcons.location,
                'Destination',
                _package!.destination,
                Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Description
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _package!.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),

        const SizedBox(height: 20),

        // Location
        _buildInfoRow(
          theme,
          CupertinoIcons.location_solid,
          'Location',
          '${_package!.destination}, ${_package!.country}',
        ),

        const SizedBox(height: 20),

        // Included Services
        if (_package!.includedServices.isNotEmpty) ...[
          Text(
            'Included Services',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _package!.includedServices
                .map((service) => _buildServiceChip(theme, service, Colors.green))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Excluded Services
        if (_package!.excludedServices.isNotEmpty) ...[
          Text(
            'Not Included',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _package!.excludedServices
                .map((service) => _buildServiceChip(theme, service, Colors.red))
                .toList(),
          ),
        ],

        const SizedBox(height: 20),

        // Gallery
        if (_package!.images.isNotEmpty) ...[
          Text(
            'Gallery',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _package!.images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(_package!.images[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusCard(ThemeData theme, String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(ThemeData theme, String label, double amount, String currency, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          '${isDiscount ? '-' : ''}$currency ${amount.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDiscount ? Colors.green : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageInfoCard(ThemeData theme, IconData icon, String title, String value, Color color) {
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
            textAlign: TextAlign.center,
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

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return CupertinoIcons.check_mark_circled_solid;
      case BookingStatus.pending:
        return CupertinoIcons.time_solid;
      case BookingStatus.cancelled:
        return CupertinoIcons.xmark_circle_fill;
      case BookingStatus.completed:
        return CupertinoIcons.checkmark_seal_fill;
    }
  }

  IconData _getPaymentStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return CupertinoIcons.money_dollar_circle_fill;
      case PaymentStatus.pending:
        return CupertinoIcons.time_solid;
      case PaymentStatus.failed:
        return CupertinoIcons.xmark_circle_fill;
      case PaymentStatus.refunded:
        return CupertinoIcons.arrow_counterclockwise_circle_fill;
    }
  }
}
