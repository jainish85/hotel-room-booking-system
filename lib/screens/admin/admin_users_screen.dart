import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({
    super.key,
  });

  @override
  State<AdminUsersScreen> createState() =>
      _AdminUsersScreenState();
}

class _AdminUsersScreenState
    extends State<AdminUsersScreen> {
  final UserService userService =
  UserService();

  final TextEditingController searchController =
  TextEditingController();

  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // ROLE TEXT
  // ==========================================================

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

  // ==========================================================
  // ROLE COLOR
  // ==========================================================

  Color roleColor(
      BuildContext context,
      UserRole role,
      ) {
    switch (role) {
      case UserRole.customer:
        return Theme.of(context)
            .colorScheme
            .primary;

      case UserRole.manager:
        return Colors.orange;

      case UserRole.administrator:
        return Colors.purple;
    }
  }

  // ==========================================================
  // FILTER USERS
  // ==========================================================

  List<UserModel> filterUsers(
      List<UserModel> users,
      ) {
    final query =
    searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return users;
    }

    return users.where((user) {
      return user.name
          .toLowerCase()
          .contains(query) ||
          user.email
              .toLowerCase()
              .contains(query) ||
          user.phone.contains(query) ||
          roleText(user.role)
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  // ==========================================================
  // ADD USER
  // ==========================================================

  Future<void> addUser() async {
    final newUser =
    await showDialog<_NewUserData>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const _AddUserDialog();
      },
    );

    if (newUser == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final role = newUser.role;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Creating user...',
        ),
      ),
    );

    try {
      await userService.createUser(
        name: newUser.name,
        email: newUser.email,
        phone: newUser.phone,
        password: newUser.password,
        role: role,
      );

      if (!mounted) {
        return;
      }

      showMessage(
        '${roleText(role)} created successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      showMessage(
        'Unable to create user: $e',
      );
    }
  }

  // ==========================================================
  // EDIT USER
  //
  // Editable:
  // - Name
  // - Phone
  // - Role
  //
  // NOT editable:
  // - Email
  // - Password
  // - Firebase UID
  // ==========================================================

  Future<void> editUser(
      UserModel user,
      ) async {
    if (user.role ==
        UserRole.administrator) {
      showMessage(
        'Administrator cannot be edited.',
      );
      return;
    }

    final nameController =
    TextEditingController(
      text: user.name,
    );

    final phoneController =
    TextEditingController(
      text: user.phone,
    );

    UserRole selectedRole =
        user.role;

    final formKey =
    GlobalKey<FormState>();

    final saved =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              title: const Text(
                'Edit User',
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller:
                        nameController,
                        textCapitalization:
                        TextCapitalization
                            .words,
                        decoration:
                        const InputDecoration(
                          labelText: 'Name',
                          prefixIcon:
                          Icon(
                            Icons
                                .person_outline,
                          ),
                          border:
                          OutlineInputBorder(),
                        ),
                        validator:
                            (value) {
                          if (value ==
                              null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'Enter name';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      TextFormField(
                        controller:
                        phoneController,
                        keyboardType:
                        TextInputType.phone,
                        decoration:
                        const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon:
                          Icon(
                            Icons
                                .phone_outlined,
                          ),
                          border:
                          OutlineInputBorder(),
                        ),
                        validator:
                            (value) {
                          if (value ==
                              null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'Enter phone';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      DropdownButtonFormField<
                          UserRole>(
                        initialValue:
                        selectedRole,
                        decoration:
                        const InputDecoration(
                          labelText: 'Role',
                          prefixIcon:
                          Icon(
                            Icons
                                .badge_outlined,
                          ),
                          border:
                          OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value:
                            UserRole.customer,
                            child:
                            Text(
                              'Customer',
                            ),
                          ),
                          DropdownMenuItem(
                            value:
                            UserRole.manager,
                            child:
                            Text(
                              'Manager',
                            ),
                          ),
                        ],
                        onChanged:
                            (value) {
                          if (value ==
                              null) {
                            return;
                          }

                          setDialogState(
                                () {
                              selectedRole =
                                  value;
                            },
                          );
                        },
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Container(
                        width:
                        double.infinity,
                        padding:
                        const EdgeInsets
                            .all(
                          12,
                        ),
                        decoration:
                        BoxDecoration(
                          border: Border.all(
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .outline,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            8,
                          ),
                        ),
                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            const Text(
                              'Authentication Information',
                              style:
                              TextStyle(
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              'Email: ${user.email}',
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            const Text(
                              'Email and password cannot be changed here.',
                              style:
                              TextStyle(
                                fontSize:
                                12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(false);
                  },
                  child:
                  const Text(
                    'Cancel',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey
                        .currentState!
                        .validate()) {
                      return;
                    }

                    Navigator.of(
                      dialogContext,
                    ).pop(true);
                  },
                  child:
                  const Text(
                    'Save Changes',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true) {
      nameController.dispose();
      phoneController.dispose();
      return;
    }

    try {
      await userService.updateUserByAdmin(
        userId: user.id,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        role: selectedRole,
      );

      if (!mounted) {
        return;
      }

      showMessage(
        '${user.name} updated successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      showMessage(
        'Unable to update user: $e',
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
    }
  }

  // ==========================================================
  // CHANGE ROLE
  // ==========================================================

  Future<void> changeRole(
      UserModel user,
      ) async {
    if (user.role ==
        UserRole.administrator) {
      showMessage(
        'Administrator role cannot be changed.',
      );
      return;
    }

    final selectedRole =
    await showDialog<UserRole>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text(
            'Change User Role',
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  UserRole.customer,
                );
              },
              child: const Text(
                'Customer',
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(
                  UserRole.manager,
                );
              },
              child: const Text(
                'Manager',
              ),
            ),
          ],
        );
      },
    );

    if (selectedRole == null ||
        selectedRole == user.role) {
      return;
    }

    try {
      await userService.updateUserRole(
        userId: user.id,
        role: selectedRole,
      );

      if (!mounted) {
        return;
      }

      showMessage(
        '${user.name} is now a ${roleText(selectedRole)}.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      showMessage(
        'Unable to change user role: $e',
      );
    }
  }

  // ==========================================================
  // ACTIVATE / DEACTIVATE
  // ==========================================================

  Future<void> toggleUserStatus(
      UserModel user,
      ) async {
    if (user.role ==
        UserRole.administrator) {
      showMessage(
        'Administrator status cannot be changed.',
      );
      return;
    }

    final willActivate =
    !user.isActive;

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            willActivate
                ? 'Activate User'
                : 'Deactivate User',
          ),
          content: Text(
            willActivate
                ? 'Do you want to activate ${user.name}?'
                : 'Do you want to deactivate ${user.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
              const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child:
              Text(
                willActivate
                    ? 'Activate'
                    : 'Deactivate',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await userService.updateUserStatus(
        userId: user.id,
        isActive: willActivate,
      );

      if (!mounted) {
        return;
      }

      showMessage(
        willActivate
            ? '${user.name} activated successfully.'
            : '${user.name} deactivated successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      showMessage(
        'Unable to update user status: $e',
      );
    }
  }

  // ==========================================================
  // PERMANENT DELETE
  // ==========================================================

  Future<void> permanentlyDeleteUser(
      UserModel user,
      ) async {
    if (user.role ==
        UserRole.administrator) {
      showMessage(
        'Administrator cannot be deleted.',
      );
      return;
    }

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete User Permanently',
          ),
          content: Text(
            'Are you sure you want to permanently delete '
                '${user.name}?\n\n'
                'This will remove:\n'
                '• Firebase Authentication account\n'
                '• User profile\n'
                '• User-related bookings\n'
                '• User-related service requests\n'
                '• User-related customer requests\n\n'
                'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
              const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.red,
                foregroundColor:
                Colors.white,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child:
              const Text(
                'Delete Permanently',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Deleting user...',
        ),
      ),
    );

    try {
      await userService
          .deleteUserPermanently(
        user.id,
      );

      if (!mounted) {
        return;
      }

      showMessage(
        '${user.name} deleted permanently.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      showMessage(
        'Unable to delete user: $e',
      );
    }
  }

  // ==========================================================
  // USER DETAILS
  // ==========================================================

  void showUserDetails(
      UserModel user,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'User Details',
          ),
          content:
          SingleChildScrollView(
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                _detailRow(
                  'Name',
                  user.name,
                ),
                _detailRow(
                  'Email',
                  user.email,
                ),
                _detailRow(
                  'Phone',
                  user.phone,
                ),
                _detailRow(
                  'Role',
                  roleText(user.role),
                ),
                _detailRow(
                  'Status',
                  user.isActive
                      ? 'Active'
                      : 'Inactive',
                ),
                _detailRow(
                  'User ID',
                  user.id,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child:
              const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
            const TextStyle(
              fontWeight:
              FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          SelectableText(
            value,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // USER ACTIONS
  // ==========================================================

  void showUserActions(
      UserModel user,
      ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              // VIEW DETAILS
              ListTile(
                leading:
                const Icon(
                  Icons.info_outline,
                ),
                title:
                const Text(
                  'View Details',
                ),
                onTap: () {
                  Navigator.of(
                    sheetContext,
                  ).pop();

                  showUserDetails(
                    user,
                  );
                },
              ),

              // EDIT USER
              if (user.role !=
                  UserRole.administrator)
                ListTile(
                  leading:
                  const Icon(
                    Icons.edit_outlined,
                  ),
                  title:
                  const Text(
                    'Edit User',
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    editUser(
                      user,
                    );
                  },
                ),

              // CHANGE ROLE
              if (user.role !=
                  UserRole.administrator)
                ListTile(
                  leading:
                  const Icon(
                    Icons
                        .badge_outlined,
                  ),
                  title:
                  const Text(
                    'Change Role',
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    changeRole(
                      user,
                    );
                  },
                ),

              // ACTIVATE / DEACTIVATE
              if (user.role !=
                  UserRole.administrator)
                ListTile(
                  leading:
                  Icon(
                    user.isActive
                        ? Icons
                        .visibility_off_outlined
                        : Icons
                        .visibility_outlined,
                  ),
                  title: Text(
                    user.isActive
                        ? 'Deactivate'
                        : 'Activate',
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    toggleUserStatus(
                      user,
                    );
                  },
                ),

              // PERMANENT DELETE
              if (user.role !=
                  UserRole.administrator)
                ListTile(
                  leading:
                  const Icon(
                    Icons
                        .delete_forever_outlined,
                    color:
                    Colors.red,
                  ),
                  title:
                  const Text(
                    'Delete Permanently',
                    style:
                    TextStyle(
                      color:
                      Colors.red,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    permanentlyDeleteUser(
                      user,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void showMessage(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }

  // ==========================================================
  // SUMMARY CARD
  // ==========================================================

  Widget buildSummaryCard(
      BuildContext context,
      String title,
      int count,
      IconData icon,
      ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding:
          const EdgeInsets.all(
            12,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 26,
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                count.toString(),
                style:
                const TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                title,
                textAlign:
                TextAlign.center,
                style:
                const TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Management',
        ),
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: addUser,
        icon: const Icon(
          Icons.person_add,
        ),
        label: const Text(
          'Add User',
        ),
      ),

      body: StreamBuilder<
          List<UserModel>>(
        stream:
        userService.watchAllUsers(),
        builder: (
            context,
            snapshot,
            ) {
          if (snapshot
              .connectionState ==
              ConnectionState
                  .waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  20,
                ),
                child: Text(
                  'Unable to load users.\n\n${snapshot.error}',
                  textAlign:
                  TextAlign.center,
                ),
              ),
            );
          }

          final allUsers =
              snapshot.data ?? [];

          final users =
          filterUsers(
            allUsers,
          );

          final customers =
              allUsers
                  .where(
                    (user) =>
                user.role ==
                    UserRole
                        .customer,
              )
                  .length;

          final managers =
              allUsers
                  .where(
                    (user) =>
                user.role ==
                    UserRole.manager,
              )
                  .length;

          final active =
              allUsers
                  .where(
                    (user) =>
                user.isActive,
              )
                  .length;

          return Column(
            children: [
              Padding(
                padding:
                const EdgeInsets
                    .fromLTRB(
                  16,
                  16,
                  16,
                  8,
                ),
                child: Row(
                  children: [
                    buildSummaryCard(
                      context,
                      'Customers',
                      customers,
                      Icons
                          .people_outline,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    buildSummaryCard(
                      context,
                      'Managers',
                      managers,
                      Icons
                          .manage_accounts_outlined,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    buildSummaryCard(
                      context,
                      'Active',
                      active,
                      Icons
                          .check_circle_outline,
                    ),
                  ],
                ),
              ),

              Padding(
                padding:
                const EdgeInsets.all(
                  16,
                ),
                child: TextField(
                  controller:
                  searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery =
                          value;
                    });
                  },
                  decoration:
                  InputDecoration(
                    hintText:
                    'Search name, email, phone or role...',
                    prefixIcon:
                    const Icon(
                      Icons.search,
                    ),
                    suffixIcon:
                    searchQuery
                        .isNotEmpty
                        ? IconButton(
                      onPressed:
                          () {
                        searchController
                            .clear();

                        setState(
                              () {
                            searchQuery =
                            '';
                          },
                        );
                      },
                      icon:
                      const Icon(
                        Icons.clear,
                      ),
                    )
                        : null,
                    border:
                    const OutlineInputBorder(),
                  ),
                ),
              ),

              Expanded(
                child:
                users.isEmpty
                    ? const Center(
                  child:
                  Column(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                    children: [
                      Icon(
                        Icons
                            .people_outline,
                        size: 70,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        'No users found.',
                        style:
                        TextStyle(
                          fontSize:
                          20,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Use Add User to create a Customer or Manager.',
                        textAlign:
                        TextAlign
                            .center,
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding:
                  const EdgeInsets
                      .fromLTRB(
                    16,
                    0,
                    16,
                    100,
                  ),
                  itemCount:
                  users.length,
                  itemBuilder:
                      (
                      context,
                      index,
                      ) {
                    final user =
                    users[index];

                    final color =
                    roleColor(
                      context,
                      user.role,
                    );

                    return Card(
                      margin:
                      const EdgeInsets
                          .only(
                        bottom: 12,
                      ),
                      child:
                      ListTile(
                        contentPadding:
                        const EdgeInsets
                            .all(
                          14,
                        ),
                        leading:
                        CircleAvatar(
                          child:
                          Text(
                            user.name
                                .trim()
                                .isNotEmpty
                                ? user
                                .name
                                .trim()
                                .substring(
                              0,
                              1,
                            )
                                .toUpperCase()
                                : '?',
                          ),
                        ),
                        title:
                        Text(
                          user.name
                              .isEmpty
                              ? 'Unnamed User'
                              : user.name,
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                        subtitle:
                        Padding(
                          padding:
                          const EdgeInsets
                              .only(
                            top: 6,
                          ),
                          child:
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                user
                                    .email,
                              ),
                              const SizedBox(
                                height:
                                4,
                              ),
                              Text(
                                user
                                    .phone,
                              ),
                              const SizedBox(
                                height:
                                8,
                              ),
                              Wrap(
                                spacing:
                                8,
                                runSpacing:
                                6,
                                children: [
                                  _statusChip(
                                    roleText(
                                      user
                                          .role,
                                    ),
                                    color,
                                  ),
                                  _statusChip(
                                    user.isActive
                                        ? 'Active'
                                        : 'Inactive',
                                    user.isActive
                                        ? Colors
                                        .green
                                        : Colors
                                        .red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing:
                        IconButton(
                          icon:
                          const Icon(
                            Icons
                                .more_vert,
                          ),
                          onPressed:
                              () {
                            showUserActions(
                              user,
                            );
                          },
                        ),
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

  // ==========================================================
  // STATUS CHIP
  // ==========================================================

  Widget _statusChip(
      String text,
      Color color,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration:
      BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }
}


// ============================================================
// ADD USER DIALOG
// ============================================================

class _AddUserDialog
    extends StatefulWidget {
  const _AddUserDialog();

  @override
  State<_AddUserDialog> createState() =>
      _AddUserDialogState();
}

class _AddUserDialogState
    extends State<_AddUserDialog> {
  final GlobalKey<FormState>
  formKey =
  GlobalKey<FormState>();

  final TextEditingController
  nameController =
  TextEditingController();

  final TextEditingController
  emailController =
  TextEditingController();

  final TextEditingController
  phoneController =
  TextEditingController();

  final TextEditingController
  passwordController =
  TextEditingController();

  UserRole selectedRole =
      UserRole.customer;

  bool obscurePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void submit() {
    if (!formKey.currentState!
        .validate()) {
      return;
    }

    final data =
    _NewUserData(
      name:
      nameController.text.trim(),
      email: emailController.text
          .trim()
          .toLowerCase(),
      phone:
      phoneController.text.trim(),
      password:
      passwordController.text,
      role: selectedRole,
    );

    Navigator.of(context).pop(
      data,
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return AlertDialog(
      title: const Text(
        'Add User',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                TextFormField(
                  controller:
                  nameController,
                  textCapitalization:
                  TextCapitalization
                      .words,
                  decoration:
                  const InputDecoration(
                    labelText: 'Name',
                    prefixIcon:
                    Icon(
                      Icons
                          .person_outline,
                    ),
                    border:
                    OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Enter name';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                TextFormField(
                  controller:
                  emailController,
                  keyboardType:
                  TextInputType
                      .emailAddress,
                  decoration:
                  const InputDecoration(
                    labelText: 'Email',
                    prefixIcon:
                    Icon(
                      Icons.email_outlined,
                    ),
                    border:
                    OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final email =
                        value?.trim() ??
                            '';

                    if (email.isEmpty) {
                      return 'Enter email';
                    }

                    if (!email.contains(
                      '@',
                    ) ||
                        !email.contains(
                          '.',
                        )) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                TextFormField(
                  controller:
                  phoneController,
                  keyboardType:
                  TextInputType.phone,
                  decoration:
                  const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon:
                    Icon(
                      Icons.phone_outlined,
                    ),
                    border:
                    OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final phone =
                        value?.trim() ??
                            '';

                    if (phone.isEmpty) {
                      return 'Enter phone number';
                    }

                    if (phone.length <
                        10) {
                      return 'Enter a valid phone number';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                TextFormField(
                  controller:
                  passwordController,
                  obscureText:
                  obscurePassword,
                  decoration:
                  InputDecoration(
                    labelText:
                    'Password',
                    prefixIcon:
                    const Icon(
                      Icons.lock_outline,
                    ),
                    suffixIcon:
                    IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword =
                          !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons
                            .visibility_off
                            : Icons
                            .visibility,
                      ),
                    ),
                    border:
                    const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final password =
                        value ?? '';

                    if (password.isEmpty) {
                      return 'Enter password';
                    }

                    if (password.length <
                        6) {
                      return 'Minimum 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 14,
                ),

                DropdownButtonFormField<
                    UserRole>(
                  initialValue:
                  selectedRole,
                  decoration:
                  const InputDecoration(
                    labelText: 'Role',
                    prefixIcon:
                    Icon(
                      Icons
                          .badge_outlined,
                    ),
                    border:
                    OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value:
                      UserRole
                          .customer,
                      child: Text(
                        'Customer',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                      UserRole
                          .manager,
                      child: Text(
                        'Manager',
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedRole =
                          value;
                    });
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                const Align(
                  alignment:
                  Alignment.centerLeft,
                  child: Text(
                    'Administrator accounts are not created here.',
                    style:
                    TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop();
          },
          child: const Text(
            'Cancel',
          ),
        ),
        ElevatedButton(
          onPressed: submit,
          child: const Text(
            'Create User',
          ),
        ),
      ],
    );
  }
}


// ============================================================
// NEW USER DATA
// ============================================================

class _NewUserData {
  final String name;
  final String email;
  final String phone;
  final String password;
  final UserRole role;

  const _NewUserData({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
  });
}