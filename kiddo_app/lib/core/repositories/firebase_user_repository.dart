// ─────────────────────────────────────────────────────────────────────────────
// FirebaseUserRepository — production implementation.
// ACTIVATION: Run `flutterfire configure` to generate firebase_options.dart,
// then uncomment the import below and replace MockUserRepository in
// user_provider.dart with this class.
// ─────────────────────────────────────────────────────────────────────────────

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:kiddo_app/core/models/user_model.dart';
import 'package:kiddo_app/core/repositories/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // static const String _collection = 'users'; // Uncomment when activating Firebase

  @override
  Future<UserModel?> getCurrentUser() async {
    // final fbUser = _auth.currentUser;
    // if (fbUser == null) return null;
    // final doc = await _db.collection(_collection).doc(fbUser.uid).get();
    // return doc.exists ? _fromDoc(doc) : null;
    throw UnimplementedError('Run flutterfire configure first.');
  }

  @override
  Stream<UserModel?> watchCurrentUser(String userId) {
    // return _db.collection(_collection).doc(userId).snapshots().map((snap) {
    //   return snap.exists ? _fromDoc(snap) : null;
    // });
    throw UnimplementedError('Run flutterfire configure first.');
  }

  @override
  Future<List<UserModel>> getLeaderboard() async {
    // final snap = await _db
    //     .collection(_collection)
    //     .orderBy('iq', descending: true)
    //     .limit(20)
    //     .get();
    // return snap.docs.map(_fromDoc).toList();
    throw UnimplementedError('Run flutterfire configure first.');
  }

  @override
  Future<void> updateProgress({
    required String userId,
    required int iqDelta,
    required int coinsEarned,
  }) async {
    // await _db.collection(_collection).doc(userId).update({
    //   'iq': FieldValue.increment(iqDelta),
    //   'coins': FieldValue.increment(coinsEarned),
    // });
    throw UnimplementedError('Run flutterfire configure first.');
  }

  @override
  Future<void> incrementStreak(String userId) async {
    // await _db.collection(_collection).doc(userId).update({
    //   'streak': FieldValue.increment(1),
    // });
    throw UnimplementedError('Run flutterfire configure first.');
  }

  // UserModel _fromDoc(DocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   return UserModel(
  //     id: doc.id,
  //     name: data['name'] as String? ?? 'Student',
  //     avatarUrl: data['avatarUrl'] as String? ?? 'assets/images/KidDo Character.png',
  //     iq: (data['iq'] as num?)?.toInt() ?? 0,
  //     coins: (data['coins'] as num?)?.toInt() ?? 0,
  //     streak: (data['streak'] as num?)?.toInt() ?? 0,
  //   );
  // }
}
