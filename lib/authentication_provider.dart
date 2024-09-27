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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool get isLoggedIn => _isLoggedIn;
  MyUserData? get currentUser => _currentUser;

  AuthProvider() {
    _initializeUser();
  }

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
      final userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (!userSnapshot.exists) return;

      final List<String> challengeIds =
      (userSnapshot['challenges'] as List<dynamic>).cast<String>();

      if (challengeIds.isEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'completedChallenges': 0});
        return;
      }

      final challengesSnapshot = await FirebaseFirestore.instance
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

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'completedChallenges': completedChallengesCount});
    } catch (e) {
      print('Error updating completed challenges: $e');
    }
  }

  Future<void> fetchUserData(String uid) async {
    try {
      final userSnapshot = await _firestore.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        _currentUser = MyUserData.fromMap(userSnapshot.data()!, uid);
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
      final challengesSnapshot = await _firestore
          .collection('challenge')
          .where(FieldPath.documentId, whereIn: _currentUser!.challenges)
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

  Future<void> login(
      String username, String password, BuildContext context) async {
    if (!_isLoggedIn && username.isNotEmpty && password.isNotEmpty) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userData = querySnapshot.docs.first.data();
          final storedHashedPassword = userData['password'];
          final email = userData['email'];

          if (BCrypt.checkpw(password, storedHashedPassword)) {
            UserCredential authResult =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

            await fetchUserData(authResult.user!.uid);

            if (_currentUser != null) {
              _isLoggedIn = true;
              notifyListeners();
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
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

        if (querySnapshot.docs.isEmpty) {
          String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
          UserCredential authResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          String uid = authResult.user!.uid;

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
              content: Text('Registration successful! You are now logged in.'),
            ),
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
        String snackBarText = "";
        if(e.toString() == "[firebase_auth/invalid-email] The email address is badly formatted.") {
            snackBarText = "Please enter a valid E-Mail";
        }
        else snackBarText  = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.pink[900],
            content:
              Text('Error during registration: $snackBarText'),
          ),
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

  Future<Map<int, String>> fetchAllInterests() async {
    try {
      final interestsSnapshot =
      await FirebaseFirestore.instance.collection('interests').get();

      Map<int, String> allInterests = {};
      for (var doc in interestsSnapshot.docs) {
        allInterests[doc['interestId'] as int] = doc['name'];
      }
      return allInterests;
    } catch (e) {
      print('Error fetching all interests: $e');
      return {};
    }
  }

  Future<void> updateUserData(
      String newUserName, String newEmail, String newShortDescription) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
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

  Future<void> updateUserInterests(List<int> newInterests) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'interests': newInterests});

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

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
