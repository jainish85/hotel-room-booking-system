const {
  onCall,
  HttpsError,
} = require("firebase-functions/v2/https");

const {
  initializeApp,
} = require("firebase-admin/app");

const {
  getAuth,
} = require("firebase-admin/auth");

const {
  getFirestore,
} = require("firebase-admin/firestore");

initializeApp();

const db = getFirestore();
const auth = getAuth();


// ============================================================
// VERIFY ADMINISTRATOR
// ============================================================

/**
 * Verifies that the caller is an administrator.
 *
 * @param {object} request Callable function request.
 * @return {Promise<string>} Administrator UID.
 */
async function verifyAdministrator(request) {
  if (!request.auth) {
    throw new HttpsError(
        "unauthenticated",
        "You must be logged in.",
    );
  }

  const adminUid = request.auth.uid;

  const adminSnapshot = await db
      .collection("users")
      .doc(adminUid)
      .get();

  if (!adminSnapshot.exists) {
    throw new HttpsError(
        "permission-denied",
        "Administrator profile was not found.",
    );
  }

  const adminData = adminSnapshot.data() || {};

  if (adminData.role !== "administrator") {
    throw new HttpsError(
        "permission-denied",
        "Only the Administrator can perform this action.",
    );
  }

  return adminUid;
}


// ============================================================
// ADMIN EDIT USER
//
// Changes ONLY:
// - name
// - phone
// - role
//
// Does NOT change:
// - email
// - password
// - Firebase UID
// ============================================================

exports.updateUserByAdmin = onCall(async (request) => {
  await verifyAdministrator(request);

  const data = request.data || {};

  const uid = data.uid;
  const name = data.name;
  const phone = data.phone;
  const role = data.role;

  if (
    typeof uid !== "string" ||
    uid.trim().length === 0
  ) {
    throw new HttpsError(
        "invalid-argument",
        "Invalid user UID.",
    );
  }

  if (
    typeof name !== "string" ||
    name.trim().length === 0
  ) {
    throw new HttpsError(
        "invalid-argument",
        "Name is required.",
    );
  }

  if (typeof phone !== "string") {
    throw new HttpsError(
        "invalid-argument",
        "Phone is required.",
    );
  }

  if (
    role !== "customer" &&
    role !== "manager"
  ) {
    throw new HttpsError(
        "invalid-argument",
        "Only Customer or Manager roles are allowed.",
    );
  }

  if (uid === request.auth.uid) {
    throw new HttpsError(
        "failed-precondition",
        "The signed-in Administrator cannot be edited here.",
    );
  }

  const userReference = db
      .collection("users")
      .doc(uid);

  const userSnapshot = await userReference.get();

  if (!userSnapshot.exists) {
    throw new HttpsError(
        "not-found",
        "User profile was not found.",
    );
  }

  const existingUser = userSnapshot.data() || {};

  if (existingUser.role === "administrator") {
    throw new HttpsError(
        "permission-denied",
        "Administrator accounts cannot be edited here.",
    );
  }

  await userReference.update({
    name: name.trim(),
    phone: phone.trim(),
    role: role,
  });

  return {
    success: true,
    message: "User information updated successfully.",
  };
});


// ============================================================
// DELETE CUSTOMER-RELATED DATA
//
// IMPORTANT:
// Only delete records belonging to this customer.
//
// We DO NOT delete:
// - rooms
// - services
// - settings
//
// because these are hotel-wide data.
// ============================================================

/**
 * Deletes Firestore records belonging to a customer.
 *
 * @param {string} customerId Customer Firebase UID.
 * @return {Promise<number>} Number of deleted records.
 */
async function deleteCustomerRelatedData(customerId) {
  const collections = [
    "bookings",
    "service_requests",
    "customer_requests",
  ];

  let deletedCount = 0;

  for (const collectionName of collections) {
    const snapshot = await db
        .collection(collectionName)
        .where(
            "customerId",
            "==",
            customerId,
        )
        .get();

    if (snapshot.empty) {
      continue;
    }

    const batch = db.batch();

    snapshot.docs.forEach((document) => {
      batch.delete(document.ref);
      deletedCount++;
    });

    await batch.commit();
  }

  return deletedCount;
}


// ============================================================
// PERMANENTLY DELETE USER
//
// For a CUSTOMER:
//   1. Delete bookings
//   2. Delete service requests
//   3. Delete customer requests
//   4. Delete users/{uid}
//   5. Delete Firebase Authentication account
//
// For a MANAGER:
//   1. No manager-owned records currently exist
//   2. Delete users/{uid}
//   3. Delete Firebase Authentication account
//
// ADMINISTRATOR:
//   Never allowed.
// ============================================================

exports.deleteUserPermanently = onCall(async (request) => {
  await verifyAdministrator(request);

  const data = request.data || {};
  const uid = data.uid;

  if (
    typeof uid !== "string" ||
    uid.trim().length === 0
  ) {
    throw new HttpsError(
        "invalid-argument",
        "Invalid user UID.",
    );
  }

  if (uid === request.auth.uid) {
    throw new HttpsError(
        "failed-precondition",
        "You cannot delete the currently signed-in Administrator.",
    );
  }

  const userReference = db
      .collection("users")
      .doc(uid);

  const userSnapshot = await userReference.get();

  if (!userSnapshot.exists) {
    throw new HttpsError(
        "not-found",
        "User profile was not found.",
    );
  }

  const userData = userSnapshot.data() || {};

  if (userData.role === "administrator") {
    throw new HttpsError(
        "permission-denied",
        "Administrator accounts cannot be deleted.",
    );
  }

  let deletedRelatedRecords = 0;

  try {
    if (userData.role === "customer") {
      deletedRelatedRecords =
        await deleteCustomerRelatedData(uid);
    }

    await userReference.delete();

    await auth.deleteUser(uid);

    return {
      success: true,
      deletedRelatedRecords: deletedRelatedRecords,
      message:
        "User and related records were permanently deleted.",
    };
  } catch (error) {
    console.error(
        "Permanent user deletion failed:",
        error,
    );

    throw new HttpsError(
        "internal",
        "Permanent user deletion failed.",
    );
  }
});
