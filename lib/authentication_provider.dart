import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'myUser.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  MyUserData? _currentUser;
  StreamSubscription<User?>? _authStateSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Initialize _firestore
  bool get isLoggedIn => _isLoggedIn;
  MyUserData? get currentUser => _currentUser;

  // Initialize AuthProvider by checking the current login status
  AuthProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    // Listen for changes in the FirebaseAuth state and update the provider
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        // Fetch user data only if it's a new login or the current user has changed
        if (_currentUser == null || _currentUser!.uid != user.uid) {
          print('FirebaseAuth user exists: ${user.uid}');
          await fetchUserData(user.uid);  // Fetch user data from Firestore
          _isLoggedIn = true;
          notifyListeners();  // Notify once user data is fetched
        }
      } else {
        // Only change the state if the user is actually logged out
        if (_isLoggedIn) {
          _isLoggedIn = false;
          _currentUser = null;
          notifyListeners();
        }
      }
    });
  }


  Future<void> checkLoginStatus() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      if (_currentUser == null || _currentUser!.uid != firebaseUser.uid) {
        // Fetch user data only if it's not already fetched or user has changed
        await fetchUserData(firebaseUser.uid);
        _isLoggedIn = true;
      }
    } else {
      _isLoggedIn = false;
      _currentUser = null;
    }
    notifyListeners();
  }


  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _isLoggedIn = false;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
    }
  }
  Future<void> updateCompletedChallenges(String userId) async {
    try {
      // Fetch the user's document to get the list of challenge IDs
      final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (!userSnapshot.exists) {
        print('User does not exist');
        return;
      }

      final userData = userSnapshot.data()!;
      final List<String> challengeIds = (userData['challenges'] as List<dynamic>).cast<String>();

      if (challengeIds.isEmpty) {
        // No challenges to calculate, set completedChallenges to 0
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'completedChallenges': 0,
        });
        return;
      }

      // Fetch all challenges that the user is assigned to
      final challengesSnapshot = await FirebaseFirestore.instance
          .collection('challenge')
          .where(FieldPath.documentId, whereIn: challengeIds)
          .get();

      int completedChallengesCount = 0;

      for (var doc in challengesSnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final finalDuration = data['finalDuration'] as int;

        final DateTime createdAtDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
        final DateTime currentDate = DateTime.now();
        final int daysPassed = currentDate.difference(createdAtDate).inDays;

        // If the days passed is equal to or greater than the challenge duration, it's completed
        if (daysPassed >= finalDuration) {
          completedChallengesCount++;
        }
      }

      // Update the user's completedChallenges count in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'completedChallenges': completedChallengesCount,
      });

      print('Updated completedChallenges for user $userId: $completedChallengesCount');
    } catch (e) {
      print('Error updating completed challenges: $e');
    }
  }

  Future<void> fetchUserData(String uid) async {
    try {
      final userSnapshot = await _firestore.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        _currentUser = MyUserData.fromMap(userSnapshot.data()!, uid);

        // After fetching user data, calculate and update completed challenges
        await calculateCompletedChallenges();

        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> calculateCompletedChallenges() async {
    if (_currentUser == null) return;

    try {
      // Fetch all the user's challenges
      final challengesSnapshot = await _firestore.collection('challenge')
          .where(FieldPath.documentId, whereIn: _currentUser!.challenges)
          .get();

      int completedChallengesCount = 0;
      DateTime currentDate = DateTime.now();

      for (var doc in challengesSnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final finalDuration = data['finalDuration'] as int;

        final DateTime createdAtDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
        final int daysPassed = currentDate.difference(createdAtDate).inDays;
        final bool completedChallenge = daysPassed >= finalDuration;

        if (completedChallenge) {
          completedChallengesCount++;
        }
      }

      // Update the user's completed challenges count in Firestore
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'completedChallenges': completedChallengesCount,
      });

      // Update the local user data by creating a new instance of MyUserData
      _currentUser = MyUserData(
        uid: _currentUser!.uid,
        username: _currentUser!.username,
        name: _currentUser!.name,
        email: _currentUser!.email,
        shortDescription: _currentUser!.shortDescription,
        interests: _currentUser!.interests,
        challenges: _currentUser!.challenges, // Existing challenges remain the same
        completedChallenges: completedChallengesCount, // New value for completed challenges
      );

      notifyListeners(); // Notify listeners that the user data has been updated
    } catch (e) {
      print('Error calculating completed challenges: $e');
    }
  }


  Future<void> login(String username, String password, BuildContext context) async {
    if (!_isLoggedIn) {
      if (username.isNotEmpty && password.isNotEmpty) {
        try {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            final userData = querySnapshot.docs.first.data();
            final storedHashedPassword = userData['password'];
            final email = userData['email']; // Assuming you store email in Firestore

            if (BCrypt.checkpw(password, storedHashedPassword)) {
              // Firebase Auth sign-in process
              UserCredential authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email,
                password: password,
              );

              await fetchUserData(authResult.user!.uid);

              if (_currentUser != null) {
                _isLoggedIn = true;
                notifyListeners();
                print('Login successful. User UID: ${authResult.user!.uid}');
              } else {
                print('Error: User data not correctly assigned.');
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.pink[900],
                  content: Text('Incorrect username or password.'),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.pink[900],
                content: Text('Incorrect username or password.'),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.pink[900],
                content: Text('Error during login: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pink[900],
            content: Text('Please fill in all fields.'),
          ),
        );
      }
    }
  }
  // Method to attempt user registration
  Future<void> attemptRegister(
      BuildContext context,
      String username,
      String password,
      String name,
      String email,
      String shortDescription,
      List<int> interests,
      VoidCallback onRegistrationSuccess,
      ) async {
    if (username.isNotEmpty &&
        password.isNotEmpty &&
        name.isNotEmpty &&
        email.isNotEmpty &&
        shortDescription.isNotEmpty
    //interests.isNotEmpty
    ) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

        if (querySnapshot.docs.isEmpty) {
          String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
          UserCredential authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          String uid = authResult.user!.uid; // Use Firebase uid from authentication

          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'username': username,
            'password': hashedPassword,
            'name': name,
            'email': email,
            'shortDescription': shortDescription,
            'interests': interests,
            'completedChallenges': 0,
          });

          await login(username, password, context);

          onRegistrationSuccess();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.blue[900],
                content: Text('Registration successful! You are now logged in.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.pink[900],
              content: Text('Username already taken.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.pink[900],
              content: Text('Error during registration: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink[900],
          content: Text('Please fill in all fields.'),
        ),
      );
    }
  }

  // Method to fetch all interests from Firestore
  Future<Map<int, String>> fetchAllInterests() async {
    try {
      final interestsSnapshot =
      await FirebaseFirestore.instance.collection('interests').get();

      Map<int, String> allInterests = {};
      for (var doc in interestsSnapshot.docs) {
        allInterests[doc.data()['interestId'] as int] = doc.data()['name'];
      }
      return allInterests;
    } catch (e) {
      print('Error fetching all interests: $e');
      return {};
    }
  }

  // Method to update user data (username, email, and short description)
  Future<void> updateUserData(
      String newUserName, String newEmail, String newShortDescription) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': newUserName,
          'email': newEmail,
          'shortDescription': newShortDescription,
        });

        if (_currentUser != null) {
          _currentUser = MyUserData.fromMap({
            ..._currentUser!.toMap(),
            'name': newUserName,
            'email': newEmail,
            'shortDescription': newShortDescription,
          }, FirebaseFirestore.instance.collection('users').doc(user.uid).toString());

          notifyListeners();
        }
      } else {
        print('User not logged in. Cannot update data.');
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  // Method to update user interests in Firestore
  Future<void> updateUserInterests(List<int> newInterests) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'interests': newInterests,
        });

        if (_currentUser != null) {
          _currentUser = MyUserData.fromMap({
            ..._currentUser!.toMap(),
            'interests': newInterests,
          },FirebaseFirestore.instance.collection('users').doc(user.uid).toString());

          notifyListeners();
        }
      } else {
        print('User not logged in. Cannot update interests.');
      }
    } catch (e) {
      print('Error updating user interests: $e');
    }
  }
  // Ensure to cancel the stream subscription when the provider is disposed of
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
