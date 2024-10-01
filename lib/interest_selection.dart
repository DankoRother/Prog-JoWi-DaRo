import 'package:flutter/material.dart';

class InterestSelectionDialog extends StatefulWidget {
  final Map<int, String> allInterests;
  final List<int> selectedInterests;

  const InterestSelectionDialog({
    Key? key,
    required this.allInterests,
    required this.selectedInterests,
  }) : super(key: key);

  @override
  _InterestSelectionDialogState createState() => _InterestSelectionDialogState();
}

class _InterestSelectionDialogState extends State<InterestSelectionDialog> {
  late List<int> tempSelectedInterests;

  @override
  void initState() {
    super.initState();
    tempSelectedInterests = List<int>.from(widget.selectedInterests);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Select Interests',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.pink,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.allInterests.entries.map((entry) {
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(tempSelectedInterests),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
