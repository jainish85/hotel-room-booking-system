import 'package:flutter/material.dart';

import '../../models/room_model.dart';
import '../../services/room_service.dart';

enum RoomViewFilter {
  all,
  active,
  inactive,
}

class ManagerRoomsScreen extends StatefulWidget {
  const ManagerRoomsScreen({
    super.key,
  });

  @override
  State<ManagerRoomsScreen> createState() =>
      _ManagerRoomsScreenState();
}

class _ManagerRoomsScreenState
    extends State<ManagerRoomsScreen> {
  final RoomService roomService =
  RoomService();

  RoomViewFilter selectedFilter =
      RoomViewFilter.all;

  // ============================================================
  // NORMALIZE ROOM TYPE
  // ============================================================

  String normalizeRoomType(
      String? roomType,
      ) {
    switch (roomType) {
      case 'Single':
      case 'Single Room':
        return 'Single';

      case 'Double':
      case 'Double Room':
        return 'Double';

      case 'Deluxe':
      case 'Deluxe Room':
        return 'Deluxe';

      case 'Suite':
      case 'Suite Room':
        return 'Suite';

      default:
        return 'Single';
    }
  }

  // ============================================================
  // FILTER ROOMS
  // ============================================================

  List<RoomModel> filterRooms(
      List<RoomModel> rooms,
      ) {
    switch (selectedFilter) {
      case RoomViewFilter.all:
        return rooms;

      case RoomViewFilter.active:
        return rooms
            .where(
              (room) => room.isActive,
        )
            .toList();

      case RoomViewFilter.inactive:
        return rooms
            .where(
              (room) => !room.isActive,
        )
            .toList();
    }
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

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

  // ============================================================
  // ADD / EDIT ROOM
  // ============================================================

  Future<void> showRoomForm({
    RoomModel? room,
  }) async {
    // Save the screen context before opening the dialog.
    // This prevents using the dialog's context after it is closed.
    final pageContext = context;

    final roomNumberController =
    TextEditingController(
      text: room?.roomNumber ?? '',
    );

    final roomNameController =
    TextEditingController(
      text: room?.roomName ?? '',
    );

    final priceController =
    TextEditingController(
      text:
      room?.price.toStringAsFixed(0) ?? '',
    );

    final capacityController =
    TextEditingController(
      text:
      room?.capacity.toString() ?? '',
    );

    final descriptionController =
    TextEditingController(
      text:
      room?.description ?? '',
    );

    final facilitiesController =
    TextEditingController(
      text:
      room?.facilities.join(', ') ?? '',
    );

    final imageUrlController =
    TextEditingController(
      text:
      room?.imageUrl ?? '',
    );

    final ratingController =
    TextEditingController(
      text:
      room?.rating.toString() ?? '',
    );

    String selectedRoomType =
    normalizeRoomType(
      room?.roomType,
    );

    RoomStatus selectedStatus =
        room?.status ??
            RoomStatus.available;

    bool selectedHasParking =
        room?.hasParking ?? false;

    bool isSaving = false;

    final formKey =
    GlobalKey<FormState>();

    await showDialog(
      context: pageContext,
      barrierDismissible: !isSaving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              dialogBuilderContext,
              setDialogState,
              ) {
            return AlertDialog(
              title: Text(
                room == null
                    ? 'Add Room'
                    : 'Edit Room',
              ),

              content: SizedBox(
                width: double.maxFinite,
                child:
                SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        // ==================================================
                        // ROOM NUMBER
                        // ==================================================

                        TextFormField(
                          controller:
                          roomNumberController,
                          enabled: !isSaving,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Room Number',
                            prefixIcon:
                            Icon(
                              Icons
                                  .door_front_door,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (
                              value,
                              ) {
                            if (value ==
                                null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Enter room number';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // ==================================================
                        // ROOM TYPE
                        // ==================================================

                        DropdownButtonFormField<
                            String>(
                          initialValue:
                          selectedRoomType,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Room Type',
                            prefixIcon:
                            Icon(
                              Icons.category,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem<
                                String>(
                              value:
                              'Single',
                              child:
                              Text(
                                'Single',
                              ),
                            ),
                            DropdownMenuItem<
                                String>(
                              value:
                              'Double',
                              child:
                              Text(
                                'Double',
                              ),
                            ),
                            DropdownMenuItem<
                                String>(
                              value:
                              'Deluxe',
                              child:
                              Text(
                                'Deluxe',
                              ),
                            ),
                            DropdownMenuItem<
                                String>(
                              value:
                              'Suite',
                              child:
                              Text(
                                'Suite',
                              ),
                            ),
                          ],
                          onChanged:
                          isSaving
                              ? null
                              : (
                              value,
                              ) {
                            if (value ==
                                null) {
                              return;
                            }

                            setDialogState(
                                  () {
                                selectedRoomType =
                                    value;
                              },
                            );
                          },
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // ==================================================
                        // ROOM NAME
                        // ==================================================

                        TextFormField(
                          controller:
                          roomNameController,
                          enabled: !isSaving,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Room Name',
                            hintText:
                            'Example: Deluxe Room',
                            prefixIcon:
                            Icon(
                              Icons.hotel,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (
                              value,
                              ) {
                            if (value ==
                                null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Enter room name';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // ==================================================
                        // PRICE
                        // ==================================================

                        TextFormField(
                          controller:
                          priceController,
                          enabled: !isSaving,
                          keyboardType:
                          const TextInputType
                              .numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Price Per Night',
                            prefixText:
                            '₹ ',
                            prefixIcon:
                            Icon(
                              Icons
                                  .currency_rupee,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (
                              value,
                              ) {
                            final price =
                            double.tryParse(
                              value
                                  ?.trim() ??
                                  '',
                            );

                            if (price ==
                                null ||
                                price <=
                                    0) {
                              return 'Enter valid price';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // ==================================================
                        // CAPACITY
                        // ==================================================

                        TextFormField(
                          controller:
                          capacityController,
                          enabled: !isSaving,
                          keyboardType:
                          TextInputType.number,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Guest Capacity',
                            prefixIcon:
                            Icon(
                              Icons.people,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (
                              value,
                              ) {
                            final capacity =
                            int.tryParse(
                              value
                                  ?.trim() ??
                                  '',
                            );

                            if (capacity ==
                                null ||
                                capacity <=
                                    0) {
                              return 'Enter valid capacity';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // ==================================================
                        // DESCRIPTION
                        // ==================================================

                        TextFormField(
                          controller:
                          descriptionController,
                          enabled: !isSaving,
                          maxLines: 3,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Description',
                            prefixIcon:
                            Icon(
                              Icons
                                  .description,
                            ),
                            border:
                            OutlineInputBorder(),
                            alignLabelWithHint:
                            true,
                          ),
                          validator: (
                              value,
                              ) {
                            if (value ==
                                null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Enter description';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // ==================================================
                        // FACILITIES
                        // ==================================================

                        TextFormField(
                          controller:
                          facilitiesController,
                          enabled: !isSaving,
                          maxLines: 3,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Facilities',
                            hintText:
                            'WiFi, AC, TV, Bathroom',
                            prefixIcon:
                            Icon(
                              Icons.checklist,
                            ),
                            border:
                            OutlineInputBorder(),
                            alignLabelWithHint:
                            true,
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // ==================================================
                        // PARKING
                        // ==================================================

                        SwitchListTile(
                          contentPadding:
                          EdgeInsets.zero,
                          title:
                          const Text(
                            'Parking Available',
                            style:
                            TextStyle(
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                          subtitle:
                          const Text(
                            'Customers can filter rooms with parking.',
                          ),
                          value:
                          selectedHasParking,
                          onChanged:
                          isSaving
                              ? null
                              : (
                              value,
                              ) {
                            setDialogState(
                                  () {
                                selectedHasParking =
                                    value;
                              },
                            );
                          },
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        // ==================================================
                        // RATING
                        // ==================================================

                        TextFormField(
                          controller:
                          ratingController,
                          enabled: !isSaving,
                          keyboardType:
                          const TextInputType
                              .numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Rating',
                            hintText:
                            'Example: 4.5',
                            prefixIcon:
                            Icon(
                              Icons.star,
                            ),
                            suffixText:
                            '/ 5',
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (
                              value,
                              ) {
                            final text =
                                value
                                    ?.trim() ??
                                    '';

                            if (text.isEmpty) {
                              return 'Enter rating';
                            }

                            final rating =
                            double.tryParse(
                              text,
                            );

                            if (rating ==
                                null ||
                                rating < 0 ||
                                rating > 5) {
                              return 'Enter rating from 0 to 5';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // ==================================================
                        // IMAGE URL
                        // ==================================================

                        TextFormField(
                          controller:
                          imageUrlController,
                          enabled: !isSaving,
                          keyboardType:
                          TextInputType.url,
                          maxLines: 2,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Room Image URL',
                            hintText:
                            'Paste real room image URL',
                            prefixIcon:
                            Icon(
                              Icons
                                  .image_outlined,
                            ),
                            border:
                            OutlineInputBorder(),
                            alignLabelWithHint:
                            true,
                          ),
                        ),

                        // ==================================================
                        // ROOM STATUS
                        // ==================================================

                        if (room !=
                            null) ...[
                          const SizedBox(
                            height: 12,
                          ),

                          DropdownButtonFormField<
                              RoomStatus>(
                            initialValue:
                            selectedStatus,
                            decoration:
                            const InputDecoration(
                              labelText:
                              'Room Status',
                              prefixIcon:
                              Icon(
                                Icons
                                    .info_outline,
                              ),
                              border:
                              OutlineInputBorder(),
                            ),
                            items:
                            RoomStatus
                                .values
                                .map(
                                  (
                                  status,
                                  ) {
                                return DropdownMenuItem<
                                    RoomStatus>(
                                  value:
                                  status,
                                  child:
                                  Text(
                                    statusText(
                                      status,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged:
                            isSaving
                                ? null
                                : (
                                value,
                                ) {
                              if (value ==
                                  null) {
                                return;
                              }

                              setDialogState(
                                    () {
                                  selectedStatus =
                                      value;
                                },
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // ============================================================
              // FORM ACTIONS
              // ============================================================

              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child:
                  const Text(
                    'Cancel',
                  ),
                ),

                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                    if (!formKey
                        .currentState!
                        .validate()) {
                      return;
                    }

                    final facilities =
                    facilitiesController
                        .text
                        .split(',')
                        .map(
                          (
                          item,
                          ) =>
                          item
                              .trim(),
                    )
                        .where(
                          (
                          item,
                          ) =>
                      item
                          .isNotEmpty,
                    )
                        .toList();

                    final price =
                    double.parse(
                      priceController
                          .text
                          .trim(),
                    );

                    final capacity =
                    int.parse(
                      capacityController
                          .text
                          .trim(),
                    );

                    final rating =
                    double.parse(
                      ratingController
                          .text
                          .trim(),
                    );

                    final roomModel =
                    RoomModel(
                      id: room?.id ??
                          DateTime
                              .now()
                              .millisecondsSinceEpoch
                              .toString(),
                      roomNumber:
                      roomNumberController
                          .text
                          .trim(),
                      roomType:
                      selectedRoomType,
                      roomName:
                      roomNameController
                          .text
                          .trim(),
                      price:
                      price,
                      capacity:
                      capacity,
                      description:
                      descriptionController
                          .text
                          .trim(),
                      facilities:
                      facilities,
                      imageUrl:
                      imageUrlController
                          .text
                          .trim(),
                      status:
                      selectedStatus,
                      isActive:
                      room?.isActive ??
                          true,
                      hasParking:
                      selectedHasParking,
                      rating:
                      rating,
                    );

                    setDialogState(
                          () {
                        isSaving =
                        true;
                      },
                    );

                    try {
                      if (room == null) {
                        await roomService
                            .addRoom(
                          roomModel,
                        );
                      } else {
                        await roomService
                            .updateRoom(
                          roomModel,
                        );
                      }

                      if (!dialogContext
                          .mounted) {
                        return;
                      }

                      Navigator.of(
                        dialogContext,
                      ).pop();

                      if (!mounted) {
                        return;
                      }

                      showMessage(
                        room == null
                            ? 'Room added successfully.'
                            : 'Room updated successfully.',
                      );
                    } catch (e) {
                      if (!dialogContext
                          .mounted) {
                        return;
                      }

                      setDialogState(
                            () {
                          isSaving =
                          false;
                        },
                      );

                      if (!pageContext
                          .mounted) {
                        return;
                      }

                      ScaffoldMessenger
                          .of(
                        pageContext,
                      ).showSnackBar(
                        SnackBar(
                          content:
                          Text(
                            'Unable to save room: $e',
                          ),
                        ),
                      );
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    room == null
                        ? 'Add Room'
                        : 'Save Changes',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // IMPORTANT:
    // Do NOT manually dispose these controllers here.
    //
    // Disposing them immediately after showDialog() can cause
    // Flutter dialog/widget lifecycle errors such as:
    // '_dependents.isEmpty': is not true.
  }

  // ============================================================
  // ACTIVATE / DEACTIVATE ROOM
  // ============================================================

  Future<void> changeRoomActiveStatus(
      RoomModel room,
      ) async {
    final willActivate =
    !room.isActive;

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            willActivate
                ? 'Activate Room'
                : 'Deactivate Room',
          ),
          content: Text(
            willActivate
                ? 'Do you want to activate Room ${room.roomNumber}?'
                : 'Do you want to deactivate Room ${room.roomNumber}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
              const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: Text(
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
      if (willActivate) {
        await roomService.activateRoom(
          room.id,
        );
      } else {
        await roomService.deactivateRoom(
          room.id,
        );
      }

      if (!mounted) {
        return;
      }

      showMessage(
        willActivate
            ? 'Room ${room.roomNumber} activated successfully.'
            : 'Room ${room.roomNumber} deactivated successfully.',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      showMessage(
        'Unable to update room status: $e',
      );
    }
  }

  // ============================================================
  // ROOM STATUS TEXT
  // ============================================================

  static String statusText(
      RoomStatus status,
      ) {
    switch (status) {
      case RoomStatus.available:
        return 'Available';

      case RoomStatus.booked:
        return 'Booked';

      case RoomStatus.occupied:
        return 'Occupied';

      case RoomStatus.cleaning:
        return 'Cleaning';

      case RoomStatus.maintenance:
        return 'Maintenance';
    }
  }

  // ============================================================
  // FILTER CHIP
  // ============================================================

  Widget buildFilterChip(
      String label,
      RoomViewFilter filter,
      ) {
    return FilterChip(
      label: Text(
        label,
      ),
      selected:
      selectedFilter == filter,
      onSelected: (_) {
        setState(() {
          selectedFilter =
              filter;
        });
      },
    );
  }

  // ============================================================
  // ROOM CARD
  // ============================================================

  Widget buildRoomCard(
      RoomModel room,
      ) {
    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.all(
          16,
        ),

        // ==========================================================
        // IMAGE
        // ==========================================================

        leading: room.imageUrl.isNotEmpty
            ? ClipRRect(
          borderRadius:
          BorderRadius.circular(
            8,
          ),
          child:
          Image.network(
            room.imageUrl,
            width: 60,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (
                context,
                error,
                stackTrace,
                ) {
              return const SizedBox(
                width: 60,
                height: 70,
                child: Icon(
                  Icons.hotel,
                  size: 42,
                ),
              );
            },
          ),
        )
            : const SizedBox(
          width: 60,
          height: 70,
          child: Icon(
            Icons.hotel,
            size: 42,
          ),
        ),

        // ==========================================================
        // TITLE
        // ==========================================================

        title: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                room.roomName,
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (!room.isActive)
              Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration:
                BoxDecoration(
                  color: Colors.red
                      .withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    20,
                  ),
                ),
                child:
                const Text(
                  'Inactive',
                  style:
                  TextStyle(
                    color: Colors.red,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),

        // ==========================================================
        // ROOM DETAILS
        // ==========================================================

        subtitle: Padding(
          padding:
          const EdgeInsets.only(
            top: 8,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Room ${room.roomNumber}',
              ),
              Text(
                'Type: ${room.roomType}',
              ),
              Text(
                '₹${room.price.toStringAsFixed(0)} / night',
              ),
              Text(
                'Capacity: ${room.capacity}',
              ),
              Text(
                'Status: ${statusText(room.status)}',
              ),
              const SizedBox(
                height: 6,
              ),

              // ====================================================
              // RATING + PARKING
              // ====================================================

              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (room.rating > 0)
                    _buildRoomInfoChip(
                      icon:
                      Icons.star,
                      label:
                      room.rating
                          .toStringAsFixed(
                        1,
                      ),
                    ),

                  _buildRoomInfoChip(
                    icon: room.hasParking
                        ? Icons
                        .local_parking
                        : Icons
                        .no_transfer,
                    label:
                    room.hasParking
                        ? 'Parking'
                        : 'No Parking',
                  ),
                ],
              ),
            ],
          ),
        ),

        // ==========================================================
        // MENU
        // ==========================================================

        trailing:
        PopupMenuButton<String>(
          onSelected:
              (value) {
            if (value ==
                'edit') {
              showRoomForm(
                room: room,
              );
            }

            if (value ==
                'active_status') {
              changeRoomActiveStatus(
                room,
              );
            }
          },
          itemBuilder:
              (context) {
            return [
              const PopupMenuItem<
                  String>(
                value: 'edit',
                child: Text(
                  'Edit Room',
                ),
              ),
              PopupMenuItem<
                  String>(
                value:
                'active_status',
                child: Text(
                  room.isActive
                      ? 'Deactivate Room'
                      : 'Activate Room',
                ),
              ),
            ];
          },
        ),
      ),
    );
  }

  // ============================================================
  // ROOM INFO CHIP
  // ============================================================

  Widget _buildRoomInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            label,
            style:
            const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text(
          'Room Management',
        ),
      ),

      // ==========================================================
      // ADD ROOM
      // ==========================================================

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed:
        showRoomForm,
        icon:
        const Icon(
          Icons.add,
        ),
        label:
        const Text(
          'Add Room',
        ),
      ),

      body:
      StreamBuilder<
          List<RoomModel>>(
        // Manager sees ALL rooms.
        stream:
        roomService
            .watchAllRooms(),

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
                  'Unable to load rooms.\n\n'
                      '${snapshot.error}',
                  textAlign:
                  TextAlign.center,
                ),
              ),
            );
          }

          final allRooms =
              snapshot.data ?? [];

          final rooms =
          filterRooms(
            allRooms,
          );

          final activeCount =
              allRooms
                  .where(
                    (room) =>
                room.isActive,
              )
                  .length;

          final inactiveCount =
              allRooms
                  .where(
                    (room) =>
                !room.isActive,
              )
                  .length;

          return Column(
            children: [
              // ==================================================
              // SUMMARY
              // ==================================================

              Padding(
                padding:
                const EdgeInsets
                    .fromLTRB(
                  16,
                  16,
                  16,
                  4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child:
                        Padding(
                          padding:
                          const EdgeInsets
                              .all(
                            12,
                          ),
                          child:
                          Column(
                            children: [
                              const Icon(
                                Icons.hotel,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                allRooms
                                    .length
                                    .toString(),
                                style:
                                const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                              const Text(
                                'All Rooms',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child: Card(
                        child:
                        Padding(
                          padding:
                          const EdgeInsets
                              .all(
                            12,
                          ),
                          child:
                          Column(
                            children: [
                              const Icon(
                                Icons
                                    .check_circle_outline,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                activeCount
                                    .toString(),
                                style:
                                const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                              const Text(
                                'Active',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child: Card(
                        child:
                        Padding(
                          padding:
                          const EdgeInsets
                              .all(
                            12,
                          ),
                          child:
                          Column(
                            children: [
                              const Icon(
                                Icons
                                    .cancel_outlined,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                inactiveCount
                                    .toString(),
                                style:
                                const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                              const Text(
                                'Inactive',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // FILTER BUTTONS
              // ==================================================

              Padding(
                padding:
                const EdgeInsets
                    .fromLTRB(
                  16,
                  8,
                  16,
                  8,
                ),
                child: Wrap(
                  spacing: 8,
                  children: [
                    buildFilterChip(
                      'All',
                      RoomViewFilter
                          .all,
                    ),
                    buildFilterChip(
                      'Active',
                      RoomViewFilter
                          .active,
                    ),
                    buildFilterChip(
                      'Inactive',
                      RoomViewFilter
                          .inactive,
                    ),
                  ],
                ),
              ),

              // ==================================================
              // ROOM LIST
              // ==================================================

              Expanded(
                child:
                rooms.isEmpty
                    ? const Center(
                  child:
                  Padding(
                    padding:
                    EdgeInsets
                        .all(
                      20,
                    ),
                    child:
                    Column(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                      children: [
                        Icon(
                          Icons
                              .hotel_outlined,
                          size: 70,
                        ),
                        SizedBox(
                          height:
                          16,
                        ),
                        Text(
                          'No rooms found.',
                          style:
                          TextStyle(
                            fontSize:
                            20,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : ListView.builder(
                  padding:
                  const EdgeInsets
                      .fromLTRB(
                    16,
                    8,
                    16,
                    90,
                  ),
                  itemCount:
                  rooms.length,
                  itemBuilder:
                      (
                      context,
                      index,
                      ) {
                    final room =
                    rooms[
                    index];

                    return buildRoomCard(
                      room,
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