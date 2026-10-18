import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';

class ManagerCustomersScreen extends StatefulWidget {
  const ManagerCustomersScreen({
    super.key,
  });

  @override
  State<ManagerCustomersScreen> createState() =>
      _ManagerCustomersScreenState();
}

class _ManagerCustomersScreenState
    extends State<ManagerCustomersScreen> {
  final UserService userService = UserService();

  final TextEditingController searchController =
  TextEditingController();

  String searchText = '';

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {
        searchText =
            searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showCustomerDetails(
      BuildContext context,
      UserModel customer,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Customer Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer ID: ${customer.id}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Name: ${customer.name}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Email: ${customer.email}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Phone: ${customer.phone}',
                ),
                const SizedBox(height: 10),
                Text(
                  'Status: ${customer.isActive ? 'Active' : 'Inactive'}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: userService.watchAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load customers.',
              ),
            );
          }

          final customers = (snapshot.data ?? [])
              .where(
                (user) =>
            user.role == UserRole.customer,
          )
              .where(
                (user) {
              if (searchText.isEmpty) {
                return true;
              }

              return user.name
                  .toLowerCase()
                  .contains(searchText) ||
                  user.email
                      .toLowerCase()
                      .contains(searchText) ||
                  user.phone
                      .toLowerCase()
                      .contains(searchText);
            },
          )
              .toList();

          return Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    prefixIcon:
                    Icon(Icons.search),
                    labelText: 'Search customers',
                    hintText:
                    'Name, email or phone',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(
                      Icons.filter_alt_outlined,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: customers.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 70,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'No customers found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.separated(
                  padding:
                  const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16,
                  ),
                  itemCount: customers.length,
                  separatorBuilder:
                      (_, _) =>
                  const SizedBox(
                    height: 10,
                  ),
                  itemBuilder:
                      (context, index) {
                    final customer =
                    customers[index];

                    return Card(
                      child: ListTile(
                        leading:
                        CircleAvatar(
                          child: Text(
                            customer.name
                                .isNotEmpty
                                ? customer
                                .name[0]
                                .toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(
                          customer.name.isEmpty
                              ? 'Unnamed Customer'
                              : customer.name,
                        ),
                        subtitle: Text(
                          '${customer.email}\n${customer.phone}',
                        ),
                        isThreeLine: true,
                        trailing: Icon(
                          customer.isActive
                              ? Icons
                              .check_circle_outline
                              : Icons.block,
                          color:
                          customer.isActive
                              ? Colors.green
                              : Colors.red,
                        ),
                        onTap: () {
                          showCustomerDetails(
                            context,
                            customer,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}