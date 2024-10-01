import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart';
import 'interest_selection.dart';

/// A stateful widget that collects additional registration details from the user.
class RegisterDetailsPage extends StatefulWidget {
  /// The width of the screen for responsive design.
  final double screenWidth;

  /// The height of the screen for responsive design.
  final double screenHeight;

  /// Temporary username from the initial registration step.
  final String tempUsername;

  /// Temporary password from the initial registration step.
  final String tempPassword;

  /// Map of all available interests (ID to name).
  final Map<int, String> allInterests;

  /// Callback function to execute upon successful registration.
  final VoidCallback onRegistrationComplete;

  /// Callback function to execute when navigating back to the previous page.
  final VoidCallback onBack;

  /// Creates a [RegisterDetailsPage] with the required parameters.
  const RegisterDetailsPage({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.tempUsername,
    required this.tempPassword,
    required this.allInterests,
    required this.onRegistrationComplete,
    required this.onBack,
  }) : super(key: key);

  @override
  _RegisterDetailsPageState createState() => _RegisterDetailsPageState();
}

class _RegisterDetailsPageState extends State<RegisterDetailsPage> {
  /// Controller for the name input field.
  final TextEditingController userNameController = TextEditingController();

  /// Controller for the email input field.
  final TextEditingController emailController = TextEditingController();

  /// Controller for the short description input field.
  final TextEditingController shortDescriptionController = TextEditingController();

  /// List of selected interest IDs.
  List<int> selectedInterests = [];

  /// Indicates whether the registration process is ongoing.
  bool isRegistering = false;

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    shortDescriptionController.dispose();
    super.dispose();
  }

  /// Validates the email format.
  bool _isValidEmail(String email) {
    String emailPattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final allInterests = widget.allInterests;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Registration"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
          tooltip: 'Back to Register',
        ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.screenWidth * 0.05,
            vertical: widget.screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Profile Avatar
              CircleAvatar(
                radius: widget.screenHeight * 0.07,
                backgroundImage: const AssetImage('assets/images/profile_placeholder.png'), // Ensure this path is correct
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: widget.screenHeight * 0.03),

              // Input Form
              _buildInputForm(),
              SizedBox(height: widget.screenHeight * 0.025),

              SizedBox(height: widget.screenHeight * 0.01),
              _buildInterestChips(allInterests),
              SizedBox(height: widget.screenHeight * 0.03),

              // Buttons
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the input form with enhanced styling and icons.
  Widget _buildInputForm() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: widget.screenHeight * 0.02,
        horizontal: widget.screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: Colors.blueGrey[700],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Name Field
          TextField(
            controller: userNameController,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person, color: Colors.pink[600]),
              hintText: 'Enter your name',
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
          SizedBox(height: widget.screenHeight * 0.02),

          // Email Field
          TextField(
            controller: emailController,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email, color: Colors.pink[600]),
              hintText: 'Enter your email',
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
          SizedBox(height: widget.screenHeight * 0.02),

          // Short Description Field
          TextField(
            controller: shortDescriptionController,
            textAlign: TextAlign.left,
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
            maxLength: 150, // Optional: Limit to 150 characters
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.screenHeight * 0.022,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the interest chips displaying selected interests.
  Widget _buildInterestChips(Map<int, String> allInterests) {
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
          backgroundColor: Colors.pink[600],
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

  /// Builds the buttons for adding interests and completing registration.
  Widget _buildButtons() {
    return Column(
      children: [
        // Add Interests Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900],
            padding: EdgeInsets.symmetric(
              vertical: widget.screenHeight * 0.02,
              horizontal: widget.screenWidth * 0.08,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: _selectInterests,
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            'Add Interests',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.screenHeight * 0.022,
            ),
          ),
        ),
        SizedBox(height: widget.screenHeight * 0.015),

        // Complete Registration Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[700],
            padding: EdgeInsets.symmetric(
              vertical: widget.screenHeight * 0.02,
              horizontal: widget.screenWidth * 0.1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: isRegistering ? null : () => _completeRegistration(),
          icon: isRegistering
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Icon(Icons.check_circle, color: Colors.white),
          label: Text(
            isRegistering ? 'Registering...' : 'Complete Registration',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.screenHeight * 0.022,
            ),
          ),
        ),
      ],
    );
  }

  /// Opens the interest selection dialog and updates the selected interests.
  Future<void> _selectInterests() async {
    if (widget.allInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pink,
          content: Text('No interests available to select.'),
        ),
      );
      return;
    }

    final List<int>? newSelectedInterests = await showDialog<List<int>>(
      context: context,
      builder: (BuildContext context) {
        return InterestSelectionDialog(
          allInterests: widget.allInterests,
          selectedInterests: selectedInterests,
        );
      },
    );

    if (newSelectedInterests != null && newSelectedInterests.isNotEmpty) {
      setState(() {
        // Limit the number of interests to 5 for better UI management
        selectedInterests = newSelectedInterests.length > 5
            ? newSelectedInterests.sublist(0, 5)
            : newSelectedInterests;
      });
    }
  }

  /// Completes the registration process by invoking the AuthProvider.
  Future<void> _completeRegistration() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Input Validation
    if (userNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        shortDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pink,
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }

    if (selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pink,
          content: Text('Please select at least one interest.'),
        ),
      );
      return;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.pink,
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }

    setState(() => isRegistering = true);

    await authProvider.attemptRegister(
      context,
      widget.tempUsername,
      widget.tempPassword,
      userNameController.text.trim(),
      emailController.text.trim(),
      shortDescriptionController.text.trim(),
      selectedInterests,
      widget.onRegistrationComplete,
    );

    setState(() => isRegistering = false);
  }
}
