// authentication_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'myUser.dart';

/// A provider that manages authentication and user data.
class AuthProvider extends ChangeNotifier {
  /// Indicates whether the user is currently logged in.
  bool _isLoggedIn = false;

  /// The current user's data.
  MyUserData? _currentUser;

  /// Subscription to authentication state changes.
  StreamSubscription<User?>? _authStateSubscription;

  /// Firestore instance for database operations.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Getter for login status.
  bool get isLoggedIn => _isLoggedIn;

  /// Getter for current user data.
  MyUserData? get currentUser => _currentUser;

  /// Subscription to the user's document in Firestore.
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  /// Initializes the authentication provider by setting up listeners.
  AuthProvider() {
    _initializeUser();
  }

  /// Initializes the user by listening to authentication state changes.
  Future<void> _initializeUser() async {
    _authStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) async {
          if (user != null) {
            if (_currentUser == null || _currentUser!.uid != user.uid) {
              await fetchUserData(user.uid);
              _isLoggedIn = true;
              notifyListeners();
            }
          } else {
            if (_isLoggedIn) {
              _isLoggedIn = false;
              _currentUser = null;
              notifyListeners();
            }
          }
        });
  }

  /// Fetches user data from Firestore and listens for real-time updates.
  Future<void> fetchUserData(String uid) async {
    // Cancel any existing subscription to prevent memory leaks.
    await _userDocSubscription?.cancel();

    _userDocSubscription = _firestore.collection('users').doc(uid).snapshots().listen((userSnapshot) {
      if (userSnapshot.exists) {
        _currentUser = MyUserData.fromMap(userSnapshot.data()!, uid);
        notifyListeners();
      }
    });
  }

  /// Checks the current login status of the user.
  Future<void> checkLoginStatus() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      if (_currentUser == null || _currentUser!.uid != firebaseUser.uid) {
        await fetchUserData(firebaseUser.uid);
        _isLoggedIn = true;
      }
    } else {
      _isLoggedIn = false;
      _currentUser = null;
    }
    notifyListeners();
  }

  /// Logs out the current user.
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

  /// Logs in a user with the provided username and password.
  Future<void> login(
      String username, String password, BuildContext context) async {
    if (!_isLoggedIn && username.isNotEmpty && password.isNotEmpty) {
      try {
        // Query Firestore for the user with the given username.
        final querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userData = querySnapshot.docs.first.data();
          final storedHashedPassword = userData['password'];
          final email = userData['email'];

          // Verify the password using bcrypt.
          if (BCrypt.checkpw(password, storedHashedPassword)) {
            // Sign in with Firebase Authentication.
            UserCredential authResult =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

            // Fetch user data after successful authentication.
            await fetchUserData(authResult.user!.uid);

            if (_currentUser != null) {
              _isLoggedIn = true;
              notifyListeners();
            } else {
              print('Error: User data not correctly assigned.');
            }
          } else {
            // Show error if password does not match.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.pink[900],
                content: Text('Incorrect username or password.'),
              ),
            );
          }
        } else {
          // Show error if username is not found.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.pink[900],
              content: Text('Incorrect username or password.'),
            ),
          );
        }
      } catch (e) {
        // Show error for any exceptions during login.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.pink[900],
              content: Text('Error during login: $e')),
        );
      }
    } else {
      // Show error if username or password fields are empty.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink[900],
          content: Text('Please fill in all fields.'),
        ),
      );
    }
  }

  /// Attempts to register a new user with the provided details.
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
        shortDescription.isNotEmpty) {
      try {
        // Check if the username is already taken.
        final querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

        if (querySnapshot.docs.isEmpty) {
          // Hash the password using bcrypt.
          String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

          // Create a new user with Firebase Authentication.
          UserCredential authResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          String uid = authResult.user!.uid;

          // Store user details in Firestore.
          await _firestore.collection('users').doc(uid).set({
            'username': username,
            'password': hashedPassword,
            'name': name,
            'email': email,
            'shortDescription': shortDescription,
            'interests': interests,
            'completedChallenges': 0,
            'friends': [], // Initialize with empty friends list.
          });

          // Automatically log in the user after registration.
          await login(username, password, context);

          // Callback after successful registration.
          onRegistrationSuccess();

          // Show success message.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.blue[900],
              content: Text('Registration successful! You are now logged in.'),
            ),
          );
        } else {
          // Show error if username is already taken.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.pink[900],
              content: Text('Username already taken.'),
            ),
          );
        }
      } catch (e) {
        // Handle specific Firebase authentication errors.
        String snackBarText = "";
        if(e.toString() == "[firebase_auth/invalid-email] The email address is badly formatted.") {
          snackBarText = "Please enter a valid E-Mail";
        }
        else if(e.toString() == "[firebase_auth/weak-password] Password should be at least 6 characters.") {
          snackBarText = "Password has to be at least 6 characters";
        }
        else snackBarText  = e.toString();

        // Show error message.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pink[900],
            content:
            Text('Error during registration: $snackBarText'),
          ),
        );
      }
    } else {
      // Show error if any registration fields are empty.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink[900],
          content: Text('Please fill in all fields.'),
        ),
      );
    }
  }

  /// Updates the user's challenge list.
  void updateUserChallenges(List<String> challenges) {
    if (_currentUser != null) {
      _currentUser!.challenges = challenges;
      notifyListeners(); // Trigger rebuilds where AuthProvider is used.
    }
  }

  /// Fetches all available interests from Firestore.
  Future<Map<int, String>> fetchAllInterests() async {
    try {
      final interestsSnapshot = await _firestore.collection('interests').get();

      Map<int, String> allInterests = {};
      for (var doc in interestsSnapshot.docs) {
        if (doc.exists) {
          final data = doc.data();
          if (data.containsKey('interestId') && data.containsKey('name')) {
            final interestId = data['interestId'];
            final name = data['name'];
            if (interestId is int && name is String) {
              allInterests[interestId] = name;
            }
          }
        }
      }
      return allInterests;
    } catch (e) {
      print('Error fetching all interests: $e');
      return {};
    }
  }

  /// Updates the user's basic data (name, email, short description).
  Future<void> updateUserData(
      String newUserName, String newEmail, String newShortDescription) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
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
        }, user.uid);
        notifyListeners();
      }
    } else {
      print('User not logged in. Cannot update data.');
    }
  }

  /// Updates the user's interests.
  Future<void> updateUserInterests(List<int> newInterests) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({'interests': newInterests});

      if (_currentUser != null) {
        _currentUser = MyUserData.fromMap({
          ..._currentUser!.toMap(),
          'interests': newInterests,
        }, user.uid);
        notifyListeners();
      }
    } else {
      print('User not logged in. Cannot update interests.');
    }
  }

  /// Adds a new friend by username.
  Future<void> addFriend(String friendUsername, BuildContext context) async {
    try {
      // Find the user by username.
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: friendUsername)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Show error if user is not found.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pink[900],
            content: Text('User with username "$friendUsername" not found.'),
          ),
        );
        return;
      }

      final friendDoc = querySnapshot.docs.first;
      final friendData = MyUserData.fromMap(friendDoc.data(), friendDoc.id);

      if (friendData.uid == _currentUser!.uid) {
        // Prevent adding oneself as a friend.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pink[900],
            content: Text('You cannot add yourself as a friend.'),
          ),
        );
        return;
      }

      if (_currentUser!.friends.contains(friendData.uid)) {
        // Prevent adding the same friend multiple times.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pink[900],
            content: Text('${friendData.username} is already your friend.'),
          ),
        );
        return;
      }

      // Update current user's friends list.
      _currentUser!.friends.add(friendData.uid);
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'friends': _currentUser!.friends,
      });

      // Show success message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Added ${friendData.username} as a friend!'),
        ),
      );
    } catch (e) {
      print('Error adding friend: $e');
      // Show error message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink[900],
          content: Text('Failed to add friend: $e'),
        ),
      );
    }
  }

  /// Removes a friend by their UID.
  Future<void> removeFriend(String friendUid, BuildContext context) async {
    try {
      if (!_currentUser!.friends.contains(friendUid)) {
        // Show error if the user is not in the friends list.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pink[900],
            content: Text('This user is not in your friends list.'),
          ),
        );
        return;
      }

      // Remove the friend from the list.
      _currentUser!.friends.remove(friendUid);
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'friends': _currentUser!.friends,
      });

      // Show success message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Removed friend successfully.'),
        ),
      );
    } catch (e) {
      print('Error removing friend: $e');
      // Show error message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink[900],
          content: Text('Failed to remove friend: $e'),
        ),
      );
    }
  }

  /// Updates the user's list of completed challenges.
  Future<void> updateCompletedChallenges(String userId) async {
    try {
      final userSnapshot =
      await _firestore.collection('users').doc(userId).get();

      if (!userSnapshot.exists) return;

      final List<String> challengeIds =
      (userSnapshot['challenges'] as List<dynamic>).cast<String>();

      if (challengeIds.isEmpty) {
        await _firestore.collection('users').doc(userId).update({'completedChallenges': 0});
        return;
      }

      final challengesSnapshot = await _firestore
          .collection('challenge')
          .where(FieldPath.documentId, whereIn: challengeIds)
          .get();

      int completedChallengesCount = 0;

      for (var doc in challengesSnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final int finalDuration = data['finalDuration'] as int;
        final daysPassed = DateTime.now().difference(createdAt).inDays;

        if (daysPassed >= finalDuration) completedChallengesCount++;
      }

      await _firestore.collection('users').doc(userId).update({'completedChallenges': completedChallengesCount});
    } catch (e) {
      print('Error updating completed challenges: $e');
    }
  }

  /// Calculates the number of completed challenges for the current user.
  Future<void> calculateCompletedChallenges() async {
    if (_currentUser == null) return;

    try {
      final challengesSnapshot = await _firestore
          .collection('challenge')
          .where(FieldPath.documentId, whereIn: _currentUser!.challenges.length > 10
          ? _currentUser!.challenges.sublist(0, 10)
          : _currentUser!.challenges)
          .get();

      int completedChallengesCount = 0;
      DateTime currentDate = DateTime.now();

      for (var doc in challengesSnapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final int finalDuration = data['finalDuration'] as int;
        final daysPassed = currentDate.difference(createdAt).inDays;

        if (daysPassed >= finalDuration) completedChallengesCount++;
      }

      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .update({'completedChallenges': completedChallengesCount});

      _currentUser = MyUserData(
        uid: _currentUser!.uid,
        username: _currentUser!.username,
        name: _currentUser!.name,
        email: _currentUser!.email,
        shortDescription: _currentUser!.shortDescription,
        interests: _currentUser!.interests,
        challenges: _currentUser!.challenges,
        completedChallenges: completedChallengesCount,
      );

      notifyListeners();
    } catch (e) {
      print('Error calculating completed challenges: $e');
    }
  }

  /// Updates the user's list of challenges.
  void updateUserChallengesList(List<String> challenges) {
    if (_currentUser != null) {
      _currentUser!.challenges = challenges;
      notifyListeners();
    }
  }

  /// Updates the user's list of friends.
  void updateUserFriendsList(List<String> friends) {
    if (_currentUser != null) {
      _currentUser!.friends = friends;
      notifyListeners();
    }
  }
}
