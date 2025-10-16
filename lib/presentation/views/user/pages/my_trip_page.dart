import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gotravel/presentation/providers/booking_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class MyTripPage extends StatefulWidget {
  const MyTripPage({super.key});

  @override
  State<MyTripPage> createState() => _MyTripPageState();
}

class _MyTripPageState extends State<MyTripPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).loadUserBookings();
    });
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
          'My Trips',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = provider.userBookings;
          
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.bag,
                    size: 80,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No trips yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book your first adventure!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.push('/packages');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Browse Packages'),
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
                // Trip categories
                Row(
                  children: [
                    Expanded(
                      child: _buildTripCategoryCard(
                        'Upcoming',
                        bookings.where((b) => b.departureDate?.isAfter(DateTime.now()) ?? false).length,
                        CupertinoIcons.calendar,
                        Colors.blue,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTripCategoryCard(
                        'Ongoing',
                        bookings.where((b) => 
                          (b.departureDate?.isBefore(DateTime.now()) ?? false) && 
                          (b.returnDate?.isAfter(DateTime.now()) ?? true)
                        ).length,
                        CupertinoIcons.location,
                        Colors.green,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTripCategoryCard(
                        'Past',
                        bookings.where((b) => b.returnDate?.isBefore(DateTime.now()) ?? false).length,
                        CupertinoIcons.checkmark_circle,
                        Colors.grey,
                        theme,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // All bookings list
                Text(
                  'All Bookings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                ...bookings.map((booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildBookingCard(booking, theme),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTripCategoryCard(
    String title,
    int count,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(dynamic booking, ThemeData theme) {
    final statusColor = _getStatusColor(booking.bookingStatus);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.itemId, // This would be package name in real implementation
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.bookingStatus.toString().split('.').last.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Booking Reference: ${booking.bookingReference}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          if (booking.departureDate != null)
            Text(
              'Travel Date: ${booking.departureDate!.day}/${booking.departureDate!.month}/${booking.departureDate!.year}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                CupertinoIcons.person_2,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${booking.totalParticipants} people',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${booking.currency} ${booking.totalAmount.toStringAsFixed(0)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(dynamic status) {
    final statusString = status.toString().split('.').last;
    switch (statusString) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}