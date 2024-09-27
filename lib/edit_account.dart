import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart';

class EditAccountPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final AuthProvider authProvider;
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
  late TextEditingController userNameController;
  late TextEditingController emailController;
  late TextEditingController shortDescriptionController;
  List<int> selectedInterests = [];
  Map<int, String> allInterests = {};
  bool isLoading = false;
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
    userNameController = TextEditingController(text: currentUser?.name ?? '');
    emailController = TextEditingController(text: currentUser?.email ?? '');
    shortDescriptionController = TextEditingController(text: currentUser?.shortDescription ?? '');
    selectedInterests = List.from(currentUser?.interests ?? []);
    _fetchInterests();
  }

  Future<void> _fetchInterests() async {
    final interests = await widget.authProvider.fetchAllInterests();
    setState(() {
      allInterests = interests;
    });
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
            _buildInterestChips(),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserForm() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: widget.screenHeight * 0.012,
        horizontal: widget.screenWidth * 0.014,
      ),
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          TextField(
            controller: userNameController,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: 'Enter new username'),
          ),
          SizedBox(height: widget.screenHeight * 0.015),
          TextField(
            controller: emailController,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: 'Enter new email'),
          ),
          SizedBox(height: widget.screenHeight * 0.015),
          TextField(
            controller: shortDescriptionController,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: 'Enter a short description'),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: selectedInterests.map((interestId) {
        return Chip(
          label: Text(allInterests[interestId] ?? 'Unknown'),
          backgroundColor: Colors.blueGrey[300],
          onDeleted: () {
            setState(() {
              selectedInterests.remove(interestId);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildUpdateButton() {
    return isLoading
        ? const CircularProgressIndicator()
        : ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.blue[900]),
      ),
      onPressed: _submitChanges,
      child: const Text("Submit Changes"),
    );
  }

  Future<void> _submitChanges() async {
    if (!_isValidEmail(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.pink[900],
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // First, update user data
      await widget.authProvider.updateUserData(
        userNameController.text,
        emailController.text,
        shortDescriptionController.text,
      );

      // Then, update user interests
      await widget.authProvider.updateUserInterests(selectedInterests);

      // After successful update, trigger the onUpdate callback
      widget.onUpdate(
        userNameController.text,
        emailController.text,
        shortDescriptionController.text,
        selectedInterests,
      );

      // Navigate back to the account page using the callback
    } catch (e) {
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
