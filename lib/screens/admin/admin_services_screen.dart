import 'package:flutter/material.dart';

import '../../models/service_model.dart';
import '../../services/service_service.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({
    super.key,
  });

  @override
  State<AdminServicesScreen> createState() =>
      _AdminServicesScreenState();
}

class _AdminServicesScreenState
    extends State<AdminServicesScreen> {
  final ServiceService serviceService =
  ServiceService();

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController descriptionController =
  TextEditingController();

  final TextEditingController priceController =
  TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> showServiceDialog({
    ServiceModel? service,
  }) async {
    nameController.text = service?.name ?? '';
    descriptionController.text =
        service?.description ?? '';
    priceController.text = service != null
        ? service.price.toStringAsFixed(0)
        : '';

    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              title: Text(
                service == null
                    ? 'Add Service'
                    : 'Edit Service',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      textInputAction:
                      TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Service Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller:
                      descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: priceController,
                      keyboardType:
                      const TextInputType
                          .numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                    final name =
                    nameController.text.trim();

                    final description =
                    descriptionController
                        .text
                        .trim();

                    final price =
                    double.tryParse(
                      priceController.text.trim(),
                    );

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter service name.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (description.isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter description.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (price == null ||
                        price < 0) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid price.',
                          ),
                        ),
                      );
                      return;
                    }

                    setDialogState(() {
                      isSaving = true;
                    });

                    try {
                      if (service == null) {
                        final serviceRef =
                        serviceService
                            .servicesCollection
                            .doc();

                        final newService =
                        ServiceModel(
                          id: serviceRef.id,
                          name: name,
                          description:
                          description,
                          price: price,
                          isActive: true,
                        );

                        await serviceService
                            .addService(
                          newService,
                        );
                      } else {
                        final updatedService =
                        ServiceModel(
                          id: service.id,
                          name: name,
                          description:
                          description,
                          price: price,
                          isActive:
                          service.isActive,
                        );

                        await serviceService
                            .updateService(
                          updatedService,
                        );
                      }

                      nameController.clear();
                      descriptionController
                          .clear();
                      priceController.clear();

                      if (!dialogContext.mounted) {
                        return;
                      }

                      Navigator.pop(
                        dialogContext,
                      );

                      if (!mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            service == null
                                ? 'Service added successfully.'
                                : 'Service updated successfully.',
                          ),
                        ),
                      );
                    } catch (_) {
                      setDialogState(() {
                        isSaving = false;
                      });

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Unable to save service.',
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
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> changeServiceStatus(
      ServiceModel service,
      bool isActive,
      ) async {
    try {
      final updatedService = ServiceModel(
        id: service.id,
        name: service.name,
        description: service.description,
        price: service.price,
        isActive: isActive,
      );

      await serviceService.updateService(
        updatedService,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isActive
                ? 'Service activated.'
                : 'Service deactivated.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update service status.',
          ),
        ),
      );
    }
  }

  Future<void> deleteService(
      ServiceModel service,
      ) async {
    final shouldDelete =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Service',
          ),
          content: Text(
            'Delete "${service.name}" permanently?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await serviceService.deleteService(
        service.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Service deleted successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to delete service.',
          ),
        ),
      );
    }
  }

  void showServiceActions(
      ServiceModel service,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit,
                ),
                title: const Text(
                  'Edit Service',
                ),
                onTap: () {
                  Navigator.pop(context);

                  showServiceDialog(
                    service: service,
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  service.isActive
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                title: Text(
                  service.isActive
                      ? 'Deactivate Service'
                      : 'Activate Service',
                ),
                onTap: () {
                  Navigator.pop(context);

                  changeServiceStatus(
                    service,
                    !service.isActive,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                ),
                title: const Text(
                  'Delete Service',
                ),
                onTap: () {
                  Navigator.pop(context);

                  deleteService(service);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Service Management',
        ),
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () {
          showServiceDialog();
        },
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add Service',
        ),
      ),
      body: StreamBuilder<List<ServiceModel>>(
        stream:
        serviceService.watchAllServices(),
        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Text(
                  'Unable to load services.\n\n${snapshot.error}',
                  textAlign:
                  TextAlign.center,
                ),
              ),
            );
          }

          final services =
              snapshot.data ?? [];

          if (services.isEmpty) {
            return const Center(
              child: Padding(
                padding:
                EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.room_service_outlined,
                      size: 70,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'No services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add a hotel service to get started.',
                      textAlign:
                      TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              90,
            ),
            itemCount: services.length,
            separatorBuilder: (_, _) =>
            const SizedBox(
              height: 12,
            ),
            itemBuilder: (
                context,
                index,
                ) {
              final service =
              services[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons
                          .room_service_outlined,
                    ),
                  ),
                  title: Text(
                    service.name,
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${service.description}\n'
                        '₹${service.price.toStringAsFixed(0)} • '
                        '${service.isActive ? 'Active' : 'Inactive'}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                    ),
                    onPressed: () {
                      showServiceActions(
                        service,
                      );
                    },
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