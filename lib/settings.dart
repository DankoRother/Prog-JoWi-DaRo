import 'package:flutter/material.dart';
import 'date_notifier.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings', // Title of the app bar
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        actions: [
          // Close button to navigate back
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            iconSize: 30,
            onPressed: () {
              Navigator.of(context).pop(); // Close the settings page
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
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display the simulated date
          ValueListenableBuilder<DateTime>(
            valueListenable: simulatedDate, // Listen for changes in the simulated date
            builder: (context, value, child) {
              return Text(
                'Current Date: ${value.toLocal()}', // Show the current local date
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Buttons to change the date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _changeDate(-1), // Decrease the date by one day
                child: const Text('- DAY'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => _changeDate(1), // Increase the date by one day
                child: const Text('+ DAY'), // Button label
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetToCurrentDate, // Reset to the current date
            child: const Text('CURRENT DATE'), // Button label
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.pink,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              'Choose your Language etc.',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to change the date by a specified number of days
  void _changeDate(int days) {
    simulatedDate.value = simulatedDate.value.add(Duration(days: days)); // Update the simulated date
  }

  // Function to reset the date to the current date
  void _resetToCurrentDate() {
    simulatedDate.value = DateTime.now(); // Set simulated date to now
  }
}
