class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isActive;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isActive,
  });

  factory ServiceModel.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    return ServiceModel(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'isActive': isActive,
    };
  }
}