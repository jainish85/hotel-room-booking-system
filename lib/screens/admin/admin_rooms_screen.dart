import 'package:flutter/material.dart';

import '../../models/room_model.dart';
import '../../services/room_service.dart';

class AdminRoomsScreen extends StatefulWidget {
  const AdminRoomsScreen({super.key});

  @override
  State<AdminRoomsScreen> createState() => _AdminRoomsScreenState();
}

class _AdminRoomsScreenState extends State<AdminRoomsScreen> {
  final RoomService roomService = RoomService();

  String normalizeRoomType(String? roomType) {
    switch (roomType) {
      case 'Single Room':
        return 'Single';

      case 'Double Room':
        return 'Double';

      case 'Deluxe Room':
        return 'Deluxe';

      case 'Suite Room':
        return 'Suite';

      case 'Single':
        return 'Single';

      case 'Double':
        return 'Double';

      case 'Deluxe':
        return 'Deluxe';

      case 'Suite':
        return 'Suite';

      default:
        return 'Single';
    }
  }

  Future<void> showRoomForm({RoomModel? room}) async {
    final roomNumberController = TextEditingController(
      text: room?.roomNumber ?? '',
    );

    final roomNameController = TextEditingController(
      text: room?.roomName ?? '',
    );

    final priceController = TextEditingController(
      text: room?.price.toStringAsFixed(0) ?? '',
    );

    final capacityController = TextEditingController(
      text: room?.capacity.toString() ?? '',
    );

    final descriptionController = TextEditingController(
      text: room?.description ?? '',
    );

    String selectedRoomType =
    normalizeRoomType(room?.roomType);

    RoomStatus selectedStatus =
        room?.status ?? RoomStatus.available;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                room == null ? 'Add Room' : 'Edit Room',
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: roomNumberController,
                          decoration:
                          const InputDecoration(
                            labelText: 'Room Number',
                            prefixIcon: Icon(
                              Icons.door_front_door,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter room number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: roomNameController,
                          decoration:
                          const InputDecoration(
                            labelText: 'Room Name',
                            prefixIcon:
                            Icon(Icons.hotel),
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter room name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          initialValue:
                          selectedRoomType,
                          decoration:
                          const InputDecoration(
                            labelText: 'Room Type',
                            prefixIcon:
                            Icon(Icons.category),
                            border:
                            OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Single',
                              child: Text('Single'),
                            ),
                            DropdownMenuItem(
                              value: 'Double',
                              child: Text('Double'),
                            ),
                            DropdownMenuItem(
                              value: 'Deluxe',
                              child: Text('Deluxe'),
                            ),
                            DropdownMenuItem(
                              value: 'Suite',
                              child: Text('Suite'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setDialogState(() {
                              selectedRoomType =
                                  value;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: priceController,
                          keyboardType:
                          TextInputType.number,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Price per Night',
                            prefixText: '₹ ',
                            prefixIcon: Icon(
                              Icons.currency_rupee,
                            ),
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final price =
                            double.tryParse(
                              value?.trim() ?? '',
                            );

                            if (price == null ||
                                price <= 0) {
                              return 'Enter a valid price';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller:
                          capacityController,
                          keyboardType:
                          TextInputType.number,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Guest Capacity',
                            prefixIcon:
                            Icon(Icons.people),
                            border:
                            OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final capacity =
                            int.tryParse(
                              value?.trim() ?? '',
                            );

                            if (capacity == null ||
                                capacity <= 0) {
                              return 'Enter valid capacity';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller:
                          descriptionController,
                          maxLines: 3,
                          decoration:
                          const InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(
                              Icons.description,
                            ),
                            border:
                            OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter description';
                            }

                            return null;
                          },
                        ),

                        if (room != null) ...[
                          const SizedBox(height: 12),

                          DropdownButtonFormField<RoomStatus>(
                            initialValue:
                            selectedStatus,
                            decoration:
                            const InputDecoration(
                              labelText: 'Room Status',
                              prefixIcon: Icon(
                                Icons.info_outline,
                              ),
                              border:
                              OutlineInputBorder(),
                            ),
                            items: RoomStatus.values.map(
                                  (status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    statusText(status),
                                  ),
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setDialogState(() {
                                selectedStatus =
                                    value;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!
                        .validate()) {
                      return;
                    }

                    final price = double.parse(
                      priceController.text.trim(),
                    );

                    final capacity = int.parse(
                      capacityController.text.trim(),
                    );

                    final roomModel = RoomModel(
                      id: room?.id ??
                          DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                      roomNumber:
                      roomNumberController
                          .text
                          .trim(),
                      roomType: selectedRoomType,
                      roomName:
                      roomNameController.text.trim(),
                      price: price,
                      capacity: capacity,
                      description:
                      descriptionController
                          .text
                          .trim(),
                      facilities:
                      room?.facilities ?? const [],
                      imageUrl:
                      room?.imageUrl ?? '',
                      status: selectedStatus,
                      isActive:
                      room?.isActive ?? true,
                    );

                    try {
                      if (room == null) {
                        await roomService
                            .addRoom(roomModel);
                      } else {
                        await roomService
                            .updateRoom(roomModel);
                      }

                      if (!dialogContext.mounted) {
                        return;
                      }

                      Navigator.pop(dialogContext);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            room == null
                                ? 'Room added successfully.'
                                : 'Room updated successfully.',
                          ),
                        ),
                      );
                    } catch (_) {
                      if (!dialogContext.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        dialogContext,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Unable to save room.',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
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

   /* roomNumberController.dispose();
    roomNameController.dispose();
    priceController.dispose();
    capacityController.dispose();
    descriptionController.dispose();*/
  }

  Future<void> deactivateRoom(
      RoomModel room,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Deactivate Room',
          ),
          content: Text(
            'Do you want to deactivate Room '
                '${room.roomNumber}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await roomService.deactivateRoom(room.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Room deactivated successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to deactivate room.',
          ),
        ),
      );
    }
  }

  static String statusText(RoomStatus status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text('Room Management'),
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () {
          showRoomForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Room'),
      ),
      body: StreamBuilder<List<RoomModel>>(
        stream:
        roomService.watchActiveRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load rooms.',
              ),
            );
          }

          final rooms =
              snapshot.data ?? [];

          if (rooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hotel_outlined,
                    size: 70,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No rooms available.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Use Add Room to create a room.',
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              90,
            ),
            itemCount: rooms.length,
            itemBuilder:
                (context, index) {
              final room = rooms[index];

              return Card(
                margin:
                const EdgeInsets.only(
                  bottom: 12,
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.all(16),
                  leading: const Icon(
                    Icons.hotel,
                    size: 42,
                  ),
                  title: Text(
                    room.roomName,
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 8,
                    ),
                    child: Text(
                      'Room ${room.roomNumber}\n'
                          '${room.roomType}\n'
                          '₹${room.price.toStringAsFixed(0)} / night\n'
                          'Capacity: ${room.capacity}\n'
                          'Status: ${statusText(room.status)}',
                    ),
                  ),
                  trailing:
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        showRoomForm(
                          room: room,
                        );
                      }

                      if (value ==
                          'deactivate') {
                        deactivateRoom(room);
                      }
                    },
                    itemBuilder:
                        (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child:
                        Text('Edit Room'),
                      ),
                      PopupMenuItem(
                        value: 'deactivate',
                        child: Text(
                          'Deactivate Room',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}