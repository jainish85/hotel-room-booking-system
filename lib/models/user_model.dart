enum UserRole {
  customer,
  manager,
  administrator,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
  });

  factory UserModel.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    return UserModel(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: roleFromString(
        data['role'] as String? ?? 'customer',
      ),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': roleToString(role),
      'isActive': isActive,
    };
  }

  static UserRole roleFromString(String role) {
    switch (role) {
      case 'manager':
        return UserRole.manager;

      case 'administrator':
        return UserRole.administrator;

      default:
        return UserRole.customer;
    }
  }

  static String roleToString(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'customer';

      case UserRole.manager:
        return 'manager';

      case UserRole.administrator:
        return 'administrator';
    }
  }
}