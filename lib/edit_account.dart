// edit_account.dart

import 'package:flutter/material.dart';
import 'package:prog2_jowi_daro/main.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart';

/// A stateful widget that allows users to edit their account information.
class EditAccountPage extends StatefulWidget {
  /// The width of the screen for responsive design.
  final double screenWidth;

  /// The height of the screen for responsive design.
  final double screenHeight;

  /// The authentication provider to access user data and perform updates.
  final AuthProvider authProvider;

  /// Callback function to handle updates after successful editing.
  final Function(String, String, String, List<int>) onUpdate;

  const EditAccountPage({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.authProvider,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditAccountPageState createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  /// Controller for the username input field.
  late TextEditingController userNameController;

  /// Controller for the email input field.
  late TextEditingController emailController;

  /// Controller for the short description input field.
  late TextEditingController shortDescriptionController;

  /// List of selected interest IDs.
  List<int> selectedInterests = [];

  /// Map of all available interests.
  Map<int, String> allInterests = {};

  /// Indicates whether the update operation is in progress.
  bool isLoading = false;

  /// Validates the format of the provided email address.
  bool _isValidEmail(String email) {
    String emailPattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    final currentUser = widget.authProvider.currentUser;
    userNameController =
        TextEditingController(text: currentUser?.name ?? '');
    emailController = TextEditingController(text: currentUser?.email ?? '');
    shortDescriptionController =
        TextEditingController(text: currentUser?.shortDescription ?? '');
    selectedInterests = List.from(currentUser?.interests ?? []);
    _fetchInterests();
  }

  /// Fetches all available interests from the authentication provider.
  Future<void> _fetchInterests() async {
    final interests = await widget.authProvider.fetchAllInterests();
    setState(() {
      allInterests = interests;
    });
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    shortDescriptionController.dispose();
    super.dispose();
  }

  /// Opens a dialog for users to select their interests.
  Future<void> _selectInterests() async {
    // Temporary list to track selections within the dialog.
    List<int> tempSelectedInterests = List.from(selectedInterests);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Interests"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: allInterests.entries.map((entry) {
                return CheckboxListTile(
                  title: Text(entry.value),
                  value: tempSelectedInterests.contains(entry.key),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (tempSelectedInterests.length < 5) {
                          tempSelectedInterests.add(entry.key);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You can select up to 5 interests.'),
                            ),
                          );
                        }
                      } else {
                        tempSelectedInterests.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            // Cancel button to dismiss the dialog without changes.
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            // Confirm button to apply the selected interests.
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedInterests = tempSelectedInterests;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Account"),
        centerTitle: true,
        // Gradient background for the app bar.
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade400, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      // Main content wrapped in a scrollable view.
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: widget.screenWidth * 0.05,
              vertical: widget.screenHeight * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Profile Avatar
              CircleAvatar(
                radius: widget.screenHeight * 0.07,
                backgroundImage:
                const AssetImage('assets/images/profile_placeholder.png'),
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: widget.screenHeight * 0.03),
              // Input Form for user details.
              _buildUserForm(),
              SizedBox(height: widget.screenHeight * 0.025),
              // Display selected interests as chips.
              SizedBox(height: widget.screenHeight * 0.01),
              _buildInterestChips(),
              SizedBox(height: widget.screenHeight * 0.01),
              // Button to add more interests.
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  onPressed: _selectInterests,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Interests"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[600],
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.screenWidth * 0.03,
                      vertical: widget.screenHeight * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              SizedBox(height: widget.screenHeight * 0.03),
              // Button to submit the changes.
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the user input form with fields for username, email, and description.
  Widget _buildUserForm() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: widget.screenHeight * 0.02,
        horizontal: widget.screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: Colors.blueGrey[700],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Username Input Field
          TextField(
            controller: userNameController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person, color: Colors.pink[600]),
              hintText: 'Enter new username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.blueGrey[600],
            ),
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.screenHeight * 0.022,
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.015),
          // Email Input Field
          TextField(
            controller: emailController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email, color: Colors.pink[600]),
              hintText: 'Enter new email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.blueGrey[600],
            ),
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.screenHeight * 0.022,
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.015),
          // Short Description Input Field
          TextField(
            controller: shortDescriptionController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.description, color: Colors.pink[600]),
              hintText: 'Enter a short description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.blueGrey[600],
            ),
            maxLines: 2,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.screenHeight * 0.022,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the chips representing the user's selected interests.
  Widget _buildInterestChips() {
    if (selectedInterests.isEmpty) {
      return Text(
        "No interests selected.",
        style: TextStyle(
          color: Colors.white70,
          fontSize: widget.screenHeight * 0.02,
        ),
      );
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: selectedInterests.map((interestId) {
        return Chip(
          label: Text(
            allInterests[interestId] ?? 'Unknown',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.pink[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          deleteIcon: Icon(Icons.close, color: Colors.white),
          onDeleted: () {
            setState(() {
              selectedInterests.remove(interestId);
            });
          },
        );
      }).toList(),
    );
  }

  /// Builds the update button with loading state handling.
  Widget _buildUpdateButton() {
    return isLoading
        ? const CircularProgressIndicator()
        : ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pink[600],
        padding: EdgeInsets.symmetric(
          horizontal: widget.screenWidth * 0.1,
          vertical: widget.screenHeight * 0.02,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: _submitChanges,
      child: Text(
        "Submit Changes",
        style: standardText.copyWith(
          fontSize: widget.screenHeight * 0.022,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Handles the submission of changes with validation and feedback.
  Future<void> _submitChanges() async {
    // Validate the email format.
    if (!_isValidEmail(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid email address'),
          backgroundColor: Colors.pink[900],
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Update user data in Firestore.
      await widget.authProvider.updateUserData(
        userNameController.text,
        emailController.text,
        shortDescriptionController.text,
      );

      // Update user interests in Firestore.
      await widget.authProvider.updateUserInterests(selectedInterests);

      // Trigger the onUpdate callback to reflect changes in the parent widget.
      widget.onUpdate(
        userNameController.text,
        emailController.text,
        shortDescriptionController.text,
        selectedInterests,
      );

      // Notify the user of successful update.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: Colors.green[600],
        ),
      );
    } catch (e) {
      // Notify the user if an error occurs during the update.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
