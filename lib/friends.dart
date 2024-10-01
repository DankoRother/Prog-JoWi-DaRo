import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authentication_provider.dart'; // Ensure correct import path
import 'logInPrompt.dart'; // Ensure correct import path
import 'appBar.dart'; // Ensure correct import path
import 'myUser.dart'; // Ensure correct import path
import 'package:cloud_firestore/cloud_firestore.dart';

/// A stateful widget that displays the user's list of friends.
class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with AutomaticKeepAliveClientMixin {
  /// Controller for the add friend input field.
  final TextEditingController _addFriendController = TextEditingController();

  /// Indicates whether a friend is being added to prevent multiple submissions.
  bool _isAddingFriend = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _addFriendController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    return Scaffold(
      appBar: buildAppBar(
        context: context,
        loggedInTitle: 'Your Friends List',
        loggedOutTitle: 'Friends',
      ),
      // Display the friend list or prompt to log in based on authentication.
      body: isLoggedIn ? _buildFriendList(authProvider) : LogInPrompt(),
      // Floating action button to add a new friend.
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
        onPressed: () {
          _showAddFriendDialog(authProvider);
        },
        child: Icon(Icons.person_add),
        tooltip: 'Add Friend',
      )
          : null,
    );
  }

  /// Builds the list of friends by fetching their data from Firestore.
  Widget _buildFriendList(AuthProvider authProvider) {
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return Center(
        child: Text(
          'User data not found. Please log in again.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    if (currentUser.friends.isEmpty) {
      return Center(
        child: Text(
          'You don’t have any friends yet.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _getFriendsStream(currentUser.friends),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while fetching friends.
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          // Display an error message if something goes wrong.
          return Center(
            child: Text(
              'Error loading friends.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // Inform the user if no friends are found.
          return Center(
            child: Text(
              'You don’t have any friends yet.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          );
        }

        final friendsDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: friendsDocs.length,
          itemBuilder: (context, index) {
            final friendData = MyUserData.fromMap(
              friendsDocs[index].data() as Map<String, dynamic>,
              friendsDocs[index].id,
            );

            return Card(
              color: Colors.blueGrey[700],
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                // Display the friend's avatar with the initial of their name.
                leading: CircleAvatar(
                  backgroundColor: Colors.pink,
                  child: Text(
                    friendData.name.isNotEmpty ? friendData.name[0].toUpperCase() : 'U',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                // Display the friend's name.
                title: Text(
                  friendData.name,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                // Display the friend's short description.
                subtitle: Text(
                  friendData.shortDescription,
                  style: TextStyle(color: Colors.white70),
                ),
                // Button to remove the friend from the list.
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.redAccent),
                  onPressed: () {
                    _confirmRemoveFriend(friendData.uid, authProvider);
                  },
                  tooltip: 'Remove Friend',
                ),
                onTap: () {
                  // Optionally, navigate to the friend's profile page.
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Retrieves a stream of friends' data from Firestore based on their UIDs.
  Stream<QuerySnapshot> _getFriendsStream(List<String> friendsUids) {
    if (friendsUids.isEmpty) {
      // Return an empty stream if there are no friends.
      return Stream.empty();
    }

    // Firestore's 'whereIn' supports up to 10 items.
    List<String> limitedFriends = friendsUids.length > 10 ? friendsUids.sublist(0, 10) : friendsUids;

    return FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: limitedFriends)
        .snapshots();
  }

  /// Displays a dialog to add a new friend by entering their username.
  void _showAddFriendDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add a Friend"),
          content: TextField(
            controller: _addFriendController,
            decoration: InputDecoration(
              hintText: "Enter friend's username",
            ),
          ),
          actions: [
            // Cancel button to dismiss the dialog.
            TextButton(
              onPressed: () {
                _addFriendController.clear();
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            // Add button to initiate the friend addition process.
            TextButton(
              onPressed: _isAddingFriend
                  ? null
                  : () async {
                setState(() {
                  _isAddingFriend = true;
                });

                final friendUsername = _addFriendController.text.trim();
                if (friendUsername.isNotEmpty) {
                  await authProvider.addFriend(friendUsername, context);
                } else {
                  // Notify the user if the username field is empty.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.pink[900],
                      content: Text('Please enter a valid username.'),
                    ),
                  );
                }

                setState(() {
                  _isAddingFriend = false;
                });
                _addFriendController.clear();
                Navigator.of(context).pop();
              },
              child: _isAddingFriend
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text("Add"),
            ),
          ],
        );
      },
    );
  }

  /// Displays a confirmation dialog before removing a friend.
  void _confirmRemoveFriend(String friendUid, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Remove Friend"),
          content: Text("Are you sure you want to remove this friend?"),
          actions: [
            // Cancel button to dismiss the dialog.
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            // Remove button to confirm the removal.
            TextButton(
              onPressed: () async {
                await authProvider.removeFriend(friendUid, context);
                Navigator.of(context).pop();
              },
              child: Text(
                "Remove",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}
