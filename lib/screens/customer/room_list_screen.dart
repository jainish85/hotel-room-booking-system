import 'package:flutter/material.dart';

import '../../models/room_model.dart';
import '../../models/user_model.dart';
import '../../services/room_service.dart';
import 'room_details_screen.dart';

class RoomListScreen extends StatefulWidget {
  final UserModel user;

  const RoomListScreen({
    super.key,
    required this.user,
  });

  @override
  State<RoomListScreen> createState() =>
      _RoomListScreenState();
}

class _RoomListScreenState
    extends State<RoomListScreen> {
  final RoomService roomService =
  RoomService();

  final TextEditingController searchController =
  TextEditingController();

  String? selectedRoomType;

  int adults = 1;
  int children = 0;

  List<int?> childAges = [];

  bool parkingOnly = false;

  Set<String> selectedFacilities = {};

  double? minimumPrice;
  double? maximumPrice;

  double minimumRating = 0;

  // ============================================================
  // TOTAL GUESTS
  // ============================================================

  int get totalGuests {
    return adults + children;
  }

  // ============================================================
  // ROOM TYPE OPTIONS
  // ============================================================

  List<String> get roomTypeOptions {
    if (children > 0) {
      return const [
        'Single',
        'Double',
        'Deluxe',
        'Family',
      ];
    }

    return const [
      'Single',
      'Double',
      'Deluxe',
    ];
  }

  // ============================================================
  // FAMILY ROOM LOGIC
  // ============================================================

  bool isFamilyRoom(
      RoomModel room,
      ) {
    if (room.capacity < totalGuests) {
      return false;
    }

    // Family is a customer search category.
    // It does not create a new Firestore room type.
    return room.roomType == 'Double' ||
        room.roomType == 'Deluxe' ||
        room.roomType == 'Suite';
  }

  // ============================================================
  // SEARCH
  // ============================================================

  bool matchesSearch(
      RoomModel room,
      ) {
    final query =
    searchController.text
        .trim()
        .toLowerCase();

    if (query.isEmpty) {
      return true;
    }

    return room.roomName
        .toLowerCase()
        .contains(query) ||
        room.roomType
            .toLowerCase()
            .contains(query) ||
        room.roomNumber
            .toLowerCase()
            .contains(query) ||
        room.facilities.any(
              (facility) => facility
              .toLowerCase()
              .contains(query),
        );
  }

  // ============================================================
  // ROOM TYPE FILTER
  // ============================================================

  bool matchesRoomType(
      RoomModel room,
      ) {
    if (selectedRoomType == null) {
      return true;
    }

    if (selectedRoomType == 'Family') {
      return isFamilyRoom(room);
    }

    return room.roomType ==
        selectedRoomType;
  }

  // ============================================================
  // GUEST FILTER
  // ============================================================

  bool matchesGuests(
      RoomModel room,
      ) {
    return room.capacity >=
        totalGuests;
  }

  // ============================================================
  // PARKING FILTER
  // ============================================================

  bool matchesParking(
      RoomModel room,
      ) {
    if (!parkingOnly) {
      return true;
    }

    return room.hasParking;
  }

  // ============================================================
  // FACILITY FILTER
  // ============================================================

  bool matchesFacilities(
      RoomModel room,
      ) {
    if (selectedFacilities.isEmpty) {
      return true;
    }

    final roomFacilities =
    room.facilities
        .map(
          (facility) => facility
          .trim()
          .toLowerCase(),
    )
        .toSet();

    for (final facility
    in selectedFacilities) {
      if (!roomFacilities.contains(
        facility.toLowerCase(),
      )) {
        return false;
      }
    }

    return true;
  }

  // ============================================================
  // PRICE FILTER
  // ============================================================

  bool matchesPrice(
      RoomModel room,
      ) {
    if (minimumPrice != null &&
        room.price < minimumPrice!) {
      return false;
    }

    if (maximumPrice != null &&
        room.price > maximumPrice!) {
      return false;
    }

    return true;
  }

  // ============================================================
  // RATING FILTER
  // ============================================================

  bool matchesRating(
      RoomModel room,
      ) {
    return room.rating >=
        minimumRating;
  }

  // ============================================================
  // FINAL FILTER
  // ============================================================

  List<RoomModel> filterRooms(
      List<RoomModel> rooms,
      ) {
    return rooms.where((room) {
      return matchesSearch(room) &&
          matchesRoomType(room) &&
          matchesGuests(room) &&
          matchesParking(room) &&
          matchesFacilities(room) &&
          matchesPrice(room) &&
          matchesRating(room);
    }).toList();
  }

  // ============================================================
  // GUEST SELECTOR
  // ============================================================

  Future<void> showGuestSelector() async {
    int tempAdults = adults;
    int tempChildren = children;
    List<int?> tempChildAges =
    List<int?>.from(childAges);

    if (tempChildAges.length <
        tempChildren) {
      tempChildAges.addAll(
        List<int?>.filled(
          tempChildren -
              tempChildAges.length,
          null,
        ),
      );
    }

    final result =
    await showModalBottomSheet<
        Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (
              context,
              setSheetState,
              ) {
            final capacityLimit =
            10;

            return SafeArea(
              child: Padding(
                padding:
                EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(context)
                      .viewInsets
                      .bottom +
                      20,
                ),
                child:
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Text(
                        'Guests',
                        style:
                        TextStyle(
                          fontSize: 22,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      _buildGuestRow(
                        title: 'Adults',
                        subtitle:
                        'Age 16+',
                        value:
                        tempAdults,
                        onDecrease:
                        tempAdults > 1
                            ? () {
                          setSheetState(
                                () {
                              tempAdults--;
                            },
                          );
                        }
                            : null,
                        onIncrease:
                        tempAdults +
                            tempChildren <
                            capacityLimit
                            ? () {
                          setSheetState(
                                () {
                              tempAdults++;
                            },
                          );
                        }
                            : null,
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildGuestRow(
                        title:
                        'Children',
                        subtitle:
                        'Age 4–15',
                        value:
                        tempChildren,
                        onDecrease:
                        tempChildren >
                            0
                            ? () {
                          setSheetState(
                                () {
                              tempChildren--;

                              if (tempChildAges
                                  .isNotEmpty) {
                                tempChildAges
                                    .removeLast();
                              }
                            },
                          );
                        }
                            : null,
                        onIncrease:
                        tempAdults +
                            tempChildren <
                            capacityLimit
                            ? () {
                          setSheetState(
                                () {
                              tempChildren++;

                              tempChildAges
                                  .add(
                                null,
                              );
                            },
                          );
                        }
                            : null,
                      ),

                      if (tempChildren >
                          0) ...[
                        const SizedBox(
                          height: 20,
                        ),

                        const Text(
                          'Child Ages',
                          style:
                          TextStyle(
                            fontSize: 17,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        ...List.generate(
                          tempChildren,
                              (index) {
                            return Padding(
                              padding:
                              const EdgeInsets
                                  .only(
                                bottom: 10,
                              ),
                              child:
                              DropdownButtonFormField<
                                  int>(
                                initialValue:
                                tempChildAges[
                                index],
                                decoration:
                                InputDecoration(
                                  labelText:
                                  'Child ${index + 1} age',
                                  prefixIcon:
                                  const Icon(
                                    Icons
                                        .child_care,
                                  ),
                                  border:
                                  const OutlineInputBorder(),
                                ),
                                items:
                                List.generate(
                                  12,
                                      (index) {
                                    final age =
                                        index +
                                            4;

                                    return DropdownMenuItem<
                                        int>(
                                      value:
                                      age,
                                      child:
                                      Text(
                                        '$age years',
                                      ),
                                    );
                                  },
                                ),
                                onChanged:
                                    (value) {
                                  setSheetState(
                                        () {
                                      tempChildAges[
                                      index] =
                                          value;
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],

                      const SizedBox(
                        height: 20,
                      ),

                      SizedBox(
                        width:
                        double.infinity,
                        child:
                        ElevatedButton(
                          onPressed: () {
                            if (tempChildren >
                                0) {
                              final allSelected =
                              tempChildAges.every(
                                    (age) =>
                                age != null,
                              );

                              if (!allSelected) {
                                ScaffoldMessenger
                                    .of(
                                  context,
                                )
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select the age of every child.',
                                    ),
                                  ),
                                );

                                return;
                              }
                            }

                            Navigator.pop(
                              context,
                              {
                                'adults':
                                tempAdults,
                                'children':
                                tempChildren,
                                'childAges':
                                tempChildAges
                                    .whereType<
                                    int>()
                                    .toList(),
                              },
                            );
                          },
                          child:
                          const Text(
                            'Apply Guests',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      adults =
      result['adults'] as int;

      children =
      result['children'] as int;

      childAges =
      List<int?>.from(
        result['childAges'] as List,
      );

      if (children == 0) {
        childAges.clear();

        if (selectedRoomType ==
            'Family') {
          selectedRoomType = null;
        }
      }

      if (children > 0 &&
          selectedRoomType == null) {
        selectedRoomType = 'Family';
      }
    });
  }

  // ============================================================
  // FILTER SHEET
  // ============================================================

  Future<void> showFilterSheet(
      List<RoomModel> allRooms,
      ) async {
    final facilities =
    allRooms
        .expand(
          (room) =>
      room.facilities,
    )
        .map(
          (facility) =>
          facility.trim(),
    )
        .where(
          (facility) =>
      facility.isNotEmpty,
    )
        .toSet()
        .toList()
      ..sort();

    final highestPrice =
    allRooms.isEmpty
        ? 1000.0
        : allRooms
        .map(
          (room) => room.price,
    )
        .reduce(
          (a, b) =>
      a > b ? a : b,
    );

    final maxSliderPrice =
    highestPrice <= 0
        ? 1000.0
        : highestPrice;

    double tempMinPrice =
        minimumPrice ?? 0;

    double tempMaxPrice =
        maximumPrice ??
            maxSliderPrice;

    bool tempParking =
        parkingOnly;

    Set<String> tempFacilities =
    Set<String>.from(
      selectedFacilities,
    );

    double tempRating =
        minimumRating;

    if (tempMinPrice >
        maxSliderPrice) {
      tempMinPrice = 0;
    }

    if (tempMaxPrice >
        maxSliderPrice) {
      tempMaxPrice =
          maxSliderPrice;
    }

    if (tempMinPrice >
        tempMaxPrice) {
      tempMinPrice = 0;
    }

    final result =
    await showModalBottomSheet<
        Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (
              context,
              setSheetState,
              ) {
            return SafeArea(
              child: Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  20,
                ),
                child:
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child:
                            Text(
                              'Filters',
                              style:
                              TextStyle(
                                fontSize: 22,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed:
                                () {
                              setSheetState(
                                    () {
                                  tempParking =
                                  false;

                                  tempFacilities
                                      .clear();

                                  tempMinPrice =
                                  0;

                                  tempMaxPrice =
                                      maxSliderPrice;

                                  tempRating =
                                  0;
                                },
                              );
                            },
                            child:
                            const Text(
                              'Reset',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      SwitchListTile(
                        contentPadding:
                        EdgeInsets.zero,
                        title:
                        const Text(
                          'Parking',
                          style:
                          TextStyle(
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                        subtitle:
                        const Text(
                          'Show only rooms with parking',
                        ),
                        value:
                        tempParking,
                        onChanged:
                            (value) {
                          setSheetState(
                                () {
                              tempParking =
                                  value;
                            },
                          );
                        },
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      const Text(
                        'Facilities',
                        style:
                        TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      if (facilities
                          .isEmpty)
                        const Text(
                          'No facilities available.',
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                          facilities.map(
                                (facility) {
                              final selected =
                              tempFacilities
                                  .contains(
                                facility,
                              );

                              return FilterChip(
                                label:
                                Text(
                                  facility,
                                ),
                                selected:
                                selected,
                                onSelected:
                                    (value) {
                                  setSheetState(
                                        () {
                                      if (value) {
                                        tempFacilities
                                            .add(
                                          facility,
                                        );
                                      } else {
                                        tempFacilities
                                            .remove(
                                          facility,
                                        );
                                      }
                                    },
                                  );
                                },
                              );
                            },
                          ).toList(),
                        ),

                      const SizedBox(
                        height: 22,
                      ),

                      const Text(
                        'Price',
                        style:
                        TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        '₹${tempMinPrice.toStringAsFixed(0)} - '
                            '₹${tempMaxPrice.toStringAsFixed(0)}',
                      ),

                      RangeSlider(
                        min: 0,
                        max: maxSliderPrice,
                        divisions:
                        maxSliderPrice >
                            100
                            ? 20
                            : 10,
                        values:
                        RangeValues(
                          tempMinPrice,
                          tempMaxPrice,
                        ),
                        onChanged:
                            (values) {
                          setSheetState(
                                () {
                              tempMinPrice =
                                  values.start;

                              tempMaxPrice =
                                  values.end;
                            },
                          );
                        },
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      const Text(
                        'Minimum Rating',
                        style:
                        TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Wrap(
                        spacing: 8,
                        children: [
                          _buildRatingFilterChip(
                            0,
                            tempRating,
                            setSheetState,
                                (value) {
                              tempRating =
                                  value;
                            },
                          ),
                          _buildRatingFilterChip(
                            3,
                            tempRating,
                            setSheetState,
                                (value) {
                              tempRating =
                                  value;
                            },
                          ),
                          _buildRatingFilterChip(
                            4,
                            tempRating,
                            setSheetState,
                                (value) {
                              tempRating =
                                  value;
                            },
                          ),
                          _buildRatingFilterChip(
                            4.5,
                            tempRating,
                            setSheetState,
                                (value) {
                              tempRating =
                                  value;
                            },
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      SizedBox(
                        width:
                        double.infinity,
                        child:
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              {
                                'parking':
                                tempParking,
                                'facilities':
                                tempFacilities,
                                'minPrice':
                                tempMinPrice,
                                'maxPrice':
                                tempMaxPrice,
                                'rating':
                                tempRating,
                              },
                            );
                          },
                          child:
                          const Text(
                            'Apply Filters',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      parkingOnly =
      result['parking'] as bool;

      selectedFacilities =
      Set<String>.from(
        result['facilities'] as Set,
      );

      minimumPrice =
      result['minPrice'] as double;

      maximumPrice =
      result['maxPrice'] as double;

      minimumRating =
      result['rating'] as double;
    });
  }

  // ============================================================
  // RATING CHIP
  // ============================================================

  Widget _buildRatingFilterChip(
      double rating,
      double selectedRating,
      StateSetter setSheetState,
      void Function(double) onSelected,
      ) {
    final selected =
        selectedRating == rating;

    final label = rating == 0
        ? 'Any'
        : '${rating.toStringAsFixed(
      rating % 1 == 0 ? 0 : 1,
    )}+';

    return FilterChip(
      label: Text(
        rating == 0
            ? 'Any'
            : '$label ★',
      ),
      selected: selected,
      onSelected: (_) {
        setSheetState(() {
          onSelected(rating);
        });
      },
    );
  }

  // ============================================================
  // GUEST ROW
  // ============================================================

  Widget _buildGuestRow({
    required String title,
    required String subtitle,
    required int value,
    required VoidCallback? onDecrease,
    required VoidCallback? onIncrease,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(14),
      decoration:
      BoxDecoration(
        border: Border.all(
          color: Theme.of(context)
              .dividerColor,
        ),
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  title,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  subtitle,
                  style:
                  const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed:
            onDecrease,
            icon: const Icon(
              Icons
                  .remove_circle_outline,
            ),
          ),

          Text(
            value.toString(),
            style:
            const TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          IconButton(
            onPressed:
            onIncrease,
            icon: const Icon(
              Icons
                  .add_circle_outline,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER SUMMARY COUNT
  // ============================================================

  int get activeFilterCount {
    int count = 0;

    if (selectedRoomType != null) {
      count++;
    }

    if (parkingOnly) {
      count++;
    }

    count +=
        selectedFacilities.length;

    if (minimumPrice != null &&
        minimumPrice! > 0) {
      count++;
    }

    if (maximumPrice != null) {
      count++;
    }

    if (minimumRating > 0) {
      count++;
    }

    return count;
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  void clearFilters() {
    setState(() {
      selectedRoomType = null;

      searchController.clear();

      adults = 1;
      children = 0;
      childAges.clear();

      parkingOnly = false;

      selectedFacilities.clear();

      minimumPrice = null;
      maximumPrice = null;

      minimumRating = 0;
    });
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
        bottom: 14,
      ),
      clipBehavior:
      Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  RoomDetailsScreen(
                    room: room,
                    user: widget.user,
                  ),
            ),
          );
        },
        child: Padding(
          padding:
          const EdgeInsets.all(
            14,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  if (room
                      .imageUrl
                      .isNotEmpty)
                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                      child:
                      Image.network(
                        room.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                            context,
                            error,
                            stackTrace,
                            ) {
                          return Container(
                            width: 100,
                            height: 100,
                            alignment:
                            Alignment
                                .center,
                            child:
                            const Icon(
                              Icons.hotel,
                              size: 45,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      width: 100,
                      height: 100,
                      alignment:
                      Alignment.center,
                      decoration:
                      BoxDecoration(
                        borderRadius:
                        BorderRadius
                            .circular(
                          10,
                        ),
                      ),
                      child:
                      const Icon(
                        Icons.hotel,
                        size: 45,
                      ),
                    ),

                  const SizedBox(
                    width: 14,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        Text(
                          room.roomName,
                          style:
                          const TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          '${room.roomType} • '
                              'Room ${room.roomNumber}',
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        if (room.rating >
                            0)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 18,
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(
                                room.rating
                                    .toStringAsFixed(
                                  1,
                                ),
                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          '₹${room.price.toStringAsFixed(0)}',
                          style:
                          const TextStyle(
                            fontSize: 17,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons
                        .arrow_forward_ios,
                    size: 18,
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _buildInfoChip(
                    Icons.people,
                    '$totalGuests guest'
                        '${totalGuests > 1 ? 's' : ''}',
                  ),

                  if (room.hasParking)
                    _buildInfoChip(
                      Icons.local_parking,
                      'Parking',
                    ),

                  if (children > 0)
                    _buildInfoChip(
                      Icons.family_restroom,
                      'Family',
                    ),

                  ...room.facilities
                      .take(3)
                      .map(
                        (facility) =>
                        _buildInfoChip(
                          Icons.check,
                          facility,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      IconData icon,
      String label,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        color:
        Theme.of(context)
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
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
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
          'Search Rooms',
        ),
        actions: [
          IconButton(
            onPressed:
            clearFilters,
            tooltip:
            'Clear all',
            icon:
            const Icon(
              Icons.clear_all,
            ),
          ),
        ],
      ),

      body:
      StreamBuilder<List<RoomModel>>(
        stream:
        roomService
            .watchActiveRooms(),
        builder:
            (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState
                  .waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child:
              Padding(
                padding:
                const EdgeInsets
                    .all(
                  20,
                ),
                child:
                Text(
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

          return Column(
            children: [
              // ==================================================
              // SEARCH
              // ==================================================

              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  10,
                ),
                child:
                TextField(
                  controller:
                  searchController,
                  onChanged:
                      (_) {
                    setState(
                          () {},
                    );
                  },
                  decoration:
                  InputDecoration(
                    hintText:
                    'Search room, type, number or facility...',
                    prefixIcon:
                    const Icon(
                      Icons.search,
                    ),
                    suffixIcon:
                    searchController
                        .text
                        .isEmpty
                        ? null
                        : IconButton(
                      onPressed:
                          () {
                        searchController
                            .clear();

                        setState(
                              () {},
                        );
                      },
                      icon:
                      const Icon(
                        Icons.clear,
                      ),
                    ),
                    border:
                    const OutlineInputBorder(),
                  ),
                ),
              ),

              // ==================================================
              // GUEST + FILTER BUTTONS
              // ==================================================

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child:
                Row(
                  children: [
                    Expanded(
                      child:
                      OutlinedButton.icon(
                        onPressed:
                        showGuestSelector,
                        icon:
                        const Icon(
                          Icons
                              .people_outline,
                        ),
                        label:
                        Text(
                          '$adults adult'
                              '${adults > 1 ? 's' : ''}'
                              ' • '
                              '$children child'
                              '${children != 1 ? 'ren' : ''}',
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child:
                      OutlinedButton.icon(
                        onPressed:
                            () =>
                            showFilterSheet(
                              allRooms,
                            ),
                        icon:
                        const Icon(
                          Icons
                              .tune,
                        ),
                        label:
                        Text(
                          activeFilterCount ==
                              0
                              ? 'Filters'
                              : 'Filters ($activeFilterCount)',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // ROOM TYPE
              // ==================================================

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child:
                Row(
                  children: [
                    Expanded(
                      child:
                      DropdownButtonFormField<String>(
                        initialValue:
                        selectedRoomType,
                        decoration:
                        const InputDecoration(
                          labelText:
                          'Room Type',
                          border:
                          OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<
                              String>(
                            value:
                            null,
                            child:
                            Text(
                              'All Room Types',
                            ),
                          ),
                          ...roomTypeOptions
                              .map(
                                (
                                type,
                                ) {
                              return DropdownMenuItem<
                                  String>(
                                value:
                                type,
                                child:
                                Text(
                                  type,
                                ),
                              );
                            },
                          ),
                        ],
                        onChanged:
                            (value) {
                          setState(
                                () {
                              selectedRoomType =
                                  value;
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    IconButton(
                      onPressed:
                      clearFilters,
                      tooltip:
                      'Clear Filters',
                      icon:
                      const Icon(
                        Icons.clear,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // CURRENT GUEST SUMMARY
              // ==================================================

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child:
                Align(
                  alignment:
                  Alignment
                      .centerLeft,
                  child:
                  Text(
                    'Searching for '
                        '$totalGuests guest'
                        '${totalGuests > 1 ? 's' : ''}'
                        '${children > 0 ? ' • Family stay' : ''}',
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // RESULTS
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
                              .search_off,
                          size: 65,
                        ),
                        SizedBox(
                          height:
                          14,
                        ),
                        Text(
                          'No rooms found.',
                          style:
                          TextStyle(
                            fontSize:
                            19,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height:
                          8,
                        ),
                        Text(
                          'Try changing your search or filters.',
                          textAlign:
                          TextAlign.center,
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
                    30,
                  ),
                  itemCount:
                  rooms.length,
                  itemBuilder:
                      (
                      context,
                      index,
                      ) {
                    return buildRoomCard(
                      rooms[index],
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