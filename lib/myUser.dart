import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyUserData {
  final String uid; // Firebase uid
  final String username; // Username added back
  final String name;
  final String email;
  final String shortDescription;
  final List<int> interests;
  int completedChallenges = 0;

  MyUserData({
    required this.uid,
    required this.username, // Add username to the constructor
    required this.name,
    required this.email,
    required this.shortDescription,
    required this.interests,
    this.completedChallenges = 0,
  });

  factory MyUserData.fromMap(Map<String, dynamic> map, String uid) {
    return MyUserData(
      uid: uid, // Use Firebase uid passed from the document
      username: map['username'] ?? 'Unknown', // Fetch username from the document
      name: map['name'] ?? 'Unknown',
      email: map['email'] ?? 'Unknown',
      shortDescription: map['shortDescription'] ?? '',
      interests: (map['interests'] as List<dynamic>?)?.cast<int>() ?? [],
      completedChallenges: map['completedChallenges'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid, // Firebase uid
      'username': username, // Include username in the map
      'name': name,
      'email': email,
      'shortDescription': shortDescription,
      'interests': interests,
      'completedChallenges': completedChallenges,
    };
  }
}

Future<MyUserData?> getUserData(User user) async {
  try {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid) // Use Firebase uid as the document ID
        .get();

    if (docSnapshot.exists) {
      return MyUserData.fromMap(docSnapshot.data()!, user.uid); // Pass the Firebase uid
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching user data: $e');
    return null;
  }
}
