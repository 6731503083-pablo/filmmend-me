import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return UserModel(
        uid: doc.id,
        email: '',
        displayName: 'Film Lover',
        photoUrl: null,
        createdAt: DateTime.now(),
      );
    }
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Film Lover',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Formatted "Member since" string
  String get memberSince {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return 'Member since ${months[createdAt.month - 1]} ${createdAt.year}';
  }
}
