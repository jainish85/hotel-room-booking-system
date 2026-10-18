import 'package:flutter/material.dart';

import '../../models/room_model.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';
import '../../services/booking_service.dart';

class BookingScreen extends StatefulWidget {
  final RoomModel room;
  final UserModel user;

  const BookingScreen({
    super.key,
    required this.room,
    required this.user,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // ==================================================
  // SERVICES & CONTROLLERS
  // ==================================================
  final BookingService bookingService = BookingService();

  final TextEditingController guestNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // ==================================================
  // STATE VARIABLES
  // ==================================================
  DateTime? checkInDate;
  DateTime? checkOutDate;

  int adults = 1;
  int children = 0;

  List<int?> childAges = [];

  double totalAmount = 0;

  bool isCheckingAvailability = false;
  bool isBooking = false;
  bool availabilityChecked = false;
  bool roomIsAvailable = false;

  // ==================================================
  // LIFECYCLE METHODS
  // ==================================================
  @override
  void initState() {
    super.initState();
    guestNameController.text = widget.user.name;
    phoneController.text = widget.user.phone;
  }

  @override
  void dispose() {
    guestNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // ==================================================
  // COMPUTED GETTERS
  // ==================================================
  int get totalGuests => adults + children;

  String get bookingRoomType {
    if (children > 0) {
      return 'Family';
    }
    return widget.room.roomType;
  }

  int get maximumAdults => widget.room.capacity;

  int get maximumChildren => widget.room.capacity - adults;

  bool get allChildAgesSelected {
    return childAges.length == children &&
        childAges.every((age) => age != null);
  }

  // ==================================================
  // DATE SELECTION HANDLERS
  // ==================================================
  Future<void> selectCheckInDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: checkInDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (selectedDate == null) return;

    setState(() {
      checkInDate = selectedDate;
      checkOutDate = null;
      totalAmount = 0;
      availabilityChecked = false;
      roomIsAvailable = false;
    });
  }

  Future<void> selectCheckOutDate() async {
    if (checkInDate == null) {
      showMessage('Please select check-in date first.');
      return;
    }

    final firstDate = checkInDate!.add(const Duration(days: 1));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: checkOutDate ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime(DateTime.now().year + 2),
    );

    if (selectedDate == null) return;

    setState(() {
      checkOutDate = selectedDate;
      availabilityChecked = false;
      roomIsAvailable = false;
      calculateTotal();
    });
  }

  // ==================================================
  // CALCULATION LOGIC
  // ==================================================
  void calculateTotal() {
    if (checkInDate == null || checkOutDate == null) {
      totalAmount = 0;
      return;
    }

    final nights = checkOutDate!.difference(checkInDate!).inDays;

    if (nights <= 0) {
      totalAmount = 0;
      return;
    }

    totalAmount = widget.room.price * nights;
  }

  // ==================================================
  // CHECK AVAILABILITY
  // ==================================================
  Future<void> checkAvailability() async {
    if (checkInDate == null || checkOutDate == null) {
      showMessage('Please select both check-in and check-out dates.');
      return;
    }

    if (checkOutDate!.isBefore(checkInDate!) ||
        checkOutDate!.isAtSameMomentAs(checkInDate!)) {
      showMessage('Check-out date must be after check-in date.');
      return;
    }

    if (adults <= 0) {
      showMessage('At least one adult is required.');
      return;
    }

    if (totalGuests > widget.room.capacity) {
      showMessage(
        'This room supports a maximum of ${widget.room.capacity} guest(s).',
      );
      return;
    }

    if (children > 0 && !allChildAgesSelected) {
      showMessage('Please select the age of every child.');
      return;
    }

    if (!widget.room.isActive) {
      showMessage('This room is currently inactive.');
      return;
    }

    setState(() {
      isCheckingAvailability = true;
      availabilityChecked = false;
      roomIsAvailable = false;
    });

    try {
      final available = await bookingService.isRoomAvailable(
        roomId: widget.room.id,
        checkIn: checkInDate!,
        checkOut: checkOutDate!,
      );

      if (!mounted) return;

      setState(() {
        isCheckingAvailability = false;
        availabilityChecked = true;
        roomIsAvailable = available;

        if (available) {
          calculateTotal();
        } else {
          totalAmount = 0;
        }
      });

      if (available) {
        showMessage('Room is available for selected dates.');
      } else {
        showMessage('Room is not available for selected dates.');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCheckingAvailability = false;
        availabilityChecked = false;
        roomIsAvailable = false;
      });

      showMessage('Unable to check availability: $e');
    }
  }

  // ==================================================
  // CONFIRM BOOKING
  // ==================================================
  Future<void> confirmBooking() async {
    if (checkInDate == null || checkOutDate == null) {
      showMessage('Please select check-in and check-out dates.');
      return;
    }

    if (guestNameController.text.trim().isEmpty) {
      showMessage('Please enter guest name.');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage('Please enter phone number.');
      return;
    }

    if (adults <= 0) {
      showMessage('At least one adult is required.');
      return;
    }

    if (totalGuests > widget.room.capacity) {
      showMessage(
        'This room supports a maximum of ${widget.room.capacity} guest(s).',
      );
      return;
    }

    if (children > 0 && !allChildAgesSelected) {
      showMessage('Please select the age of every child.');
      return;
    }

    if (!availabilityChecked) {
      showMessage('Please check room availability first.');
      return;
    }

    if (!roomIsAvailable) {
      showMessage('This room is not available for the selected dates.');
      return;
    }

    setState(() {
      isBooking = true;
    });

    try {
      final booking = await bookingService.createBooking(
        customerId: widget.user.id,
        customerName: guestNameController.text.trim(),
        customerPhone: phoneController.text.trim(),
        roomId: widget.room.id,
        roomNumber: widget.room.roomNumber,
        roomName: widget.room.roomName,
        checkIn: checkInDate!,
        checkOut: checkOutDate!,
        guests: totalGuests,
        adults: adults,
        children: children,
        childAges: childAges.whereType<int>().toList(),
        roomPrice: widget.room.price,
      );

      if (!mounted) return;

      setState(() {
        isBooking = false;
      });

      if (booking == null) {
        setState(() {
          availabilityChecked = false;
          roomIsAvailable = false;
          totalAmount = 0;
        });

        showMessage('The room is no longer available for those dates.');
        return;
      }

      showBookingSuccess(booking);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isBooking = false;
      });

      showMessage('Unable to create booking: $e');
    }
  }

  // ==================================================
  // DIALOGS & HELPER METHODS
  // ==================================================
  void showBookingSuccess(BookingModel booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Booking Confirmed'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your room has been booked successfully.'),
                const SizedBox(height: 16),
                Text('Booking ID: ${booking.id}'),
                const SizedBox(height: 8),
                Text('Room: ${booking.roomName}'),
                const SizedBox(height: 8),
                Text('Room Number: ${booking.roomNumber}'),
                const SizedBox(height: 8),
                Text(
                  'Booking Type: '
                      '${booking.children > 0 ? 'Family' : booking.roomName}',
                ),
                const SizedBox(height: 8),
                Text('Check-in: ${formatDate(booking.checkIn)}'),
                const SizedBox(height: 8),
                Text('Check-out: ${formatDate(booking.checkOut)}'),
                const SizedBox(height: 8),
                Text('Adults: ${booking.adults}'),
                const SizedBox(height: 8),
                Text('Children: ${booking.children}'),
                if (booking.childAges.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Child Ages: ${booking.childAges.join(', ')}'),
                ],
                const SizedBox(height: 8),
                Text('Guests: ${booking.guests}'),
                const SizedBox(height: 8),
                Text('Nights: ${booking.numberOfNights}'),
                const SizedBox(height: 8),
                Text(
                  'Total: ₹${booking.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    return '${date.day}/${date.month}/${date.year}';
  }

  // ==================================================
  // GUEST COUNTER HANDLERS
  // ==================================================
  void increaseChildren() {
    if (children >= maximumChildren) {
      showMessage(
        'This room supports a maximum of ${widget.room.capacity} guest(s).',
      );
      return;
    }

    setState(() {
      children++;
      childAges.add(null);
      availabilityChecked = false;
      roomIsAvailable = false;
    });
  }

  void decreaseChildren() {
    if (children <= 0) return;

    setState(() {
      children--;
      if (childAges.isNotEmpty) {
        childAges.removeLast();
      }
      availabilityChecked = false;
      roomIsAvailable = false;
    });
  }

  void increaseAdults() {
    if (totalGuests >= widget.room.capacity) {
      showMessage(
        'Maximum ${widget.room.capacity} guest(s) allowed for this room.',
      );
      return;
    }

    setState(() {
      adults++;
      availabilityChecked = false;
      roomIsAvailable = false;
    });
  }

  void decreaseAdults() {
    if (adults <= 1) return;

    setState(() {
      adults--;
      availabilityChecked = false;
      roomIsAvailable = false;
    });
  }

  // ==================================================
  // WIDGET BUILDERS
  // ==================================================
  Widget buildGuestCounter({
    required String title,
    required String subtitle,
    required int value,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: value > 0 ? onDecrease : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: onIncrease,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  Widget buildChildAgeSelector(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<int>(
        initialValue: childAges[index],
        decoration: InputDecoration(
          labelText: 'Child ${index + 1} age',
          prefixIcon: const Icon(Icons.child_care),
          border: const OutlineInputBorder(),
        ),
        items: List.generate(
          12,
              (i) {
            final age = i + 4;
            return DropdownMenuItem<int>(
              value: age,
              child: Text('$age years'),
            );
          },
        ),
        onChanged: isBooking
            ? null
            : (value) {
          setState(() {
            childAges[index] = value;
            availabilityChecked = false;
            roomIsAvailable = false;
          });
        },
      ),
    );
  }

  // ==================================================
  // MAIN BUILD METHOD
  // ==================================================
  @override
  Widget build(BuildContext context) {
    final nights = checkInDate != null && checkOutDate != null
        ? checkOutDate!.difference(checkInDate!).inDays
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Room'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // ROOM HEADER INFORMATION
            // ==================================================
            Text(
              widget.room.roomName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Room ${widget.room.roomNumber} • '
                  '₹${widget.room.price.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.10),
              ),
              child: Text(
                'Booking Type: $bookingRoomType',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // ==================================================
            // STAY DATES SECTION
            // ==================================================
            const Text(
              'Stay Dates',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBooking ? null : selectCheckInDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      'Check-in\n${formatDate(checkInDate)}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBooking ? null : selectCheckOutDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      'Check-out\n${formatDate(checkOutDate)}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // ==================================================
            // GUESTS COUNTER SECTION
            // ==================================================
            const Text(
              'Guests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            buildGuestCounter(
              title: 'Adults',
              subtitle: 'Age 16+',
              value: adults,
              onDecrease: decreaseAdults,
              onIncrease: increaseAdults,
            ),
            const SizedBox(height: 10),
            buildGuestCounter(
              title: 'Children',
              subtitle: 'Age 4–15',
              value: children,
              onDecrease: decreaseChildren,
              onIncrease: increaseChildren,
            ),
            if (children > 0) ...[
              const SizedBox(height: 16),
              const Text(
                'Child Ages',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...List.generate(
                children,
                buildChildAgeSelector,
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'Total Guests: $totalGuests / ${widget.room.capacity}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 25),

            // ==================================================
            // GUEST INFORMATION INPUT SECTION
            // ==================================================
            const Text(
              'Guest Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: guestNameController,
              enabled: !isBooking,
              decoration: const InputDecoration(
                labelText: 'Guest Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              enabled: !isBooking,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),

            // ==================================================
            // CHECK AVAILABILITY BUTTON & STATUS
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed:
                isCheckingAvailability || isBooking ? null : checkAvailability,
                icon: isCheckingAvailability
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  isCheckingAvailability
                      ? 'Checking...'
                      : 'Check Availability',
                ),
              ),
            ),
            const SizedBox(height: 15),

            if (availabilityChecked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: roomIsAvailable
                      ? Colors.green.withValues(alpha: 0.10)
                      : Colors.red.withValues(alpha: 0.10),
                ),
                child: Row(
                  children: [
                    Icon(
                      roomIsAvailable ? Icons.check_circle : Icons.cancel,
                      color: roomIsAvailable ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        roomIsAvailable
                            ? 'Room is available for these dates.'
                            : 'Room is not available for these dates.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: roomIsAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // ==================================================
            // BOOKING SUMMARY CARD
            // ==================================================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Room Price: ₹${widget.room.price.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    Text('Number of Nights: $nights'),
                    const SizedBox(height: 8),
                    Text('Adults: $adults'),
                    const SizedBox(height: 8),
                    Text('Children: $children'),
                    const SizedBox(height: 8),
                    Text('Total Guests: $totalGuests'),
                    if (children > 0) ...[
                      const SizedBox(height: 8),
                      const Text('Booking Type: Family'),
                    ],
                    const Divider(height: 25),
                    Text(
                      'Total Amount: ₹${totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ==================================================
            // CONFIRM BOOKING BUTTON
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (isBooking ||
                    isCheckingAvailability ||
                    !availabilityChecked ||
                    !roomIsAvailable)
                    ? null
                    : confirmBooking,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isBooking
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Confirm Booking',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}