import 'package:flutter/material.dart';


class AddFriendToChallenge extends StatelessWidget {
  const AddFriendToChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add your friends',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white,),
            iconSize: 30,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.blueGrey.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        automaticallyImplyLeading: false, // Entfernt den Zurückpfeil
      ),
      body: const Center(
        child: Text(
            'Here you can add the friends you´d like to challenge.',
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
    );
  }
}