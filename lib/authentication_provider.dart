import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'accountController.dart';
import 'myUser.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  MyUserData? _currentUser; // Changed to MyUserData

  bool get isLoggedIn => _isLoggedIn;
  MyUserData? get currentUser => _currentUser;

  Future<void> checkLoginStatus(BuildContext context) async {
    // Check if there's a currently logged-in Firebase user
    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser != null) {
      // If there is, fetch their additional data from Firestore
      _currentUser = await getUserData(firebaseUser);

      if (_currentUser != null) {
        _isLoggedIn = true;
        notifyListeners(); // Notify listeners that the user is logged in
      } else {
        // Handle the case where the Firebase user exists, but their data isn't in Firestore
        // You might want to log the user out or handle this in another way
        print('Firebase user exists, but user data not found in Firestore.');
      }
    } else {
      _isLoggedIn = false;
      _currentUser = null;
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
      ) async {
    // Basic validation
    if (username.isNotEmpty &&
        password.isNotEmpty &&
        name.isNotEmpty &&
        email.isNotEmpty &&
        shortDescription.isNotEmpty &&
        interests.isNotEmpty) { // Added interests check
      try {
        // Check if username already exists
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

        if (querySnapshot.docs.isEmpty) {
          // Username is available, proceed with registration
          String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
          await FirebaseFirestore.instance.collection('users').add({
            'username': username,
            'password': hashedPassword,
            'name': name,
            'email': email,
            'shortDescription': shortDescription,
            'interests': interests,
          });

          // After successful registration, log the user in automatically
          await login(username, password, context);

          // Optionally show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful! You are now logged in.')),
          );
        } else {
          // Username already exists, show error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red, // Changed color for better visibility
              content: Text('Username already taken.'),
            ),
          );
        }
      } catch (e) {
        // Error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during registration: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please fill in all fields.'),
        ),
      );
    }
  }

  Future<void> login(String username, String password, BuildContext context) async { // Pass context
    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          final storedHashedPassword = userData['password'];
    if (BCrypt.checkpw(password, storedHashedPassword)) {
    _isLoggedIn = true;
    _currentUser = MyUserData.fromMap(userData);
    notifyListeners();

    // Instead of navigating directly, trigger a state change in MyAccountState
    // You'll need a way to communicate this to MyAccountState
    // One option is to use a callback or a state management solution
    } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text('Incorrect username or password.'),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Incorrect username or password.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during login: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Please fill in all fields.'),
        ),
      );
    }
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    if (_currentUser == null) return {};

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid) // Access uid from MyUserData
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;

        final interestsSnapshot =
        await userDoc.reference.collection('interests').get();
        List<int> interests = [];
        for (var doc in interestsSnapshot.docs) {
          interests.add(doc.data()['interestId'] as int);
        }
        userData['interests'] = interests;

        return userData;
      } else {
        print('User document not found');
        return {};
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }

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

  Future<void> updateUserData(
      String newUserName, String newEmail, String newShortDescription) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch the existing user data first
        final myUserData = await getUserData(user);
        if (myUserData != null) {
          // Update Firestore with the new data
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'name': newUserName,
            'email': newEmail,
            'shortDescription': newShortDescription,
          });

          // Update the local _currentUser object
          _currentUser = MyUserData.fromMap({
            ...myUserData.toMap(), // Keep existing data
            'name': newUserName,
            'email': newEmail,
            'shortDescription': newShortDescription,
          });

          notifyListeners(); // Notify listeners of the change
        } else {
          // Handle the case where the user document doesn't exist
          print('User document not found. Cannot update data.');
          // You might want to throw an exception or show an error message here
        }
      } else {
        // Handle the case where the user is not logged in
        print('User not logged in. Cannot update data.');
        // You might want to throw an exception or show an error message here
      }
    } catch (e) {
      // Handle errors that might occur during the update
      print('Error updating user data: $e');
      // Consider rethrowing the exception or showing an error message to the user
    }
  }

  Future<void> updateUserInterests(List<int> newInterests) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch existing user data
        final myUserData = await getUserData(user);
        if (myUserData != null) {
          // Update interests in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'interests': newInterests,
          });

          // Update the local _currentUser object
          _currentUser = MyUserData.fromMap({
            ...myUserData.toMap(),
            'interests': newInterests,
          });

          notifyListeners();
        } else {
          // Handle the case where the user document doesn't exist
          print('User document not found. Cannot update interests.');
        }
      } else {
        // Handle the case where the user is not logged in
        print('User not logged in. Cannot update interests.');
      }
    } catch (e) {
      // Handle errors that might occur during the update
      print('Error updating user interests: $e');
    }
  }
}