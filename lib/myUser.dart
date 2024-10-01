// myUser.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A class representing the user's data structure.
class MyUserData {
  /// Unique identifier for the user.
  String uid;

  /// The user's chosen username.
  String username;

  /// The user's full name.
  String name;

  /// The user's email address.
  String email;

  /// A short description or bio of the user.
  String shortDescription;

  /// List of interest IDs associated with the user.
  List<int> interests;

  /// List of challenge IDs the user is participating in.
  List<String> challenges;

  /// Number of challenges the user has completed.
  int completedChallenges;

  /// List of friend UIDs.
  List<String> friends;

  /// Constructs a [MyUserData] instance with the required fields.
  MyUserData({
    required this.uid,
    required this.username,
    required this.name,
    required this.email,
    required this.shortDescription,
    required this.interests,
    this.challenges = const [],
    this.completedChallenges = 0,
    this.friends = const [],
  });

  /// Creates a [MyUserData] instance from a map retrieved from Firestore.
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
      friends: (map['friends'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Converts the [MyUserData] instance into a map for Firestore storage.
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
      'friends': friends,
    };
  }
}

/// Fetches the user data from Firestore based on the authenticated [User].
///
/// Returns a [MyUserData] instance if successful, otherwise null.
Future<MyUserData?> getUserData(User user) async {
  try {
    // Retrieve the user's document from the 'users' collection.
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (docSnapshot.exists) {
      // Create and return a [MyUserData] instance from the retrieved data.
      return MyUserData.fromMap(docSnapshot.data()!, user.uid);
    }
    return null;
  } catch (e) {
    // Print the error and return null if an exception occurs.
    print('Error fetching user data: $e');
    return null;
  }
}
