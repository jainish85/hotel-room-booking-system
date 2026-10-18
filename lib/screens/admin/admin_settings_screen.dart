import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({
    super.key,
  });

  @override
  State<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState
    extends State<AdminSettingsScreen> {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  final TextEditingController hotelNameController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController addressController =
  TextEditingController();

  final TextEditingController checkInController =
  TextEditingController();

  final TextEditingController checkOutController =
  TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  void dispose() {
    hotelNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    checkInController.dispose();
    checkOutController.dispose();
    super.dispose();
  }

  Future<void> loadSettings() async {
    try {
      final document = await firestore
          .collection('settings')
          .doc('hotel')
          .get();

      if (document.exists &&
          document.data() != null) {
        final data = document.data()!;

        hotelNameController.text =
            data['hotelName'] as String? ?? '';

        phoneController.text =
            data['phone'] as String? ?? '';

        emailController.text =
            data['email'] as String? ?? '';

        addressController.text =
            data['address'] as String? ?? '';

        checkInController.text =
            data['checkInTime'] as String? ?? '';

        checkOutController.text =
            data['checkOutTime'] as String? ?? '';
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load system settings.',
          ),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveSettings() async {
    final hotelName =
    hotelNameController.text.trim();

    final phone =
    phoneController.text.trim();

    final email =
    emailController.text.trim();

    final address =
    addressController.text.trim();

    final checkIn =
    checkInController.text.trim();

    final checkOut =
    checkOutController.text.trim();

    if (hotelName.isEmpty) {
      showMessage(
        'Please enter hotel name.',
      );
      return;
    }

    if (phone.isEmpty) {
      showMessage(
        'Please enter hotel phone number.',
      );
      return;
    }

    if (email.isEmpty) {
      showMessage(
        'Please enter hotel email.',
      );
      return;
    }

    if (address.isEmpty) {
      showMessage(
        'Please enter hotel address.',
      );
      return;
    }

    if (checkIn.isEmpty || checkOut.isEmpty) {
      showMessage(
        'Please enter check-in and check-out times.',
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await firestore
          .collection('settings')
          .doc('hotel')
          .set({
        'hotelName': hotelName,
        'phone': phone,
        'email': email,
        'address': address,
        'checkInTime': checkIn,
        'checkOutTime': checkOut,
        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      showMessage(
        'System settings saved successfully.',
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      showMessage(
        'Unable to save system settings.',
      );
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> selectTime(
      TextEditingController controller,
      ) async {
    TimeOfDay initialTime =
    TimeOfDay.now();

    final existing =
    controller.text.trim();

    final parts = existing.split(':');

    if (parts.length == 2) {
      final hour =
      int.tryParse(parts[0]);

      final minute =
      int.tryParse(parts[1]);

      if (hour != null &&
          minute != null &&
          hour >= 0 &&
          hour <= 23 &&
          minute >= 0 &&
          minute <= 59) {
        initialTime = TimeOfDay(
          hour: hour,
          minute: minute,
        );
      }
    }

    final selected =
    await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selected == null) {
      return;
    }

    if (!mounted) return;

    controller.text =
    '${selected.hour.toString().padLeft(2, '0')}:'
        '${selected.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'System Settings',
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'System Settings',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Hotel Information',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: hotelNameController,
              decoration: const InputDecoration(
                labelText: 'Hotel Name',
                prefixIcon:
                Icon(Icons.hotel_outlined),
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType:
              TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Hotel Phone',
                prefixIcon:
                Icon(Icons.phone_outlined),
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              keyboardType:
              TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Hotel Email',
                prefixIcon:
                Icon(Icons.email_outlined),
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Hotel Address',
                prefixIcon:
                Icon(Icons.location_on_outlined),
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Hotel Timings',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: checkInController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Check-In Time',
                prefixIcon:
                Icon(Icons.login),
                border:
                OutlineInputBorder(),
              ),
              onTap: () {
                selectTime(
                  checkInController,
                );
              },
            ),

            const SizedBox(height: 15),

            TextField(
              controller: checkOutController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Check-Out Time',
                prefixIcon:
                Icon(Icons.logout),
                border:
                OutlineInputBorder(),
              ),
              onTap: () {
                selectTime(
                  checkOutController,
                );
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isSaving
                    ? null
                    : saveSettings,
                icon: isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.save_outlined,
                ),
                label: Text(
                  isSaving
                      ? 'Saving...'
                      : 'Save Settings',
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}