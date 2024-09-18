import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart';
import 'main.dart';
import 'interest_selection.dart';

class EditAccountPage extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final AuthProvider authProvider;
  final String userName;
  final String email;
  final String shortDescription;
  final List<int> interests;
  final Map<int, String> allInterests;
  final Function(String, String, String, List<int>) onUpdate; // Callback to update parent state

  const EditAccountPage({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
    required this.authProvider,
    required this.userName,
    required this.email,
    required this.shortDescription,
    required this.interests,
    required this.allInterests,
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
    userNameController = TextEditingController(text: widget.userName);
    emailController = TextEditingController(text: widget.email);
    shortDescriptionController = TextEditingController(text: widget.shortDescription);
    selectedInterests = List.from(widget.interests);
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
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: widget.screenHeight * 0.04),
                CircleAvatar(
                  radius: widget.screenHeight * 0.07,
                  backgroundImage: const AssetImage(
                      'assets/images/profile_placeholder.png'),
                ),
                SizedBox(height: widget.screenHeight * 0.022),
                Container(
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
                        style: standardText.copyWith(
                          fontSize: standardText.fontSize! * 1.4,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Enter new username',
                        ),
                      ),
                      SizedBox(height: widget.screenHeight * 0.015),
                      TextField(
                        controller: emailController,
                        textAlign: TextAlign.center,
                        style: standardText.copyWith(
                            fontWeight: FontWeight.normal,
                            color: Colors.grey[800]
                        ),
                        decoration: InputDecoration(
                            hintText: 'Enter new email',
                            filled: true,
                            fillColor: Colors.blueGrey[300]
                        ),
                      ),
                      SizedBox(height: widget.screenHeight * 0.001),
                      TextField(
                        controller: shortDescriptionController,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        maxLength: 200,
                        style: standardText.copyWith(
                            fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                            hintText: 'Enter a short description about yourself',
                            filled: true,
                            fillColor: Colors.blueGrey[300]
                        ),
                      ),
                      SizedBox(height: widget.screenHeight * 0.025),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Colors.blue[900]),
                            ),
                            onPressed: () async {
                              // Update user data
                              await widget.authProvider.updateUserData(
                                userNameController.text,
                                emailController.text,
                                shortDescriptionController.text,
                              );

                              // Update user interests
                              await widget.authProvider.updateUserInterests(
                                  selectedInterests);

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
                              textAlign: TextAlign.center,
                              "Submit Changes",
                              style: standardText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: widget.screenHeight * 0.015),
                      Wrap(
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
                      ),
                      SizedBox(height: widget.screenHeight * 0.015),
                      ElevatedButton(
                        onPressed: () async {
                          final List<int>? newSelectedInterests =
                          await showDialog<List<int>>(
                            context: context,
                            builder: (BuildContext context) {
                              return InterestSelectionDialog(
                                  allInterests: widget.allInterests,
                                  selectedInterests: selectedInterests
                              );
                            },
                          );

                          if (newSelectedInterests != null &&
                              newSelectedInterests.isNotEmpty) {
                            setState(() {
                              selectedInterests = newSelectedInterests;
                              selectedInterests = selectedInterests.sublist(
                                0,
                                selectedInterests.length > 3
                                    ? 3
                                    : selectedInterests.length,
                              );
                            });
                          }
                        },
                        child: const Text('Add Interest'),
                      ),
                      SizedBox(height: widget.screenHeight * 0.015),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}