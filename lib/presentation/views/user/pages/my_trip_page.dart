import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gotravel/data/models/booking_model.dart';
import 'package:gotravel/presentation/providers/booking_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MyTripPage extends StatefulWidget {
  const MyTripPage({super.key});

  @override
  State<MyTripPage> createState() => _MyTripPageState();
}

class _MyTripPageState extends State<MyTripPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).loadUserBookings();
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
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'My Bookings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Packages'),
            Tab(text: 'Hotels'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPackageBookingsTab(provider, theme),
              _buildHotelBookingsTab(provider, theme),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildPackageBookingsTab(BookingProvider provider, ThemeData theme) {
    final packageBookings = provider.userBookings
        .where((b) => b.bookingType == BookingType.package)
        .toList();
    
    if (packageBookings.isEmpty) {
      return _buildEmptyState(
        icon: CupertinoIcons.cube_box,
        title: 'No Package Bookings',
        subtitle: 'Your package bookings will appear here',
        buttonText: 'Browse Packages',
        onPressed: () => context.go('/home'),
        theme: theme,
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => provider.loadUserBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: packageBookings.length,
        itemBuilder: (context, index) {
          final booking = packageBookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildPackageBookingCard(booking, theme),
          );
        },
      ),
    );
  }
  
  Widget _buildHotelBookingsTab(BookingProvider provider, ThemeData theme) {
    final hotelBookings = provider.userBookings
        .where((b) => b.bookingType == BookingType.hotel)
        .toList();
    
    if (hotelBookings.isEmpty) {
      return _buildEmptyState(
        icon: CupertinoIcons.building_2_fill,
        title: 'No Hotel Bookings',
        subtitle: 'Your hotel bookings will appear here',
        buttonText: 'Browse Hotels',
        onPressed: () => context.go('/home'),
        theme: theme,
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => provider.loadUserBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: hotelBookings.length,
        itemBuilder: (context, index) {
          final booking = hotelBookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildHotelBookingCard(booking, theme),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPackageBookingCard(dynamic booking, ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final statusColor = _getStatusColor(booking.bookingStatus);
    final paymentStatusColor = _getPaymentStatusColor(booking.paymentStatus);
    
    return InkWell(
      onTap: () {
        // Navigate to booking details
        context.push('/booking-details', extra: booking);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badges
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(booking.bookingStatus),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: paymentStatusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          booking.paymentStatus == PaymentStatus.paid
                              ? CupertinoIcons.check_mark_circled_solid
                              : CupertinoIcons.time_solid,
                          size: 12,
                          color: paymentStatusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getPaymentStatusText(booking.paymentStatus),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: paymentStatusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Guest name
                  Text(
                    booking.primaryGuestName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Departure date
                  if (booking.departureDate != null)
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Departure: ${dateFormat.format(booking.departureDate!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Participants
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.person_2_fill,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${booking.totalParticipants} ${booking.totalParticipants > 1 ? 'Guests' : 'Guest'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${booking.currency} ${booking.totalAmount.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHotelBookingCard(dynamic booking, ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final statusColor = _getStatusColor(booking.bookingStatus);
    final paymentStatusColor = _getPaymentStatusColor(booking.paymentStatus);
    
    return InkWell(
      onTap: () {
        // Navigate to booking details
        context.push('/booking-details', extra: booking);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badges
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(booking.bookingStatus),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: paymentStatusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          booking.paymentStatus == PaymentStatus.paid
                              ? CupertinoIcons.check_mark_circled_solid
                              : CupertinoIcons.time_solid,
                          size: 12,
                          color: paymentStatusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getPaymentStatusText(booking.paymentStatus),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: paymentStatusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Guest name
                  Text(
                    booking.primaryGuestName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Check-in date
                  if (booking.checkInDate != null)
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Check-in: ${dateFormat.format(booking.checkInDate!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 6),
                  
                  // Check-out date
                  if (booking.checkOutDate != null)
                    Row(
                      children: [
                        const SizedBox(width: 24),
                        Text(
                          'Check-out: ${dateFormat.format(booking.checkOutDate!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Guests and rooms
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.person_2_fill,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${booking.totalParticipants} ${booking.totalParticipants > 1 ? 'Guests' : 'Guest'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        CupertinoIcons.bed_double_fill,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${booking.roomCount ?? 1} ${(booking.roomCount ?? 1) > 1 ? 'Rooms' : 'Room'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${booking.currency} ${booking.totalAmount.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(dynamic status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }
  
  String _getPaymentStatusText(dynamic status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(dynamic status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  Color _getPaymentStatusColor(dynamic status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}