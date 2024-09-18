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
  late List<int> _dialogSelectedInterests;

  @override
  void initState() {
    super.initState();
    _dialogSelectedInterests = List.from(widget.selectedInterests);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Interests'),
      content: SingleChildScrollView(
        child: Column(
          children: widget.allInterests.entries
              .where((entry) => !_dialogSelectedInterests.contains(entry.key))
              .map((entry) {
            return CheckboxListTile(
              title: Text(entry.value),
              value: _dialogSelectedInterests.contains(entry.key),
              onChanged: (bool? value) {
                setState(() {
                  if (value!) {
                    _dialogSelectedInterests.add(entry.key);
                  } else {
                    _dialogSelectedInterests.remove(entry.key);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_dialogSelectedInterests);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}