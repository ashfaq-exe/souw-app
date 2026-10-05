import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String role,
    String phone = '',
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data();
  }

  Future<void> addFood({
    required String foodName,
    required String description,
    required String quantity,
    required String location,
    required String donorId,
    required String donorName,
  }) async {
    await _db.collection('foods').add({
      'foodName': foodName,
      'description': description,
      'quantity': quantity,
      'location': location,
      'donorId': donorId,
      'donorName': donorName,

      // Important
      'status': 'Available',

      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAvailableFoods() {
    return _db
        .collection('foods')
        .where('status', isEqualTo: 'Available')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyFoods(String donorId) {
    return _db
        .collection('foods')
        .where('donorId', isEqualTo: donorId)
        .snapshots();
  }

  Future<void> createRequest({
    required String foodId,
    required String foodName,
    required String donorId,
    required String receiverId,
    required String receiverName,
    required String quantity,
  }) async {
    await _db.collection('requests').add({
      'foodId': foodId,
      'foodName': foodName,
      'donorId': donorId,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'quantity': quantity,
      'status': 'Requested',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('foods').doc(foodId).update({'status': 'Requested'});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRequests() {
    return _db.collection('requests').snapshots();
  }

  Future<void> updateRequestStatus({
    required String requestId,
    required String foodId,
    required String status,
  }) async {
    await _db.collection('requests').doc(requestId).update({'status': status});

    await _db.collection('foods').doc(foodId).update({'status': status});
  }
}
