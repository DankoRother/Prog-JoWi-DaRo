import 'package:flutter/material.dart';
import 'date_notifier.dart'; // Achten Sie darauf, dass dieser Import korrekt ist

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Zeige das simulierte Datum an
          ValueListenableBuilder<DateTime>(
            valueListenable: simulatedDate,
            builder: (context, value, child) {
              return Text(
                'Current Date: ${value.toLocal()}',
                style: const
                TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.white
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Buttons zum Ändern des Datums
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _changeDate(-1),
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
                onPressed: () => _changeDate(1),
                child: const Text('+ DAY'),
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
            onPressed: _resetToCurrentDate,
            child: const Text('CURRENT DATE'),
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

  // Funktion zum Ändern des Datums
  void _changeDate(int days) {
    simulatedDate.value = simulatedDate.value.add(Duration(days: days));
  }

  // Funktion zum Zurücksetzen auf das aktuelle Datum
  void _resetToCurrentDate() {
    simulatedDate.value = DateTime.now();
  }
}
