import 'package:flutter/material.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart';
import 'user.dart';
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false; // Track whether the user is logged in

  bool get isLoggedIn => _isLoggedIn;
  User? _currentUser; // Store the currently logged-in user's information
  User? get currentUser => _currentUser;

void attemptRegister(BuildContext context, String username,
      String password, String name, String email, String shortDescription,
      List<int> interests) async {
    // Basic validation
    if (username.isNotEmpty &&
        password.isNotEmpty &&
        name.isNotEmpty &&
        email.isNotEmpty &&
        shortDescription.isNotEmpty) {
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
            // In a real app, you should hash the password before storing it
            'name': name,
            'email': email,
            'shortDescription': shortDescription,
            'interests': interests,
          });

          // After successful registration, you might want to log the user in automatically
          login(username, password);
        } else {
          // Username already exists, show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.pink[700],
              content: Text('Username already taken.'),
            ),
          );
        }
      } catch (e) {
        // Error handling
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error during registration: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink[700],
          content: Text('Please fill in all fields.'),
        ),
      );
    }
  }

  Future<void> attemptLogin(BuildContext context, String username, String password) async {
    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        // Query Firestore for the user with the given username
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // User found, check the password
          final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
          final storedHashedPassword = userData['password'];

          // Use BCrypt to verify the provided password against the stored hash
          if (BCrypt.checkpw(password, storedHashedPassword)) {
            // Login successful
            _isLoggedIn = true;
            _currentUser = User.fromMap(userData);
            notifyListeners();
          } else {
            // Incorrect password
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.pink[700],
                content: Text('Incorrect username or password.'), // More general error message for security
              ),
            );
          }
        } else {
          // User not found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.pink[700],
              content: Text('Incorrect username or password.'),
              // More general error message for security
            ),
          );
        }
      } catch (e) {
        // Error handling
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error during login: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.pink[700],
          content: Text('Please fill in all fields.'),
        ),
      );
    }
  }

  Future<void> login(String username, String password) async {
    try {
      // Fetch user data from Firestore based on username
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _currentUser = User.fromMap(querySnapshot.docs.first.data());
      }

      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      // Handle potential errors during login
      print("Error during login: $e");
      // You might also want to display an error message to the user
    }
  }

  // Add a logout method
  void logout() {
    _isLoggedIn = false;
    _currentUser = null; // Clear the current user's information
    notifyListeners();
  }
  Future<Map<String, dynamic>> fetchUserData() async {
    if (_currentUser == null) return {}; // Return empty map if no user is logged in

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.id)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;

        // Fetch interests
        final interestsSnapshot = await userDoc.reference.collection('interests').get();
        List<int> interests = [];
        for (var doc in interestsSnapshot.docs) {
          interests.add(doc.data()['interestId'] as int);
        }
        userData['interests'] = interests; // Add interests to the user data

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
      final interestsSnapshot = await FirebaseFirestore.instance
          .collection('interests')
          .get();

      Map<int, String> allInterests = {};
      for (var doc in interestsSnapshot.docs) {
        allInterests[doc.data()['interestId'] as int] = doc.data()['name'];
      }
      return allInterests;
    } catch (e) {
      print('Error fetching all interests: $e');
      return {}; // Return empty map in case of error
    }
  }

}
