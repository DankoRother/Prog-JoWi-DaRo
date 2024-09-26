import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyUserData {
  final String uid;
  final String username;
  final String name;
  final String email;
  final String shortDescription;
  final List<int> interests;
  List<String> challenges;
  int completedChallenges;

  MyUserData({
    required this.uid,
    required this.username,
    required this.name,
    required this.email,
    required this.shortDescription,
    required this.interests,
    this.challenges = const [],
    this.completedChallenges = 0,
  });

  factory MyUserData.fromMap(Map<String, dynamic> map, String uid) {
    return MyUserData(
      uid: uid,
      username: map['username'] ?? 'Unknown',
      name: map['name'] ?? 'Unknown',
      email: map['email'] ?? 'Unknown',
      shortDescription: map['shortDescription'] ?? '',
      interests: (map['interests'] as List<dynamic>?)?.cast<int>() ?? [],
      challenges: (map['challenges'] as List<dynamic>?)?.cast<String>() ?? [],
      completedChallenges: map['completedChallenges'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'name': name,
      'email': email,
      'shortDescription': shortDescription,
      'interests': interests,
      'challenges': challenges,
      'completedChallenges': completedChallenges,
    };
  }
}

Future<MyUserData?> getUserData(User user) async {
  try {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (docSnapshot.exists) {
      return MyUserData.fromMap(docSnapshot.data()!, user.uid);
    }
    return null;
  } catch (e) {
    print('Error fetching user data: $e');
    return null;
  }
}
