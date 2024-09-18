import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyUserData {
  final String uid;
  final String name;
  final String email;
  final String shortDescription;
  final List<int> interests;

  MyUserData({
    required this.uid,
    required this.name,
    required this.email,
    required this.shortDescription,
    required this.interests,
  });

  factory MyUserData.fromMap(Map<String, dynamic> map) {
    return MyUserData(
      uid: map['uid'] ?? '', // Provide default values in case fields are missing
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      shortDescription: map['shortDescription'] ?? '',
      interests: (map['interests'] as List<dynamic>?)?.cast<int>() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'shortDescription': shortDescription,
      'interests': interests,
    };
  }
}

// Helper function to get user data from Firestore and convert it
Future<MyUserData?> getUserData(User user) async {
  try {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (docSnapshot.exists) {
      return MyUserData.fromMap(docSnapshot.data()!);
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching user data: $e');
    return null;
  }
}