import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart';
import 'interest_selection.dart';

class RegisterDetailsPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final String tempUsername;
  final String tempPassword;
  final Map<int, String> allInterests;
  final VoidCallback onRegistrationComplete;

  const RegisterDetailsPage({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.tempUsername,
    required this.tempPassword,
    required this.allInterests,
    required this.onRegistrationComplete,
  }) : super(key: key);

  @override
  _RegisterDetailsPageState createState() => _RegisterDetailsPageState();
}

class _RegisterDetailsPageState extends State<RegisterDetailsPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController shortDescriptionController = TextEditingController();
  List<int> selectedInterests = [];
  bool isRegistering = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
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
            _buildInputForm(),
            _buildInterestChips(),
            _buildButtons(authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm() {
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
            decoration: const InputDecoration(hintText: 'Enter your name'),
          ),
          SizedBox(height: widget.screenHeight * 0.01),
          TextField(
            controller: emailController,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(hintText: 'Enter your email'),
          ),
          SizedBox(height: widget.screenHeight * 0.01),
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
          label: Text(widget.allInterests[interestId]!),
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

  Widget _buildButtons(AuthProvider authProvider) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _selectInterests,
          child: const Text('Add Interests'),
        ),
        SizedBox(height: widget.screenHeight * 0.015),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue[900]),
          ),
          onPressed: isRegistering ? null : () => _completeRegistration(authProvider),
          child: const Text("Complete Registration"),
        ),
      ],
    );
  }

  Future<void> _selectInterests() async {
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
        selectedInterests = newSelectedInterests.sublist(
          0,
          newSelectedInterests.length > 3 ? 3 : newSelectedInterests.length,
        );
      });
    }
  }

  Future<void> _completeRegistration(AuthProvider authProvider) async {
    setState(() => isRegistering = true);

    await authProvider.attemptRegister(
      context,
      widget.tempUsername,
      widget.tempPassword,
      userNameController.text,
      emailController.text,
      shortDescriptionController.text,
      selectedInterests,
      widget.onRegistrationComplete,
    );

    setState(() => isRegistering = false);
  }
}
