import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart';
import 'main.dart';
import 'interest_selection.dart';

class EditAccountPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final AuthProvider authProvider;
  final Function(String, String, String, List<int>) onUpdate; // Callback to update parent state

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
  late TextEditingController userNameController;
  late TextEditingController emailController;
  late TextEditingController shortDescriptionController;
  late List<int> selectedInterests;

  @override
  void initState() {
    super.initState();
    // Fetch the current user details from authProvider
    final currentUser = widget.authProvider.currentUser;

    // Initialize controllers with current user data
    userNameController = TextEditingController(text: currentUser?.name ?? '');
    emailController = TextEditingController(text: currentUser?.email ?? '');
    shortDescriptionController = TextEditingController(text: currentUser?.shortDescription ?? '');
    selectedInterests = List.from(currentUser?.interests ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade400, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Edit Account"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: widget.screenHeight * 0.04),
            CircleAvatar(
              radius: widget.screenHeight * 0.07,
              backgroundImage: const AssetImage('assets/images/profile_placeholder.png'),
            ),
            SizedBox(height: widget.screenHeight * 0.022),
            _buildUserForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserForm() {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: widget.screenHeight * 0.012,
          horizontal: widget.screenWidth * 0.014),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          TextField(
            controller: userNameController,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(hintText: 'Enter new username'),
          ),
          SizedBox(height: widget.screenHeight * 0.015),
          TextField(
            controller: emailController,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey[800]),
            decoration: InputDecoration(hintText: 'Enter new email', filled: true, fillColor: Colors.blueGrey[300]),
          ),
          SizedBox(height: widget.screenHeight * 0.001),
          TextField(
            controller: shortDescriptionController,
            textAlign: TextAlign.center,
            maxLines: 1,
            maxLength: 200,
            style: TextStyle(fontWeight: FontWeight.normal),
            decoration: InputDecoration(
                hintText: 'Enter a short description about yourself',
                filled: true,
                fillColor: Colors.blueGrey[300]),
          ),
          SizedBox(height: widget.screenHeight * 0.025),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue[900]),
            ),
            onPressed: () async {
              // Update user data
              await widget.authProvider.updateUserData(
                userNameController.text,
                emailController.text,
                shortDescriptionController.text,
              );

              // Update user interests
              await widget.authProvider.updateUserInterests(selectedInterests);

              // Call the callback to update the parent state
              widget.onUpdate(
                userNameController.text,
                emailController.text,
                shortDescriptionController.text,
                selectedInterests,
              );

              // Close the dialog
              Navigator.pop(context);
            },
            child: Text(
              "Submit Changes",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.015),
        ],
      ),
    );
  }
}
