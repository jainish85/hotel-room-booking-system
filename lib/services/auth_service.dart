import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore =>
      FirebaseFirestore.instance;

  // REGISTER CUSTOMER
  Future<UserModel?> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final UserCredential credential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? firebaseUser = credential.user;

      if (firebaseUser == null) {
        return null;
      }

      final user = UserModel(
        id: firebaseUser.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        role: UserRole.customer,
        isActive: true,
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set({
        'id': firebaseUser.uid,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'role': UserModel.roleToString(user.role),
        'isActive': user.isActive,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // LOGIN
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? firebaseUser = credential.user;

      if (firebaseUser == null) {
        return null;
      }

      final DocumentSnapshot<Map<String, dynamic>> document =
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!document.exists || document.data() == null) {
        await _auth.signOut();
        return null;
      }

      final data = document.data()!;

      final bool isActive =
          data['isActive'] as bool? ?? true;

      if (!isActive) {
        await _auth.signOut();
        return null;
      }

      final String roleString =
          data['role'] as String? ?? 'customer';

      final UserRole role =
      UserModel.roleFromString(roleString);

      return UserModel(
        id: firebaseUser.uid,
        name: data['name'] as String? ?? '',
        email:
        data['email'] as String? ??
            firebaseUser.email ??
            '',
        phone: data['phone'] as String? ?? '',
        role: role,
        isActive: isActive,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }
  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}