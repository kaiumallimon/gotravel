import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gotravel/presentation/providers/user_hotels_provider.dart';
import 'package:gotravel/presentation/providers/booking_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/data/models/room_model.dart';

class HotelBookingPage extends StatefulWidget {
  final String hotelId;
  final String? roomId; // Optional - for direct room booking
  
  const HotelBookingPage({
    super.key,
    required this.hotelId,
    this.roomId,
  });

  @override
  State<HotelBookingPage> createState() => _HotelBookingPageState();
}

class _HotelBookingPageState extends State<HotelBookingPage> {
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int numberOfGuests = 1;
  int roomCount = 1;
  Room? selectedRoom;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController specialRequestsController = TextEditingController();
  final TextEditingController accessibilityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserHotelsProvider>(context, listen: false);
      // Load hotel details if not already loaded
      final hotel = provider.hotels.firstWhere(
        (h) => h.id == widget.hotelId,
        orElse: () => provider.hotels.first, // fallback
      );
      
      // Pre-select room if roomId provided
      if (widget.roomId != null && hotel.rooms.isNotEmpty) {
        setState(() {
          selectedRoom = hotel.rooms.firstWhere(
            (room) => room.id == widget.roomId,
            orElse: () => hotel.rooms.first,
          );
        });
      } else if (hotel.rooms.isNotEmpty) {
        setState(() {
          selectedRoom = hotel.rooms.first;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    specialRequestsController.dispose();
    accessibilityController.dispose();
    super.dispose();
  }

  int get numberOfNights {
    if (checkInDate == null || checkOutDate == null) return 0;
    return checkOutDate!.difference(checkInDate!).inDays;
  }

  double get totalPrice {
    if (selectedRoom == null || numberOfNights == 0) return 0;
    return selectedRoom!.pricePerNight * numberOfNights * roomCount;
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
          'Book Hotel',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            CupertinoIcons.back,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Consumer<UserHotelsProvider>(
        builder: (context, hotelProvider, child) {
          final hotel = hotelProvider.hotels.firstWhere(
            (h) => h.id == widget.hotelId,
            orElse: () => hotelProvider.hotels.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hotel Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          hotel.coverImage,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: theme.colorScheme.surfaceContainerHigh,
                              child: Icon(
                                CupertinoIcons.building_2_fill,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hotel.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.location_solid,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${hotel.city}, ${hotel.country}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // Room Selection
                if (hotel.rooms.isNotEmpty) ...[
                  Text(
                    'Select Room',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Room>(
                        value: selectedRoom,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        borderRadius: BorderRadius.circular(12),
                        items: hotel.rooms.map((room) {
                          return DropdownMenuItem<Room>(
                            value: room,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  room.roomType,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${room.currency} ${room.pricePerNight.toStringAsFixed(2)}/night',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (Room? room) {
                          setState(() {
                            selectedRoom = room;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Check-in Date
                Text(
                  'Check-in Date',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: checkInDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        checkInDate = picked;
                        // Reset checkout if it's before check-in
                        if (checkOutDate != null && checkOutDate!.isBefore(picked.add(const Duration(days: 1)))) {
                          checkOutDate = null;
                        }
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          checkInDate == null
                              ? 'Select check-in date'
                              : '${checkInDate!.day}/${checkInDate!.month}/${checkInDate!.year}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: checkInDate == null
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Check-out Date
                Text(
                  'Check-out Date',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: checkInDate == null
                      ? null
                      : () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: checkOutDate ?? checkInDate!.add(const Duration(days: 1)),
                            firstDate: checkInDate!.add(const Duration(days: 1)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() {
                              checkOutDate = picked;
                            });
                          }
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: checkInDate == null 
                          ? theme.colorScheme.surfaceContainerHighest
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          color: checkInDate == null
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          checkOutDate == null
                              ? 'Select check-out date'
                              : '${checkOutDate!.day}/${checkOutDate!.month}/${checkOutDate!.year}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: checkOutDate == null
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Number of Rooms
                Text(
                  'Number of Rooms',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rooms',
                        style: theme.textTheme.bodyLarge,
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: roomCount > 1
                                ? () {
                                    setState(() {
                                      roomCount--;
                                    });
                                  }
                                : null,
                            icon: const Icon(CupertinoIcons.minus_circle),
                          ),
                          Text(
                            roomCount.toString(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                roomCount++;
                              });
                            },
                            icon: const Icon(CupertinoIcons.plus_circle),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Number of Guests
                Text(
                  'Number of Guests',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Guests',
                        style: theme.textTheme.bodyLarge,
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: numberOfGuests > 1
                                ? () {
                                    setState(() {
                                      numberOfGuests--;
                                    });
                                  }
                                : null,
                            icon: const Icon(CupertinoIcons.minus_circle),
                          ),
                          Text(
                            numberOfGuests.toString(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                numberOfGuests++;
                              });
                            },
                            icon: const Icon(CupertinoIcons.plus_circle),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Guest Information
                Text(
                  'Guest Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(CupertinoIcons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(CupertinoIcons.mail),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Phone
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixIcon: const Icon(CupertinoIcons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Special Requests
                Text(
                  'Special Requests (Optional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: specialRequestsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'e.g., Late check-in, early breakfast',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Accessibility Needs
                Text(
                  'Accessibility Needs (Optional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accessibilityController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'e.g., Wheelchair accessible, ground floor room',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Booking Summary
                if (checkInDate != null && checkOutDate != null && selectedRoom != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking Summary',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          'Room Type',
                          selectedRoom!.roomType,
                          theme,
                        ),
                        _buildSummaryRow(
                          'Number of Nights',
                          numberOfNights.toString(),
                          theme,
                        ),
                        _buildSummaryRow(
                          'Number of Rooms',
                          roomCount.toString(),
                          theme,
                        ),
                        _buildSummaryRow(
                          'Number of Guests',
                          numberOfGuests.toString(),
                          theme,
                        ),
                        _buildSummaryRow(
                          'Price per Night',
                          '${selectedRoom!.currency} ${selectedRoom!.pricePerNight.toStringAsFixed(2)}',
                          theme,
                        ),
                        const Divider(),
                        _buildSummaryRow(
                          'Total Amount',
                          '${selectedRoom!.currency} ${totalPrice.toStringAsFixed(2)}',
                          theme,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Book Button
                SizedBox(
                  width: double.infinity,
                  child: Consumer<BookingProvider>(
                    builder: (context, bookingProvider, child) {
                      return FilledButton(
                        onPressed: bookingProvider.isLoading
                            ? null
                            : _canProceedWithBooking()
                            ? () => _handleBooking(context)
                            : null,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: bookingProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Proceed to Payment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceedWithBooking() {
    return checkInDate != null &&
        checkOutDate != null &&
        selectedRoom != null &&
        nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.isNotEmpty;
  }

  Future<void> _handleBooking(BuildContext context) async {
    if (!_canProceedWithBooking()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    
    try {
      // Use the new createHotelBooking with bKash integration
      final result = await bookingProvider.createHotelBooking(
        hotelId: widget.hotelId,
        roomId: selectedRoom!.id,
        primaryGuestName: nameController.text,
        primaryGuestEmail: emailController.text,
        primaryGuestPhone: phoneController.text,
        totalParticipants: numberOfGuests,
        checkInDate: checkInDate!,
        checkOutDate: checkOutDate!,
        roomCount: roomCount,
        basePrice: totalPrice,
        currency: selectedRoom!.currency,
        specialRequests: specialRequestsController.text.isNotEmpty 
            ? specialRequestsController.text 
            : null,
        accessibilityNeeds: accessibilityController.text.isNotEmpty 
            ? accessibilityController.text 
            : null,
      );
      
      if (result == null) {
        // Error already set in provider
        if (context.mounted && bookingProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking failed: ${bookingProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      if (context.mounted) {
        // Navigate to bKash WebView payment page
        context.push('/bkash-payment', extra: {
          'paymentUrl': result['bkashURL'],
          'paymentID': result['paymentID'],
          'idToken': result['idToken'],
          'bookingId': result['booking'].id,
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
