import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';

class CustomerProfileScreen extends StatefulWidget {
  final UserModel user;

  const CustomerProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState
    extends State<CustomerProfileScreen> {
  final UserService userService = UserService();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  bool isSaving = false;

  UserModel? currentUser;

  @override
  void initState() {
    super.initState();

    currentUser = widget.user;

    nameController = TextEditingController(
      text: widget.user.name,
    );

    phoneController = TextEditingController(
      text: widget.user.phone,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      showMessage('Please enter your name.');
      return;
    }

    if (phone.isEmpty) {
      showMessage('Please enter your phone number.');
      return;
    }

    if (phone.length < 10) {
      showMessage('Please enter a valid phone number.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await userService.updateCustomerProfile(
        userId: widget.user.id,
        name: name,
        phone: phone,
      );

      final updatedUser =
      await userService.getUserById(
        widget.user.id,
      );

      if (!mounted) return;

      setState(() {
        currentUser = updatedUser;
        isSaving = false;
      });

      showMessage(
        'Profile updated successfully.',
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      showMessage(
        'Unable to update profile.',
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

  String roleText(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.manager:
        return 'Manager';
      case UserRole.administrator:
        return 'Administrator';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser ?? widget.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 45,
                child: Text(
                  user.name.isNotEmpty
                      ? user.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: nameController,
              textInputAction:
              TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon:
                Icon(Icons.person_outline),
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
                labelText: 'Phone',
                prefixIcon:
                Icon(Icons.phone_outlined),
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: TextEditingController(
                text: user.email,
              ),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon:
                Icon(Icons.email_outlined),
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isSaving
                    ? null
                    : saveProfile,
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
                      : 'Save Changes',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.badge_outlined,
                ),
                title: const Text('Role'),
                subtitle: Text(
                  roleText(user.role),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: Icon(
                  user.isActive
                      ? Icons.check_circle_outline
                      : Icons.block,
                ),
                title: const Text(
                  'Account Status',
                ),
                subtitle: Text(
                  user.isActive
                      ? 'Active'
                      : 'Inactive',
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