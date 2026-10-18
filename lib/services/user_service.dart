import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';
import '../models/user_model.dart';
class UserService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFunctions _functions =
      FirebaseFunctions.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // ==========================================================
  // GET ALL USERS
  // ==========================================================

  Stream<List<UserModel>> watchAllUsers() {
    return _users
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs
            .map(
              (doc) => UserModel.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
            .toList();
      },
    );
  }

  // ==========================================================
  // GET USER BY ID
  // ==========================================================

  Future<UserModel?> getUserById(
      String userId,
      ) async {
    final document =
    await _users.doc(userId).get();

    if (!document.exists ||
        document.data() == null) {
      return null;
    }

    return UserModel.fromFirestore(
      document.id,
      document.data()!,
    );
  }

  // ==========================================================
  // UPDATE CUSTOMER PROFILE
  // ==========================================================

  Future<void> updateCustomerProfile({
    required String userId,
    required String name,
    required String phone,
  }) async {
    await _users.doc(userId).update({
      'name': name.trim(),
      'phone': phone.trim(),
    });
  }

  // ==========================================================
  // UPDATE USER ROLE
  // ==========================================================

  Future<void> updateUserRole({
    required String userId,
    required UserRole role,
  }) async {
    if (role == UserRole.administrator) {
      throw Exception(
        'Administrator role cannot be assigned here.',
      );
    }

    await _users.doc(userId).update({
      'role':
      UserModel.roleToString(role),
    });
  }

  // ==========================================================
  // ACTIVATE / DEACTIVATE USER
  // ==========================================================

  Future<void> updateUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    await _users.doc(userId).update({
      'isActive': isActive,
    });
  }

  // ==========================================================
  // CREATE CUSTOMER / MANAGER
  // ==========================================================

  Future<void> createUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    if (role == UserRole.administrator) {
      throw Exception(
        'Administrator accounts cannot be created from User Management.',
      );
    }

    final secondaryApp =
    await Firebase.initializeApp(
      name: 'adminUserManagement',
      options:
      DefaultFirebaseOptions.currentPlatform,
    );

    final secondaryAuth =
    FirebaseAuth.instanceFor(
      app: secondaryApp,
    );

    User? createdUser;

    try {
      final credential =
      await secondaryAuth
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      createdUser =
          credential.user;

      if (createdUser == null) {
        throw Exception(
          'Unable to create authentication account.',
        );
      }

      await _users
          .doc(createdUser.uid)
          .set({
        'id': createdUser.uid,
        'name': name.trim(),
        'email':
        email.trim().toLowerCase(),
        'phone': phone.trim(),
        'role':
        UserModel.roleToString(role),
        'isActive': true,
      });
    } on FirebaseAuthException catch (e) {
      throw Exception(
        e.message ??
            'Unable to create authentication account.',
      );
    } catch (e) {
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {}
      }

      throw Exception(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      await secondaryAuth.signOut();
      await secondaryApp.delete();
    }
  }

  // ==========================================================
  // ADMIN EDIT USER
  //
  // Changes:
  // - name
  // - phone
  // - role
  //
  // Does NOT change:
  // - email
  // - password
  // - Firebase UID
  // ==========================================================

  Future<void> updateUserByAdmin({
    required String userId,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    if (role == UserRole.administrator) {
      throw Exception(
        'Administrator role cannot be assigned here.',
      );
    }

    final callable =
    _functions.httpsCallable(
      'updateUserByAdmin',
    );

    try {
      await callable.call({
        'uid': userId,
        'name': name.trim(),
        'phone': phone.trim(),
        'role':
        UserModel.roleToString(role),
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message ??
            'Unable to update user information.',
      );
    }
  }

  // ==========================================================
  // PERMANENT DELETE USER
  // ==========================================================

  Future<void> deleteUserPermanently(
      String userId,
      ) async {
    final currentUser =
        _auth.currentUser;

    if (currentUser?.uid == userId) {
      throw Exception(
        'You cannot delete your own Administrator account.',
      );
    }

    final user =
    await getUserById(userId);

    if (user == null) {
      throw Exception(
        'User was not found.',
      );
    }

    if (user.role ==
        UserRole.administrator) {
      throw Exception(
        'Administrator accounts cannot be deleted.',
      );
    }

    final callable =
    _functions.httpsCallable(
      'deleteUserPermanently',
    );

    try {
      await callable.call({
        'uid': userId,
      });
    } on FirebaseFunctionsException catch (e) {
      throw Exception(
        e.message ??
            'Unable to permanently delete user.',
      );
    }
  }
}